#!/bin/sh
set -e

# Network
docker network create --subnet=10.0.0.0/8 --gateway=10.0.0.1 honeynet

# Logs
docker volume create --name sharedLogs

# Start child Dockers
python3 "/app/dind/start-services.py"

# Start SSH service
/usr/sbin/sshd -D &


# Start Rsyslog
rsyslogd &

# Start Docker daemon
#dockerd

# Keep the container running
tail -f /dev/null
