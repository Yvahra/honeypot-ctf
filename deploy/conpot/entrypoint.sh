#!/bin/bash
set -e

# Set LC_ALL to C to prevent errors with locale.
export LC_ALL=C

# --- Configure SSH to only listen on localhost ---
# Add or modify the ListenAddress setting in /etc/ssh/sshd_config
# This is important for security; it ensures SSH only listens on the container's
# loopback interface. This means that it is only accessible from inside
# the container.  The port mapping in docker will make this available.
sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/g" /etc/ssh/sshd_config

# --- Run Conpot's entrypoint (keeping most of the original features) ---
# This will run the Conpot services.  The image uses gunicorn, so it starts the service.

# --- Start conpot with a different port number.
/opt/conpot/conpot --listen-address 0.0.0.0 --listen-port 80 --http-address 0.0.0.0  --ssh-port 22
# /opt/conpot/conpot -c /opt/conpot/conpot.cfg # If you use the config file
