# Use an existing Python base image
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required by Conpot
RUN apt-get update && apt-get install -y \
    git \
    python3-dev \
    libffi-dev \
    libssl-dev \
    build-essential \
    libsndfile1-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the Conpot repository
RUN git clone https://github.com/conpot/conpot.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Conpot configuration (you'll need to create this file)
COPY conpot.cfg /app/conpot.cfg

# Optionally, copy other configuration files if you've customized them
# For example:
# COPY configs/modbus.json /app/configs/modbus.json

# Expose the relevant ports (Modbus, HTTP, etc.)
EXPOSE 502 8080 2000/tcp 2000/udp

# Set environment variables (optional) - customize to your needs
ENV CONPOT_USER=conpot
ENV CONPOT_PASS=conpot

# Create a user for Conpot (security best practice)
RUN adduser --disabled-password --gecos "" ${CONPOT_USER}

# Set permissions for the honeypot user
RUN chown -R ${CONPOT_USER}:${CONPOT_USER} /app

# Switch to the honeypot user
USER ${CONPOT_USER}

# Start Conpot
CMD ["python3", "conpot.py", "-c", "/app/conpot.cfg"]
