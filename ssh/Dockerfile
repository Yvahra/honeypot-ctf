# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        bash \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Create a non-root user (Highly Recommended for Security)
ARG SSH_USER='ot-user'
ARG SSH_PASS='p@ssword'
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
# Configure Bash History (Larger and Persistent)
RUN echo 'HISTSIZE=10000' >> /etc/bash.bashrc
RUN echo 'HISTFILESIZE=20000' >> /etc/bash.bashrc
RUN echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /etc/bash.bashrc
RUN echo 'shopt -s histappend' >> /etc/bash.bashrc
RUN echo 'shopt -s checkwinsize' >> /etc/bash.bashrc
ENV HISTFILE=/root/.bash_history

# Configure rsyslog to forward logs to the DinD container
# Get the DinD container IP address at runtime.  Use Docker network to resolve by name.

##

# Expose the SSH port
EXPOSE 2222

# Start services
 
RUN mkdir -p /app/ssh/
COPY start.sh /app/ssh/
RUN chmod +x /app/ssh/start.sh
CMD ["/app/ssh/start.sh"]
