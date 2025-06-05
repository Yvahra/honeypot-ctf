#!/bin/bash
set -e

# Set LC_ALL to C to prevent errors with locale.
export LC_ALL=C

#Activate Cowrie.
source venv/bin/activate

#Ensure the cowrie runs on specific interface
sed -i "s/listen_addr = 0.0.0.0/listen_addr = 0.0.0.0/" etc/cowrie.cfg

#If the ssh_enabled is not enabled, let enable it.
#The value should match COWRIE_PORT
sed -i "s/ssh_enabled = false/ssh_enabled = true/g" etc/cowrie.cfg
sed -i "s/ssh_port = 22/ssh_port = ${SSH_PORT}/g" etc/cowrie.cfg

# Configure data directory.
sed -i "s|database_url = sqlite:\/\/\/db.sqlite|database_url = sqlite:////opt/cowrie_data/db.sqlite|g" etc/cowrie.cfg
sed -i "s|textlog_file = log\/cowrie.log|textlog_file = \/opt\/cowrie_data\/cowrie.log|g" etc/cowrie.cfg

# Start Cowrie
/home/cowrie/cowrie/bin/cowrie start
