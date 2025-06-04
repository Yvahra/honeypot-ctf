# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

ENV DOCKER_COMPOSE_VERSION 1.29.2

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apk add --no-cache \
	btrfs-progs \
	e2fsprogs \
	e2fsprogs-extra \
	iptables \
	xfsprogs \
	xz \
	py3-pip python3-dev libffi-dev openssl-dev gcc libc-dev rust cargo make \
	openssh \
	rsyslog \
	shadow \
#	git \
#	&& pip install --upgrade pip \
#	&& pip install -U docker-compose==${DOCKER_COMPOSE_VERSION} \
	&& rm -rf /root/.cache \
	&& chmod +x /usr/local/bin/dind \
	&& mkdir -p /root/.docker/ /root/.ssh/ \
	&& touch /root/.docker/config.json \
	&& touch /root/.ssh/authorized_keys \
	&& chmod u=rwx,g=,o= /root/.ssh #\
	#&& rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# disable password auth - a no-go in any case
RUN echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
	echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config && \  
	echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config

RUN groupadd -f "players" \
	&& useradd -m -g "players" -s /bin/bash "player"\
 	&& echo "player:iwanttopawn" | chpasswd \
	&& mkdir -p "/home/player/.ssh" \
	&& chown -R "player":"players" "/home/player/.ssh" \
	&& chmod 700 "/home/player/.ssh" \
	&& touch "/home/player/.ssh/authorized_keys" \
	&& chown "player":"players" "/home/player/.ssh/authorized_keys" \
	&& chmod 600 "/home/player/.ssh/authorized_keys" \
	&& cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bck" \
	&& echo "Port 22" >> "/etc/ssh/sshd_config" \
	&& echo "PermitRootLogin no" >> "/etc/ssh/sshd_config" \
	&& echo "PasswordAuthentication no" >> "/etc/ssh/sshd_config" \
	&& echo "PubkeyAuthentication no" >> "/etc/ssh/sshd_config" \
	&& echo "AllowUsers player" >> "/etc/ssh/sshd_config"\
	&& chmod 600 "$SSH_CONFIG" \
	&& chown root:root "$SSH_CONFIG" \
	&& systemctl restart sshd

# Set the working directory
RUN mkdir -p app/
WORKDIR /app

# Install Git (required for cloning repos)
RUN apk add --no-cache git

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Copy the Dockerfiles and other relevant files
COPY . /app
COPY ./ssh-user-keys/id_rsa /root/.ssh/authorized_keys
RUN chmod u=r,g=,o= /root/.ssh/authorized_keys 

# Update package lists
# RUN apt-get update && apt-get upgrade -y

# Install OpenSSH server and utilities
# RUN apt-get install -y openssh-server sudo

# Create a dedicated user (replace 'myuser' with your desired username)
# ARG SSH_USER=player
# ARG SSH_PASS=iwanttopawn
# RUN useradd -m -s /bin/bash ${SSH_USER}
# RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
# RUN usermod -aG sudo ${SSH_USER} # Add user to sudo group

# SSH configuration
# RUN mkdir /var/run/sshd
# RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
# RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
# RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config # Change default port

# Expose the SSH port
EXPOSE 22

# Startup script
# RUN echo "#!/bin/bash\n/usr/sbin/sshd -D" > /start.sh
# RUN chmod +x /start.sh

# Switch to the SSH user
# USER ${SSH_USER}

# Command to run when the container starts
# CMD ["/start.sh"]


# Install Python dependencies for the analyzer
# RUN pip3 install --no-cache-dir -r analyzer_requirements.txt

# Make the scripts executable
# RUN chmod +x /scripts/build_and_run.sh /scripts/log_analyzer.py

# Run the build and run script, and then the log analyzer in the background
# CMD ["/scripts/build_and_run.sh"]
