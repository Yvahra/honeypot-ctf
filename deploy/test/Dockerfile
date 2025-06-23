# Use the official Ubuntu base image as a parent image
FROM ubuntu:latest

# Update the package list
RUN apt-get update -y

# Upgrade existing packages (recommended for security)
RUN apt-get upgrade -y

# Install any additional packages you need here.  Examples:
# RUN apt-get install -y --no-install-recommends python3 python3-pip  # Installs Python 3
# RUN apt-get install -y --no-install-recommends nginx         # Installs Nginx web server
RUN apt-get install -y --no-install-recommends vim           # Installs vim text editor
# RUN apt-get install -y --no-install-recommends wget          # Installs wget command

# Clean up apt cache to reduce image size (best practice)
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Optional: Set a working directory (where subsequent commands will be executed)
WORKDIR /app

# Optional:  Copy application code (if you have any)
COPY ../ssh/ /app

# Optional: Expose a port (if your application needs it)
# EXPOSE 8080

# Optional: Define the command to run when the container starts
CMD ["/bin/bash"]  # Starts a bash shell
# CMD ["python3", "app.py"] # Runs a python script
