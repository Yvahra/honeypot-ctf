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

# Copy the Dockerfiles and other relevant files
COPY . .

# Create a dedicated user (replace 'myuser' with your desired username and password)
ARG SSH_USER
ARG SSH_PASS
RUN adduser -D ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd



# Create the chroot directory
RUN mkdir -p /home/player/jail

# Copy essential binaries and libraries to the chroot directory
# You may need to adjust this list based on the commands you want to allow
# For example, if you want the player to use python inside their shell:
#RUN cp /usr/bin/python3 /home/player/jail/
#RUN cp /lib/ld-linux-x86-64.so.2 /home/player/jail/
#RUN cp /bin/sh /home/player/jail
#RUN cp /bin/pwd /home/player/jail
#RUN cp /bin/cat /home/player/jail
#RUN cp /bin/echo /home/player/jail
#RUN cp /bin/whoami /home/player/jail
#RUN cp /bin/date /home/player/jail
#RUN cp /bin/uname /home/player/jail
RUN cp /bin/sh /home/player/jail # For basic shell functionality
#RUN cp /bin/mkdir /home/player/jail # create dir

# Create a home directory inside the jail (optional)
RUN mkdir -p /home/player/jail/home/${SSH_USER}
RUN chown -R ${SSH_USER}:${SSH_USER} /home/player/jail/home/${SSH_USER}

# Copy start to player
RUN cp /app/start.sh /home/player/jail

# Create the chroot script
RUN echo "#!/bin/sh\nchroot /home/player/jail /bin/sh" > /chroot_start.sh

# Copy the chroot Script
RUN cp /chroot_start.sh /usr/bin

# Allow chroot_start.sh to execute.
RUN chmod +x /usr/bin/chroot_start.sh

# Copy the program to the main
RUN cp /usr/bin/chroot_start.sh /usr/local/bin
RUN chmod +x /usr/local/bin/chroot_start.sh

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


#Add the ForceCommands and Allow TCP, make the chroot

RUN sed -i '$a ForceCommand /usr/local/bin/chroot_start.sh' /etc/ssh/sshd_config
RUN sed -i '$a AllowTcpForwarding no' /etc/ssh/sshd_config # This is generally a good security practice
RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

# SSH Configuration

RUN ssh-keygen -A
#RUN chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh/


# Expose SSH Port
EXPOSE 22

# Startup script
#RUN echo "#!/bin/sh\n/usr/sbin/sshd -D" > /start.sh
RUN chmod +x /app/start.sh

# Run the build and run script, and then the log analyzer in the background
CMD ["/app/start.sh"]
