FROM ubuntu:latest  # Or your preferred base image

# --- Metadata ---
LABEL maintainer="Your Name"
LABEL description="Dockerfile for deploying Cowrie SSH Honeypot with custom SSH user"

# --- Configuration ---
ARG COWRIE_USER=cowrie          # User to run Cowrie
ARG COWRIE_GROUP=cowriegroup
ARG COWRIE_HOME=/home/$COWRIE_USER/cowrie
ARG COWRIE_DATA=/opt/cowrie_data  # Data location
ARG COWRIE_PORT=2222         # port number to expose.
ARG SSH_PORT=22              # The internal SSH port for Cowrie
ARG SSH_USER=sshuser             # Custom SSH user
ARG SSH_PASSWORD=mysecurepassword  # **CHANGE THIS!** Custom SSH user password
ARG UID=1000                     # User id for ssh user to ensure same as docker
ARG GID=1000                     # Group id for ssh user

# --- Install Dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-virtualenv libssl-dev libffi-dev build-essential \
    python3-openssl python3-twisted openssh-server \
    && rm -rf /var/lib/apt/lists/*

# --- Create Cowrie User and Group ---
RUN groupadd $COWRIE_GROUP
RUN useradd -m -g $COWRIE_GROUP -s /bin/bash $COWRIE_USER

# --- Create SSH User and Group ---
RUN groupadd --gid $GID sshgroup
RUN useradd -m -u $UID -g sshgroup -s /bin/bash $SSH_USER

# --- Set SSH User Password ---
RUN echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

# --- Configure SSH for Custom User ---
RUN mkdir /home/$SSH_USER/.ssh
RUN chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh
#RUN chmod 700 /home/$SSH_USER/.ssh  #redundant

# --- Allow Password Authentication (for custom user) ---
RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# --- Prevent Root Login ---
RUN sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config

# --- Create Data directory and setup permissions. ---
RUN mkdir -p $COWRIE_DATA
RUN chown -R $COWRIE_USER:$COWRIE_GROUP $COWRIE_DATA
RUN chmod 770 $COWRIE_DATA  # ensure all user has rw access to the directory.

# --- Clone Cowrie Repository and configure permissions ---
RUN git clone https://github.com/cowrie/cowrie.git $COWRIE_HOME
RUN chown -R $COWRIE_USER:$COWRIE_GROUP $COWRIE_HOME
RUN chmod +x $COWRIE_HOME/bin/cowrie

# --- Set Cowrie Home Directory as Working Directory ---
WORKDIR $COWRIE_HOME

# --- Create Virtual Environment and install dependencies ---
USER $COWRIE_USER  # Important, change user.

RUN python3 -m venv venv
RUN . venv/bin/activate
RUN pip3 install --no-cache-dir -r requirements.txt

# Configure ports.
EXPOSE $COWRIE_PORT

# Create entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --- Run Cowrie ---
CMD ["/entrypoint.sh"]
