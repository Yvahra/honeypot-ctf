#!/bin/sh
set -e

# Start SSH service
/usr/sbin/sshd -D &

# Start Docker daemon
cd /bin/rootshell && gcc asadmin.c -o shell
#chown ot-admin:admin /bin/rootshell/shell
cd /bin/rootshell && chmod u+s shell

# Keep the container running
tail -f /dev/null
