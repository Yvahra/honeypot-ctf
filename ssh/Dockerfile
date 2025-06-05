# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Create a non-root user (Highly Recommended for Security)
ARG SSH_USER 
ARG SSH_PASS  
ARG SSH_PORT
RUN useradd -m -s /bin/bash ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd  # **WARNING:  Never hardcode passwords in production!**
# RUN usermod -aG sudo ${SSH_USER}  # Add user to the sudo group

# SSH Configuration
RUN mkdir /var/run/sshd

# Configure SSH:  Allow password authentication (for example purposes, but not recommended)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config  # Disable root login
RUN sed -i 's/#Port 22/Port ${SSH_PORT}/g' /etc/ssh/sshd_config # Port settings.
# Optionally, use a specific port
#RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config  # Change the SSH port if needed

# SSH key configuration (Recommended for Production):
# Instead of password authentication, use SSH keys.  First, uncomment and modify this block.
# ARG SSH_PUB_KEY  # Define an argument to pass the public key at build time
# RUN mkdir -p /home/${SSH_USER}/.ssh
# RUN echo "${SSH_PUB_KEY}" >> /home/${SSH_USER}/.ssh/authorized_keys
# RUN chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh
# RUN chmod 700 /home/${SSH_USER}/.ssh
# RUN chmod 600 /home/${SSH_USER}/.ssh/authorized_keys

# Start SSHD as an entrypoint
# Set the shell
ENV SHELL /bin/bash

# Expose the SSH port
EXPOSE 22

# Configure SSH
CMD ["/usr/sbin/sshd", "-D"]  # Start the SSH daemon in the foreground

# Optional:  Add a startup script (useful if you need to do other setup)
# RUN echo '#!/bin/bash\n/usr/sbin/sshd -D' > /start.sh
# RUN chmod +x /start.sh
# CMD ["/start.sh"]
