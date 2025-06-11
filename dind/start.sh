#!/bin/sh
set -e

# Start child Dockers
python3 "/app/dind/start-services.py"

# Start SSH service
/usr/sbin/sshd -D &

# Start auditd service
/usr/sbin/auditd &

# Start Docker daemon
#dockerd

# Keep the container running
tail -f /dev/null
