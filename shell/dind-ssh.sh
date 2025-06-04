#!/bin/bash

# Script to configure SSH for a Linux system
# This script requires root privileges to modify system files.

# --- Configuration Options ---
PORT="22"  # Default SSH port (change if desired)
PERMIT_ROOT_LOGIN="no" # Disable root login
PASSWORD_AUTHENTICATION="yes" # Disable password authentication
PUBKEY_AUTHENTICATION="no" # Enable public key authentication
ALLOW_USERS="player" # Optional: List of users allowed to SSH (separated by spaces)
DENY_USERS="" # Optional: List of users denied SSH access (separated by spaces)
TCP_KEEP_ALIVE="yes" # Enable TCP keep alive
CLIENT_ALIVE_INTERVAL="300" # Send client alive request every 5 minutes
CLIENT_ALIVE_COUNT_MAX="3"  # Server will disconnect after 3 failed requests

# --- Script Logic ---

# 1. Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges.  Please run with sudo."
  exit 1
fi

# 2. Check if user exists
id "player" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'player'..."
  groupadd -f "players" # add the group. -f means it won't complain if it exists.
  useradd -m -g "players" -s /bin/bash "player"
  echo "player:iwanttopawn" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'player' already exists."
fi

# 3. Create .ssh directory and authorized_keys file
mkdir -p "/home/player/.ssh"
chown -R "agent":"players" "/home/player/.ssh"
chmod 700 "/home/player/.ssh"
touch "/home/player/.ssh/authorized_keys"
chown "player":"players" "/home/player/.ssh/authorized_keys"
chmod 600 "/home/player/.ssh/authorized_keys"


# 2.  Check if SSH is installed
if ! command -v sshd &> /dev/null; then
  echo "SSH server is not installed. Installing..."
  apt update
  apt install -y openssh-server
  if [[ $? -ne 0 ]]; then
    echo "Failed to install SSH server."
    exit 1
  fi
fi

# 3. Back up the original SSH configuration file
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_BACKUP="${SSH_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"

cp "$SSH_CONFIG" "$SSH_CONFIG_BACKUP"
echo "Original SSH configuration backed up to: $SSH_CONFIG_BACKUP"

# 4. Configure SSH
echo "Configuring SSH..."

# Create a temporary file to hold the new configuration
TEMP_CONFIG=$(mktemp)

# Add/Modify configurations
echo "Port $PORT" >> "$TEMP_CONFIG"
echo "PermitRootLogin $PERMIT_ROOT_LOGIN" >> "$TEMP_CONFIG"
echo "PasswordAuthentication $PASSWORD_AUTHENTICATION" >> "$TEMP_CONFIG"
echo "PubkeyAuthentication $PUBKEY_AUTHENTICATION" >> "$TEMP_CONFIG"

if [[ ! -z "$ALLOW_USERS" ]]; then
  echo "AllowUsers $ALLOW_USERS" >> "$TEMP_CONFIG"
fi

if [[ ! -z "$DENY_USERS" ]]; then
  echo "DenyUsers $DENY_USERS" >> "$TEMP_CONFIG"
fi

echo "TCPKeepAlive $TCP_KEEP_ALIVE" >> "$TEMP_CONFIG"
echo "ClientAliveInterval $CLIENT_ALIVE_INTERVAL" >> "$TEMP_CONFIG"
echo "ClientAliveCountMax $CLIENT_ALIVE_COUNT_MAX" >> "$TEMP_CONFIG"

# Append any other existing configuration options.  We'll grep out the old versions of
# parameters that we just set, and keep the rest.
grep -vE "^(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|AllowUsers|DenyUsers|TCPKeepAlive|ClientAliveInterval|ClientAliveCountMax)" "$SSH_CONFIG" >> "$TEMP_CONFIG"

# Move the new config into place.
mv "$TEMP_CONFIG" "$SSH_CONFIG"

# 5. Set SSH permissions
chmod 600 "$SSH_CONFIG"
chown root:root "$SSH_CONFIG"

# 6. Restart the SSH service
echo "Restarting SSH service..."
systemctl restart sshd

if [[ $? -ne 0 ]]; then
  echo "Failed to restart SSH service."
  exit 1
fi

echo "SSH configuration complete."

# --- Notes ---
# * This script overwrites the /etc/ssh/sshd_config file.  A backup is created.
# *  You must configure public key authentication *before* disabling password authentication.
# *  Remember to generate SSH keys for users and place their public keys in ~/.ssh/authorized_keys.
# *  Test the configuration after running the script before relying on it.
# *  This script is a starting point and should be reviewed and modified
#    to meet the specific security requirements of your environment.
