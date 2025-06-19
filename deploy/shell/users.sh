#!/bin/bash

# Script to deploy an SSH service on port 22001

# --- Configuration ---
SSH_USER="user-ssh" # Dedicated user.
USER_PASSWD="user-passwd" # User password
SSH_GROUP="sshgroup" #  Dedicated group.
AUTHORIZED_KEYS_FILE="/home/${SSH_USER}/.ssh/authorized_keys" # Where public keys will be stored.
# --- End Configuration ---

# Check if the script is run as root (required for most operations)
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root.  Try 'sudo bash $0'"
  exit 1
fi


# DPELOY-MANAGER

# 1. Create the user if it doesn't exist
id "deploy-manager" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'deploy-manager'..."
  groupadd -f "deploy-group" # add the group. -f means it won't complain if it exists.
  useradd -m -g "deploy-group" -s /bin/bash "deploy-manager"
  echo "deploy-manager:I4mtHeMan@gerF0rsSh" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'deploy-manager' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/deploy-manager/.ssh"
chown -R "deploy-manager":"deploy-group" "/home/deploy-manager/.ssh"
chmod 700 "/home/deploy-manager/.ssh"
touch "/home/deploy-manager/.ssh/authorized_keys"
chown "deploy-manager":"deploy-group" "/home/deploy-manager/.ssh/authorized_keys"
chmod 600 "/home/deploy-manager/.ssh/authorized_keys"


# DPELOY-1

# 1. Create the user if it doesn't exist
id "deploy-1" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'deploy-1'..."
  groupadd -f "deploy-group" # add the group. -f means it won't complain if it exists.
  useradd -m -g "deploy-group" -s /bin/bash "deploy-1"
  echo "deploy-1:Iw4ntT0dEploysSh!" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'deploy-1' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/deploy-1/.ssh"
chown -R "deploy-1":"deploy-group" "/home/deploy-1/.ssh"
chmod 700 "/home/deploy-1/.ssh"
touch "/home/deploy-1/.ssh/authorized_keys"
chown "deploy-1":"deploy-group" "/home/deploy-1/.ssh/authorized_keys"
chmod 600 "/home/deploy-1/.ssh/authorized_keys"


# DPELOY-2

# 1. Create the user if it doesn't exist
id "deploy-2" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'deploy-2'..."
  groupadd -f "deploy-group" # add the group. -f means it won't complain if it exists.
  useradd -m -g "deploy-group" -s /bin/bash "deploy-2"
  echo "deploy-2:Iw4ntT0dEploysSh!" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'deploy-2' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/deploy-2/.ssh"
chown -R "deploy-2":"deploy-group" "/home/deploy-2/.ssh"
chmod 700 "/home/deploy-2/.ssh"
touch "/home/deploy-2/.ssh/authorized_keys"
chown "deploy-2":"deploy-group" "/home/deploy-2/.ssh/authorized_keys"
chmod 600 "/home/deploy-2/.ssh/authorized_keys"


# DPELOY-3

# 1. Create the user if it doesn't exist
id "deploy-3" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'deploy-3'..."
  groupadd -f "deploy-group" # add the group. -f means it won't complain if it exists.
  useradd -m -g "deploy-group" -s /bin/bash "deploy-3"
  echo "deploy-3:Iw4ntT0dEploysSh!" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'deploy-3' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/deploy-3/.ssh"
chown -R "deploy-3":"deploy-group" "/home/deploy-3/.ssh"
chmod 700 "/home/deploy-3/.ssh"
touch "/home/deploy-3/.ssh/authorized_keys"
chown "deploy-3":"deploy-group" "/home/deploy-3/.ssh/authorized_keys"
chmod 600 "/home/deploy-3/.ssh/authorized_keys"


# DPELOY-4

# 1. Create the user if it doesn't exist
id "deploy-4" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'deploy-4'..."
  groupadd -f "deploy-group" # add the group. -f means it won't complain if it exists.
  useradd -m -g "deploy-group" -s /bin/bash "deploy-4"
  echo "deploy-4:Iw4ntT0dEploysSh!" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'deploy-4' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/deploy-4/.ssh"
chown -R "deploy-4":"deploy-group" "/home/deploy-4/.ssh"
chmod 700 "/home/deploy-4/.ssh"
touch "/home/deploy-4/.ssh/authorized_keys"
chown "deploy-4":"deploy-group" "/home/deploy-4/.ssh/authorized_keys"
chmod 600 "/home/deploy-4/.ssh/authorized_keys"



# SSH-USERS

# 1. Create the user if it doesn't exist
id "ssh-user" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating user 'ssh-user'..."
  groupadd -f "users" # add the group. -f means it won't complain if it exists.
  useradd -m -g "users" -s /bin/bash "ssh-user"
  echo "ssh-user:Nev3rtRusty0uRM4n@ger!" | chpasswd
  #echo "New password for $SSH_USER: $PASSWORD" # Important! Securely store or change this immediately!
else
  echo "User 'ssh-user' already exists."
fi

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/ssh-user/.ssh"
chown -R "ssh-user":"users" "/home/ssh-user/.ssh"
chmod 700 "/home/ssh-user/.ssh"
touch "/home/ssh-user/.ssh/authorized_keys"
chown "ssh-user":"users" "/home/ssh-user/.ssh/authorized_keys"
chmod 600 "/home/ssh-user/.ssh/authorized_keys"

# 3. Copy private and public key

cp "../ssh-user-keys/id_rsa" "/home/ssh-user/.ssh/id_rsa"
cp "../ssh-user-keys/id_rsa.pub" "/home/ssh-user/.ssh/id_rsa.pub"


# AGENT

# 1. Create the user if it doesn't exist
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

# 2. Create .ssh directory and authorized_keys file
mkdir -p "/home/player/.ssh"
chown -R "agent":"players" "/home/player/.ssh"
chmod 700 "/home/player/.ssh"
touch "/home/player/.ssh/authorized_keys"
chown "player":"players" "/home/player/.ssh/authorized_keys"
chmod 600 "/home/player/.ssh/authorized_keys"

