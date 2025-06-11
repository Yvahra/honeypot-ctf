# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        auditd \
        rsyslog \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Create a non-root user (Highly Recommended for Security)
ARG SSH_USER 
ARG SSH_PASS 
RUN useradd -m -s /bin/bash ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd  
# RUN usermod -aG sudo ${SSH_USER}  # Add user to the sudo group

# SSH Configuration
RUN mkdir /run/sshd

# Create required folder and start ssh server.
RUN mkdir -p /home/${SSH_USER}/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

RUN mkdir /home/root
COPY flag.txt /home/root/

# Set up audit rules
# Log commands for specific user using auid
RUN echo "-a always,exit -F arch=b64 -S execve -F auid=$(id -u ${SSH_USER}) -k user_commands" > /etc/audit/rules.d/user_commands.rules
RUN echo "-a always,exit -F arch=b32 -S execve -F auid=$(id -u ${SSH_USER}) -k user_commands" >> /etc/audit/rules.d/user_commands.rules

# Immutable rule - last rule
RUN echo "-e 2" >> /etc/audit/rules.d/user_commands.rules

# Configure rsyslog to forward audit logs
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf
RUN echo '$UDPServerRun 514' >> /etc/rsyslog.conf  # Listen on UDP port 514
RUN echo 'if $programname == "auditd" then @172.20.0.2:514' >> /etc/rsyslog.conf # Forward to remote server
RUN echo 'if $programname == "auditd" then ~' >> /etc/rsyslog.conf # Stop processing locally

# Expose the SSH port
EXPOSE 2222 514

# Start services
CMD /usr/sbin/auditd && rsyslogd && /usr/sbin/sshd -D
