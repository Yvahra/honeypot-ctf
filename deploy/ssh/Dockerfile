# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        python3 \
        sudo \
        bash \
        build-essential \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

ARG FLAG 
ARG SSH_TYPE
ARG PASS

# Expose the SSH port
EXPOSE 2222

# Start services
 
RUN mkdir -p /app/ssh/

RUN echo "$FLAG" > /app/flag
RUN echo "$SSH_TYPE" > /app/ssh_type
RUN echo "$PASS" > /app/pass

COPY start.sh /app/ssh/
#COPY analyze /bin/
COPY banners/ /app/ssh/banners/
RUN chmod +x /app/ssh/start.sh
ENTRYPOINT ["/app/ssh/start.sh"]
