#!/bin/bash
set -e

SSH_TYPE=0 #$(</app/ssh_type)
FLAG="ECW" #$(</app/flag)
PASS="pass" #$(</app/pass)

echo $SSH_TYPE

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

addgroup hacker
addgroup admin
addgroup temp
addgroup cowrie

if [ $SSH_TYPE -ne 1 ]; then
  echo "Add Real Users" 
  useradd -m -s /bin/bash -g hacker ghost
  echo "ghost:${PASS}" | chpasswd  
  useradd -m -s /bin/bash -g admin zephyr-adm
  echo "zephyr-adm:${PASS}" | chpasswd  
  useradd -m -s /bin/bash -g hacker zephyr
  echo "zephyr:${PASS}" | chpasswd 
  useradd -m -s /bin/bash -g hacker skywalker
  echo "skywalker:${PASS}" | chpasswd 
else
	echo "No Real Users"
fi

useradd -m -s /bin/bash -g temp ot-user
echo "ot-user:p@ssword" | chpasswd  
useradd -m -s /bin/bash -g admin ot-admin
echo "ot-admin:${PASS}" | chpasswd

if [ $SSH_TYPE -eq 2 ]; then
  echo "Add Common Users"
  useradd -m -s /bin/bash -g temp user
  echo "user:password" | chpasswd  
else
	echo "No Common Users"
fi

if [ $SSH_TYPE -eq 3 ]; then
  echo "Add Honeypot Users"
  useradd -m -s /bin/bash -g cowrie cowrie
  echo "cowrie:password" | chpasswd  
else
	echo "No Honeypot Users"
fi

# CREATE PROCESS

if [ $SSH_TYPE -ne 1 ]; then
  echo "Add Real Scripts"
  echo "while True:" > /app/update.py
  echo "    pass" >> /app/update.py
  python3 /app/update.py &
else
  echo "No Real Scripts"
fi

# CREATE DATA

if [ $SSH_TYPE -ne 1 ]; then
  echo "Add Real Data"
  echo "N.B.: Zephyr told me that ot-user should be deleted... Skywalker." > /home/ot-user/README
else
  echo "No Real Data"
fi

# BANNER

if [ $SSH_TYPE -ne 7 ]; then
  cat /app/ssh/banners/ssh > /etc/motd
else
  echo "Debian GNU/Linux 7 \n \l" > /etc/motd
fi

# FLAG

if [ $SSH_TYPE -eq 0 ]; then
  echo "Add Flag"
  mkdir -p /bin/rootshell
  echo "${FLAG}" > /home/ot-admin/flag.txt
  echo '#include<stdio.h>' > /bin/rootshell/asroot.c
  echo '#include<unistd.h>' >> /bin/rootshell/asroot.c
  echo '#include<sys/types.h>' >> /bin/rootshell/asroot.c
  echo 'int main(){setuid(geteuid());system("/bin/bash");return 0;}' >> /bin/rootshell/asroot.c
  cd /bin/rootshell && gcc asroot.c -o shell
  chmod u+s /bin/rootshell/shell 
  chmod 600 /home/ot-admin/flag.txt
  chown -R ot-admin:admin /home/ot-admin
else
	echo "No Flag Here"
fi


# LOG SYSTEM

echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /home/ot-user/.bashrc
echo 'history > /logs/command_history.log 2>/dev/null' >> /home/ot-user/.bashrc
echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /home/ot-user/.bashrc

#echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /root/.bashrc
#echo 'history -a > /logs/command_history.log 2>/dev/null' >> /root/.bashrc
#echo 'PROMPT_COMMAND="history -a > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /root/.bashrc


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
