#!/bin/sh
set -e

# Start SSH service
/usr/sbin/sshd -D &

# Start Rsyslog
rsyslogd &

# Start Docker daemon
#dockerd

# Keep the container running
tail -f /dev/null
