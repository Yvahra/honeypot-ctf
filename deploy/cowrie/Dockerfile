# Use an official Ubuntu base image
FROM ubuntu:latest

# Set noninteractive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    libssl-dev \
    libffi-dev \
    python3-dev \
    virtualenv \
    telnetd \
    unzip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for Cowrie
WORKDIR /opt/cowrie

# Clone the Cowrie repository
RUN git clone https://github.com/cowrie/cowrie.git .

# Create a virtual environment
RUN virtualenv --python=python3 .env

# Activate the virtual environment (necessary for subsequent pip commands)
ENV VIRTUAL_ENV=/opt/cowrie/.env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Cowrie dependencies using pip
RUN pip install --no-cache-dir -r requirements.txt

# Create a user for Cowrie (important for security!)
RUN useradd -m cowrie

# Change ownership of the Cowrie directory to the cowrie user
RUN chown -R cowrie:cowrie /opt/cowrie

# Copy configuration files
COPY cowrie.cfg /opt/cowrie/cowrie.cfg

# Expose SSH port (2222 is commonly used to avoid conflicts with host's SSH)
EXPOSE 2222

# Switch to the cowrie user
USER cowrie

# Start Cowrie
CMD ["./bin/cowrie", "start", "--nodaemon"]
