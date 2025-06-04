# Use an existing Python base image
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required by Kippo
RUN apt-get update && apt-get install -y \
    git \
    python3-dev \
    libffi-dev \
    libssl-dev \
    build-essential \
    tcpdump \
    tshark \
    && rm -rf /var/lib/apt/lists/*

# Clone the Kippo repository
RUN git clone https://github.com/desaster/kippo.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy kippo.cfg (you'll need to create this file)
COPY kippo.cfg /app/kippo.cfg

# Optionally, copy other configuration files if you've customized them
# For example:
# COPY kippo.auth /app/kippo.auth
# COPY honeyfs.pickle /app/honeyfs.pickle

# Expose the SSH port (default is 2222)
EXPOSE 2222

# Set environment variables (optional, but good practice)
ENV HONEYPOT_USER=kippo
ENV HONEYPOT_PASS=kippo

# Create a user for Kippo (security best practice)
RUN adduser --disabled-password --gecos "" ${HONEYPOT_USER}

# Set permissions for the honeypot user
RUN chown -R ${HONEYPOT_USER}:${HONEYPOT_USER} /app

# Switch to the honeypot user
USER ${HONEYPOT_USER}

# Start Kippo
CMD ["python3", "start.py"]
