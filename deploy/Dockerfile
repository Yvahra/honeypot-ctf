# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
WORKDIR /app

# INSTALL PACKAGES
RUN apk add --no-cache bash \
        python3 py3-pip \
        openssh \
        util-linux \ 
        coreutils \
        nmap

# COPY FILES
COPY ./dind ./dind
COPY ./ssh ./ssh
COPY ./config ./config

ARG SSH_USER='nobody1'
ARG SSH_PASS='password'

# Unique ID
RUN bash -c 'uuidgen > /app/dind/.container_id'

# Define jail directory
ENV JAIL_DIR /jail
RUN mkdir -p ${JAIL_DIR}


# %%
# USERS
# %%

RUN adduser -D ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
RUN mkdir -p ${JAIL_DIR}/home/${USER}


# %%
# SSH CONF
# %%

RUN mkdir -p /run/sshd

#Password login - NOT RECOMENDED
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config # For password login

# Create required folder and start ssh server.
RUN mkdir -p /home/${SSH_USER}/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
RUN sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

RUN ssh-keygen -A

# %%
# JAIL
# %%

# Copy necessary binaries and libraries into the jail (minimal set for basic commands)
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/lib/x86_64-linux-gnu
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/usr/lib/
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/usr/bin/
RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/etc/
#RUN mkdir -p ${JAIL_DIR}/bin ${JAIL_DIR}/dev/
RUN cp /bin/sh ${JAIL_DIR}/bin/
RUN cp /bin/ls ${JAIL_DIR}/bin/
RUN cp /bin/pwd ${JAIL_DIR}/bin/
RUN cp /usr/lib/libcrypto.so.3 ${JAIL_DIR}/usr/lib/
RUN cp /usr/lib/libz.so.1 ${JAIL_DIR}/usr/lib/
RUN cp /lib/libc.musl-x86_64.so.1 ${JAIL_DIR}/usr/lib/
RUN cp /lib/ld-musl-x86_64.so.1 ${JAIL_DIR}/lib/
RUN cp /usr/bin/ssh ${JAIL_DIR}/usr/bin/
RUN getent passwd > ${JAIL_DIR}/etc/passwd
RUN getent group > ${JAIL_DIR}/etc/group
# RUN cp /dev/tty ${JAIL_DIR}/dev/

# Create directories and files needed by the user
RUN mkdir -p ${JAIL_DIR}/home/${USER}
# RUN chown ${USER}:${USER} ${JAIL_DIR}/home/${USER}

# Create /dev inside the jail (for tty/terminal)
RUN mkdir -p ${JAIL_DIR}/dev
RUN mknod -m 666 ${JAIL_DIR}/dev/null c 1 3
RUN mknod -m 666 ${JAIL_DIR}/dev/tty c 5 0
# Add minimal device to the jail

RUN echo "Host 10.0.0.*" >> /etc/ssh/ssh_config && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config && \
    echo "    GlobalKnownHostsFile /dev/null" >> /etc/ssh/ssh_config

# Chroot configuration
RUN echo "Match User ${SSH_USER}" >> /etc/ssh/sshd_config
RUN echo "    ChrootDirectory ${JAIL_DIR}" >> /etc/ssh/sshd_config



# RUN echo "Match all" >> /etc/ssh/sshd_config


# %%
# LOGS
# %%

RUN mkdir /logs

# %%
# START
# %%

RUN chmod +x /app/dind/start.sh

# Expose SSH Port
EXPOSE 22

# Run the build and run script, and then the log analyzer in the background
CMD ["/app/dind/start.sh"]
