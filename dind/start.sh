#!/bin/sh
python3 "/app/dind/set-services.py"
/usr/sbin/sshd -D
