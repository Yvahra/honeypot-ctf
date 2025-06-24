# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
WORKDIR /app

# INSTALL PACKAGES
RUN apk add --no-cache git \
        python3 py3-pip \
        openssh \
        util-linux
        #openrc

# COPY FILES
COPY . .

ARG SSH_USER='m95dupont'
ARG SSH_PASS='myP@ssword!'
ARG FLAG="ECW{H0n3y_pr0of_pl@yer}"

# Define jail directory
ENV JAIL_DIR /jail
RUN mkdir -p ${JAIL_DIR}

# %%
# USERS
# %%

RUN adduser -D ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
RUN mkdir -p ${JAIL_DIR}/home/${USER}

# RUN git clone https://github.com/cowrie/cowrie.git


# %%
# SSH CONF
# %%
RUN mkdir -p /run/sshd

#Password login - NOT RECOMENDED
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config # For password login

# Create required folder and start ssh server.
RUN mkdir -p /home/${SSH_USER}/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
RUN sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
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

COPY dind/start.sh /app/dind/start.sh
RUN chmod +x /app/dind/start.sh

# Expose SSH Port
EXPOSE 22

# Run the build and run script, and then the log analyzer in the background
RUN echo ${FLAG} > /app/ssh/flag.txt
CMD ["/app/dind/start.sh"]
