# Use an existing Python base image
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /cowrie

# Install system dependencies required by Cowrie
RUN apt-get update && apt-get install -y \
    git \
    python3-dev \
    libffi-dev \
    libssl-dev \
    build-essential \
    python3-virtualenv \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Clone the Cowrie repository
RUN git clone https://github.com/cowrie/cowrie.git .

# Create a virtual environment
RUN virtualenv -p python3 .env
ENV VIRTUAL_ENV=/cowrie/.env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy cowrie.cfg (you'll need to create this file)
COPY cowrie.cfg /cowrie/cowrie.cfg

# Copy user-mapping.txt if you're using it
# COPY user-mapping.txt /cowrie/user-mapping.txt

# Expose the SSH port (default is 2222, but configurable)
EXPOSE 2222

# Set environment variables (optional, but good practice)
ENV HONEYPOT_USER=cowrie
ENV HONEYPOT_PASS=cowrie

# Create a user for Cowrie (security best practice)
RUN adduser --disabled-password --gecos "" ${HONEYPOT_USER}

# Set permissions for the honeypot user
RUN chown -R ${HONEYPOT_USER}:${HONEYPOT_USER} /cowrie

# Switch to the honeypot user
USER ${HONEYPOT_USER}

# Start Cowrie
CMD ["./bin/cowrie", "start"]
