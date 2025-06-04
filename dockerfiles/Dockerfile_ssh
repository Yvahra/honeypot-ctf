FROM ubuntu:latest

# Update package lists
RUN apt-get update && apt-get upgrade -y

# Install OpenSSH server and utilities
RUN apt-get install -y openssh-server sudo

# Create a dedicated user (replace 'myuser' with your desired username)
ARG SSH_USER=myuser
ARG SSH_PASS=mypassword
RUN useradd -m -s /bin/bash ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
RUN usermod -aG sudo ${SSH_USER} # Add user to sudo group

# SSH configuration
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config # For simplicity, password auth is on.  USE KEY-BASED AUTH IN PRODUCTION
RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config # Change default port

# Expose the SSH port
EXPOSE 2222

# Startup script
RUN echo "#!/bin/bash\n/usr/sbin/sshd -D" > /start.sh
RUN chmod +x /start.sh

# Switch to the SSH user
USER ${SSH_USER}

# Command to run when the container starts
CMD ["/start.sh"]
