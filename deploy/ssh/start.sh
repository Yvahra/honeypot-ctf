#!/bin/sh
set -e

SSH_TYPE=$1

# 0 = Real SSH
# 1 = EasyPot1
# 2 = EasyPot2
# 3 = StrangePot1
# 4 = StrangePot2
# 5 = StrangePot3
# 6 = StrangePot4
# 7 = KnownPot1
# 8 = KnownPot2



# CREATE USERS

addgroup user
addgroup admin

if [ $SSH_TYPE -ne 1 ]; then
  useradd -m -s /bin/bash -g user james
  echo "james:password" | chpasswd  
  useradd -m -s /bin/bash -g admin james-adm
  echo "james-adm:password" | chpasswd  
  useradd -m -s /bin/bash -g user james2
  echo "james2:password" | chpasswd 
  useradd -m -s /bin/bash -g user robert
  echo "robert:password" | chpasswd 
else
	echo "No Real Users"
fi

useradd -m -s /bin/bash -g user ot-user
echo "ot-user:p@ssword" | chpasswd  
useradd -m -s /bin/bash -g admin ot-admin
echo "ot-admin:arblleabrhve2379r4b3214b9fJBDSABB@M@#KK@#" | chpasswd

if [ $SSH_TYPE = 2 ]; then
  useradd -m -s /bin/bash -g user user
  echo "user:password" | chpasswd  
else
	echo "No Common Users"
fi

if [ $SSH_TYPE = 3 ]; then
  useradd -m -s /bin/bash -g user honeyagent
  echo "honeyagent:password" | chpasswd  
else
	echo "No Honeypot Users"
fi

# CREATE PROCESS

if [ $SSH_TYPE -ne 1 ]; then
  echo "while True:\npass" > /app/update.py
  python /app/update.py &
else
	echo "No Real Data"
fi

# CREATE DATA

if [ $SSH_TYPE -ne 1 ]; then
  echo "N.B.: james told me that ot-user should be deleted... Robert." > /home/ot-user/README
else
	echo "No Real Data"
fi

# BANNER

# FLAG

if [ $SSH_TYPE = 0 ]; then
  mkdir -p /bin/rootshell
  echo "ECW{H0n3y_pr0of_pl@yer}" > /home/ot-admin/flag.txt
  echo '#include<stdio.h>' > /bin/rootshell/asroot.c
  echo '#include<unistd.h>' >> /bin/rootshell/asroot.c
  echo '#include<sys/types.h>' >> /bin/rootshell/asroot.c
  echo 'int main(){setuid(geteuid());system("/bin/bash");return 0;}' >> /bin/rootshell/asroot.c
  cd /bin/rootshell && gcc asroot.c -o shell
  cd /bin/rootshell && chmod u+s shell
  chmod 600 /home/ot-admin/flag.txt
  chown -R ot-admin:admin /home/ot-admin
else
	echo "No Flag Here"
fi


# LOG SYSTEM

echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /home/ot-user/.bashrc
echo 'history > /logs/command_history.log 2>/dev/null' >> /home/ot-user/.bashrc
echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /home/ot-user/.bashrc

echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /root/.bashrc
echo 'history -a > /logs/command_history.log 2>/dev/null' >> /root/.bashrc
echo 'PROMPT_COMMAND="history -a > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /root/.bashrc


# SERVICES

# SSH Configuration
mkdir /run/sshd
# Create required folder and start ssh server.
mkdir -p /home/ot-user/.ssh

echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

# Start SSH service
/usr/sbin/sshd -D &



# Keep the container running
tail -f /dev/null
