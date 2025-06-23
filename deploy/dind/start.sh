#!/bin/sh
set -e

unset DOCKER_HOST

# Start Docker daemon
dockerd &

sleep 15
# Network
# Check if the 'honeynet' network exists
if ! docker network inspect honeynet >/dev/null 2>&1; then
  # Network doesn't exist, create it
  echo "Network 'honeynet' does not exist. Creating..."
  docker network create --subnet=10.0.0.0/8 --gateway=10.0.0.1 honeynet
  if [ $? -eq 0 ]; then
    echo "Network 'honeynet' created successfully."
  else
    echo "Error creating network 'honeynet'."
    exit 1  # Exit with an error code
  fi
else
  # Network exists
  echo "Network 'honeynet' already exists."
fi

# Build images
docker build --build-arg SSH_TYPE=0 -t ssh0 /app/ssh

# Start child Dockers
#python3 "/app/dind/start-services.py"

# Start SSH service
/usr/sbin/sshd -D &

# Start child Dockers
python3 "/app/dind/alarm.py" &


# Keep the container running
tail -f /dev/null
