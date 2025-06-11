# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        auditd \
        rsyslog \
        audispd-plugins \
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
# Create audisp directories and file
RUN mkdir -p /etc/audisp/plugins.d
RUN touch /etc/audisp/plugins.d/syslog.conf

# Create required folder and start ssh server.
RUN mkdir -p /home/${SSH_USER}/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

RUN mkdir /home/root
COPY flag.txt /home/root/


##
# Create audit.rules file
RUN echo "-a always,exit -F arch=b64 -S execve,execveat -F auid>=1000 -F auid!=4294967295 -k command" > /etc/audit/audit.rules

# Configure audispd to send audit events to rsyslog
RUN sed -i 's/^#log_file =.*/log_file = syslog/' /etc/audisp/plugins.d/syslog.conf
RUN sed -i 's/^#file_location =.*/file_location = syslog/' /etc/audisp/plugins.d/syslog.conf # For Ubuntu 22 and newer

# Configure rsyslog to receive audit messages
RUN echo '$ModLoad imuxsock # provides support for local system logging' >> /etc/rsyslog.conf
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf # UDP listener
RUN echo '$UDPServerRun 514' >> /etc/rsyslog.conf # Listen on UDP port 514 (or any unused port)
RUN echo 'if $programname == "auditd" then @172.20.0.2:514' >> /etc/rsyslog.conf
RUN echo 'if $programname == "auditd" then ~' >> /etc/rsyslog.conf  # Discard the message after processing

##

# Expose the SSH port
EXPOSE 2222 514

# Start services
 
RUN mkdir -p /app/ssh/
COPY start.sh /app/ssh/
RUN chmod +x /app/ssh/start.sh
CMD ["/app/ssh/start.sh"]
