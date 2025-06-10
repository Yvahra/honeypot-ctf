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
COPY /app/ssh/flag.txt /home/root/

# Expose the SSH port
EXPOSE 2222

# Configure SSH
CMD ["/usr/sbin/sshd", "-D"]  # Start the SSH daemon in the foreground

# Optional:  Add a startup script (useful if you need to do other setup)
# RUN echo '#!/bin/bash\n/usr/sbin/sshd -D' > /start.sh
# RUN chmod +x /start.sh
# CMD ["/start.sh"]
