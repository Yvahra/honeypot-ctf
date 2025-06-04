# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
RUN mkdir -p app/
WORKDIR /app

# Install Git (required for cloning repos)
RUN apk add --no-cache git

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Copy the Dockerfiles and other relevant files
COPY . /app

# Update package lists
RUN apt-get update && apt-get upgrade -y

# Install OpenSSH server and utilities
RUN apt-get install -y openssh-server sudo

# Create a dedicated user (replace 'myuser' with your desired username)
ARG SSH_USER=player
ARG SSH_PASS=iwanttopawn
RUN useradd -m -s /bin/bash ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
RUN usermod -aG sudo ${SSH_USER} # Add user to sudo group

# SSH configuration
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
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


# Install Python dependencies for the analyzer
# RUN pip3 install --no-cache-dir -r analyzer_requirements.txt

# Make the scripts executable
# RUN chmod +x /scripts/build_and_run.sh /scripts/log_analyzer.py

# Run the build and run script, and then the log analyzer in the background
# CMD ["/scripts/build_and_run.sh"]
