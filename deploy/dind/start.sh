#!/bin/sh
set -e

unset DOCKER_HOST

FLAG=$(cat /app/config/flag)
PASS=$(cat /app/config/hard_password)

mkdir -p /logs/-1
mkdir -p /jail//logs
mount --bind /logs/-1 /jail/logs

# Start Docker daemon
dockerd &

sleep 5
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

mkdir -p /jail/home/nobody1
cp -r /home/nobody1 /jail/home/nobody1
echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /jail/home/nobody1/.bashrc
echo 'history > /logs/command_history.log 2>/dev/null' >> /jail/home/nobody1/.bashrc
echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /jail/home/nobody1/.bashrc


# Build images
#docker build -t ssh_image /app/ssh
docker build --build-arg SSH_TYPE=0 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh0 /app/ssh
docker build --build-arg SSH_TYPE=1 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh1 /app/ssh
docker build --build-arg SSH_TYPE=2 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh2 /app/ssh
docker build --build-arg SSH_TYPE=3 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh3 /app/ssh
docker build --build-arg SSH_TYPE=4 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh4 /app/ssh
docker build --build-arg SSH_TYPE=5 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh5 /app/ssh
docker build --build-arg SSH_TYPE=6 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh6 /app/ssh
docker build --build-arg SSH_TYPE=7 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh7 /app/ssh
docker build --build-arg SSH_TYPE=8 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh8 /app/ssh
# Start child Dockers
python3 "/app/dind/start-services.py"

# Start SSH service
/usr/sbin/sshd -D &

# Start child Dockers
python3 "/app/dind/alarm.py" &


# Keep the container running
tail -f /dev/null
