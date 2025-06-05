#!/bin/sh
python3 "/app/dind/start-services.py"
/usr/sbin/sshd -D
