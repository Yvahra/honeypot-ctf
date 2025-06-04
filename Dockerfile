FROM ubuntu:latest

# --- Configuration ---
ARG SSH_PORT=22
ARG SSH_USER=player
ARG SSH_GROUP=players
ARG SSH_PASSWORD=iwanttheflag
# --- End Configuration ---

# --- Install and Configure SSH ---

# Update and install SSH and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    && \
    rm -rf /var/lib/apt/lists/*

# Create the SSH user and group
RUN groupadd -f "$SSH_GROUP"
RUN useradd -m -g "$SSH_GROUP" -s /bin/bash "$SSH_USER"

# Set the user's password (REQUIRED for password auth)
RUN echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

# Create .ssh directory (Not strictly needed but good practice)
RUN mkdir -p "/home/${SSH_USER}/.ssh"
RUN chown -R "$SSH_USER":"$SSH_GROUP" "/home/${SSH_USER}/.ssh"
RUN chmod 700 "/home/${SSH_USER}/.ssh"

# Configure SSH
RUN sed -i "s/#Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
RUN sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/g" /etc/ssh/sshd_config # Listen on localhost
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config # Prevent root login.
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config  # Enable Password Auth
RUN sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication no/g" /etc/ssh/sshd_config  # Disable key auth
# Ensure PasswordAuthentication is enabled and PubkeyAuthentication is disabled
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config

# Optional: Limit access (Highly Recommended!)
# RUN echo "AllowUsers $SSH_USER" >> /etc/ssh/sshd_config

# Configure SSH to start automatically
RUN mkdir -p /var/run/sshd
RUN echo "export LC_ALL=C" >> /root/.bashrc # Fix locale issues

# Expose the SSH port (not strictly necessary, but good practice)
EXPOSE ${SSH_PORT}

# Generate SSH host keys (if they don't exist)
RUN ssh-keygen -A

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]
