#!/bin/sh
set -e

# Function to build and run a Dockerfile
build_and_run_dockerfile() {
  local dockerfile_name="$1"
  local image_name="$2"
  local port_mappings="$3"
  local env_vars="$4"

  echo "Building image from Dockerfile: $dockerfile_name"
  docker build -t "$image_name" -f "$dockerfile_name" .

  echo "Running container for image: $image_name"
  docker run -d $port_mappings $env_vars --name "$image_name" "$image_name" # Named container!
  echo "Container started."
}

# --- Build and Run Specific Dockerfiles Below ---

# Example: Build and run the Kippo Dockerfile
build_and_run_dockerfile Dockerfile.kippo kippo-honeypot "-p 2222:2222"

# Example: Build and run the Conpot Dockerfile
build_and_run_dockerfile Dockerfile.conpot conpot-honeypot "-p 502:502 -p 8080:8080 -p 2000:2000/tcp -p 2000:2000/udp"

# Example: Build and run the Cowrie Dockerfile
build_and_run_dockerfile Dockerfile.cowrie cowrie-honeypot "-p 2222:2222"

# Example: Build and run the SSH Server Dockerfile
build_and_run_dockerfile Dockerfile.ssh ssh-server "-p 2222:2222" # add -e etc.

# --- Start log analyzer script in background---
/usr/bin/python3 /scripts/log_analyzer.py &

echo "Log analyzer started in background."

# --- End ---
