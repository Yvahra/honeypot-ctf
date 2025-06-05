#!/bin/sh
/usr/sbin/sshd -D
python /app/dind/set-services.py
