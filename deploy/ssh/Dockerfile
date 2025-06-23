# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        bash \
        build-essential \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

ARG SSH_TYPE=0


# Expose the SSH port
EXPOSE 2222

# Start services
 
RUN mkdir -p /app/ssh/
COPY start.sh /app/ssh/
RUN chmod +x /app/ssh/start.sh
CMD ["ls"] #"/app/ssh/start.sh", "${SSH_TYPE}"]
