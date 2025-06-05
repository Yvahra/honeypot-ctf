#!/usr/bin/env python3

import docker
import time
import re

# Define patterns that indicate suspicious commands (expand this list!)
suspicious_patterns = [
    r".*rm -rf \/.*",     # Attempt to delete everything
    r".*wget.*",           # Download files
    r".*curl.*",           # Download files
    r".*dd if=\/dev\/.*",  # Low-level disk access
    r".*nc -l.*",          # Start a listening netcat
    r".*python -m http\.server.*", # Start a web server
    r".*perl.*",            # Run Perl scripts
    r".*lua.*",             # Run Lua Scripts
    r".*whoami.*",         # Getting the current user
    r".*uname -a.*",        # Kernel Version Information
    r".*id.*",              # Get User IDs and Group IDs
    r".*ps aux.*",        # Process Listing
    r".*netstat -ant.*", # List Network Connections
    r".*ifconfig.*",    # Interface information
    r".*service ssh start.*",  # Attempt to start ssh service
    r".*sudo.*",           # Try to use sudo commands
    r".*su.*",             # Switch User
]

# Function to analyze logs for suspicious patterns
def analyze_logs(container, client):
    try:
        for log_line in container.logs(stream=True, follow=True, tail=0):
            log_line = log_line.decode('utf-8').strip()
            if log_line:
                for pattern in suspicious_patterns:
                    if re.search(pattern, log_line, re.IGNORECASE):
                        print(f"ALARM: Suspicious command detected in {container.name}: {log_line}")
                        # Add your alarm logic here: Send email, write to file, etc.

    except docker.errors.APIError as e:
        print(f"Error reading logs from {container.name}: {e}")
    except Exception as e:
        print(f"General Error: {e}")
# Function to get Docker client
def get_docker_client():
    return docker.from_env()
# Main function
def main():
    client = get_docker_client()

    # Get the list of containers (adjust this filter to only include honeypots if needed)
    containers = client.containers.list()

    # Start log analysis for each container
    for container in containers:
        print(f"Starting log analysis for container: {container.name}")
        analyze_logs(container, client)

    # Keep the script running
    while True:
        time.sleep(60) # Check every 60 seconds for new containers or errors.
        containers = client.containers.list()
        for container in containers:
             analyze_logs(container, client) # in case the program exits.

if __name__ == "__main__":
    main()
