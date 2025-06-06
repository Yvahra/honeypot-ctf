# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
WORKDIR /app

# Install Git (required for cloning repos)
RUN apk add --no-cache git

# Install necessary tools
#RUN apk add openssh-server && \
#    bash && \
#    && rm -rf /var/lib/apt/lists/*


# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Install OpenSSH server and utilities
RUN apk add --no-cache openssh

# Copy the Dockerfiles and other relevant files
COPY . .

# Create a dedicated user (replace 'myuser' with your desired username and password)
ARG SSH_USER
ARG SSH_PASS

# Define jail directory
ENV JAIL_DIR /jail
RUN mkdir -p ${JAIL_DIR}

RUN adduser -D ${SSH_USER}
#RUN groupadd ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
#RUN chown ${USER}:${USER} ${JAIL_DIR}
RUN mkdir -p ${JAIL_DIR}/home/${USER}
#RUN chown ${USER}:${USER} ${JAIL_DIR}/home/${USER}

# RUN git clone https://github.com/cowrie/cowrie.git


# Allow chroot_start.sh to execute.
#COPY dind/only /usr/local/bin/only
#RUN chmod +x /usr/local/bin/only


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

#RUN sed -i '$a ForceCommand only ssh' /etc/ssh/sshd_config
#RUN sed -i '$a AllowTcpForwarding no' /etc/ssh/sshd_config # This is generally a good security practice
#RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

# SSH Configuration

RUN ssh-keygen -A


# Copy necessary binaries and libraries into the jail (minimal set for basic commands)
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/lib/x86_64-linux-gnu
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/usr/lib/
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/usr/bin/
RUN cp /bin/sh ${JAIL_DIR}/bin/
RUN cp /bin/ls ${JAIL_DIR}/bin/
RUN cp /bin/pwd ${JAIL_DIR}/bin/
RUN cp /usr/lib/libcrypto.so.3 ${JAIL_DIR}/usr/lib/
RUN cp /usr/lib/libz.so.1 ${JAIL_DIR}/usr/lib/
RUN cp /lib/libc.musl-x86_64.so.1 ${JAIL_DIR}/usr/lib/
RUN cp /lib/ld-musl-x86_64.so.1 ${JAIL_DIR}/lib/
RUN cp /lib/bin/ssh ${JAIL_DIR}/usr/bin/

# Create directories and files needed by the user
RUN mkdir -p ${JAIL_DIR}/home/${USER}
# RUN chown ${USER}:${USER} ${JAIL_DIR}/home/${USER}

# Create /dev inside the jail (for tty/terminal)
RUN mkdir -p ${JAIL_DIR}/dev
RUN mknod -m 666 ${JAIL_DIR}/dev/null c 1 3
RUN mknod -m 600 ${JAIL_DIR}/dev/tty c 5 0
# Add minimal device to the jail

# Chroot configuration
#RUN echo "Match User ${USER}" >> /etc/ssh/sshd_config
RUN echo "ChrootDirectory ${JAIL_DIR}" >> /etc/ssh/sshd_config
#RUN echo "Match all" >> /etc/ssh/sshd_config

#RUN chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh/

# Create a custom Docker network with a subnet
# RUN docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 mynetwork

# Define environment variables
#ENV CHILD_IMAGE my-child-container
#ENV CHILD_CONTAINER_NAME child-container-1
#ENV CHILD_IP_ADDRESS 172.20.0.10  # Static IP for child-container-1
#ENV CHILD_SSH_PORT 22

# Expose SSH Port
EXPOSE 22

# Startup script
#RUN echo "#!/bin/sh\n/usr/sbin/sshd -D" > /start.sh
RUN chmod +x /app/dind/start.sh

# Run the build and run script, and then the log analyzer in the background
CMD ["/app/dind/start.sh"]
