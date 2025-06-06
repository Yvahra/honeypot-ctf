#!/bin/bash

# Script to deploy an SSH service on port 22001

# --- Configuration ---
CONPOT_SSH_PORT=$1
CONPOT_SSH_USER=$2 # Dedicated user.
SSH_GROUP="deploy-group" #  Dedicated group.
AUTHORIZED_KEYS_FILE="/home/${SSH_USER}/.ssh/authorized_keys" # Where public keys will be stored.
# --- End Configuration ---

# Check if the script is run as root (required for most operations)
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root.  Try 'sudo bash $0'"
  exit 1
fi


# 3. Configure SSH daemon
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_CONFIG_FILE="/etc/ssh/sshd_config.bak"  # Back up the config

# Check if the backup file exists.  If not, create it.
if [ ! -f "$BACKUP_CONFIG_FILE" ]; then
    echo "Backing up $SSH_CONFIG_FILE to $BACKUP_CONFIG_FILE"
    cp "$SSH_CONFIG_FILE" "$BACKUP_CONFIG_FILE"
fi

# Modify SSH configuration
echo "Modifying SSH configuration..."
sed -i "s/#Port 22/Port ${SSH_PORT}/g" "$SSH_CONFIG_FILE"
sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g" "$SSH_CONFIG_FILE"
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" "$SSH_CONFIG_FILE"
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" "$SSH_CONFIG_FILE" #Disable Password Auth
sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" "$SSH_CONFIG_FILE" #Enable Key auth

#Ensure PubkeyAuthentication is enabled and PasswordAuthentication is disabled
grep -q '^PubkeyAuthentication yes' "$SSH_CONFIG_FILE" || echo "PubkeyAuthentication yes" >> "$SSH_CONFIG_FILE"
grep -q '^PasswordAuthentication no' "$SSH_CONFIG_FILE" || echo "PasswordAuthentication no" >> "$SSH_CONFIG_FILE"



# Optional: Limit which users can login via SSH.  This adds extra security.
#  Uncomment the following lines to only allow the specified user(s)
echo "AllowUsers $SSH_USER" >> "$SSH_CONFIG_FILE"

# 4. Restart SSH service
echo "Restarting SSH service..."
if command -v systemctl &> /dev/null; then
  systemctl restart ssh
elif command -v service &> /dev/null; then
  service ssh restart
else
  echo "Unable to restart SSH service.  Please restart manually."
fi


# 5. Configure firewall (if applicable)
echo "Configuring firewall..."

#Determine if using UFW or FirewallD
if command -v ufw &> /dev/null; then
    echo "Using UFW..."
    ufw allow "$SSH_PORT"/tcp
    # Uncomment the following line to enable UFW if it's not already enabled:
    # ufw enable
    ufw status # Display firewall status

elif command -v firewall-cmd &> /dev/null; then
    echo "Using FirewallD..."
    firewall-cmd --permanent --add-port="${SSH_PORT}/tcp"
    firewall-cmd --reload
    firewall-cmd --list-all # Display firewall status
else
    echo "No known firewall management tool found (ufw or firewall-cmd). Please configure your firewall manually."
fi

echo "Deployment complete!"
echo "SSH service is now running on port $SSH_PORT."
echo "Make sure to copy your public key to $AUTHORIZED_KEYS_FILE for '$SSH_USER'."
echo "Example: scp ~/.ssh/id_rsa.pub ${SSH_USER}@your_server_ip:$AUTHORIZED_KEYS_FILE"
