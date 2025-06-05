# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
WORKDIR /app

# Install Git (required for cloning repos)
RUN apk add --no-cache git

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Install OpenSSH server and utilities
RUN apk add --no-cache openssh

# Create a dedicated user (replace 'myuser' with your desired username and password)
ARG SSH_USER=player
ARG SSH_PASS=iwanttheflag
RUN adduser -D ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd

# SSH Configuration
RUN mkdir -p /run/sshd

#Password login - NOT RECOMENDED
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config # For password login

# Create required folder and start ssh server.
RUN mkdir -p /home/${SSH_USER}/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# Add user to SSHD

# SSH Configuration
#Expose a public key.
#RUN echo "${SSH_PUB_KEY}" > /home/${SSH_USER}/.ssh/authorized_keys && \
#  chmod 600 /home/${SSH_USER}/.ssh/authorized_keys
#RUN chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh/

# SSH Configuration

RUN ssh-keygen -A
#RUN chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh/

# Copy the Dockerfiles and other relevant files
COPY . .

# Expose SSH Port
EXPOSE 22

# Startup script
RUN echo "#!/bin/sh\n/usr/sbin/sshd -D" > /start.sh
RUN chmod +x /start.sh

# Run the build and run script, and then the log analyzer in the background
CMD ["/start.sh"]
