FROM ubuntu:latest

# Install necessary tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    docker.io \
    openssh-server \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH (Parent)
RUN mkdir -p /var/run/sshd
RUN echo 'root:YOUR_PASSWORD' | chpasswd  # CRITICAL: Change this!
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN ssh-keygen -A

# Create a custom Docker network with a subnet
RUN docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 mynetwork

# Define environment variables
ENV CHILD_IMAGE my-child-container
ENV CHILD_CONTAINER_NAME child-container-1
ENV CHILD_IP_ADDRESS 172.20.0.10  # Static IP for child-container-1
ENV CHILD_SSH_PORT 22

ENTRYPOINT ["/bin/bash"]
CMD ["-c",
    "service ssh start && sleep infinity"
]
#    docker run --name ${CHILD_CONTAINER_NAME} --net mynetwork --ip ${CHILD_IP_ADDRESS} ${CHILD_IMAGE} && \
