#!/bin/bash

# Script to build (if needed) and run the dind-analyzer container

# Check if the image exists
if docker images -q honeypot-challenge > /dev/null 2>&1; then
  echo "honeypot-challenge image exists."
else
  echo "honeypot-challenge image does not exist. Building..."
  docker build -t honeypot-challenge .  # Assumes Dockerfile is in the current directory
  if [ $? -ne 0 ]; then
    echo "Error building honeypot-challenge image. Exiting."
    exit 1
  fi
  echo "honeypot-challenge image built successfully."
fi


# Stop and remove any existing container (optional but useful)
if docker ps -aq --filter "name=honeypot-challenge-container" | grep -q .; then
  echo "Stopping and removing existing dind-analyzer-container..."
  docker stop honeypot-challenge-container
  docker rm honeypot-challenger-container
fi

# Run the container, giving it a name
echo "Running dind-analyzer container..."
docker run --privileged -d -v /var/run/docker.sock:/var/run/docker.sock --name honeypot-challenge-container honeypot-challenge

if [ $? -ne 0 ]; then
  echo "Error running dind-analyzer container. Check the logs."
  exit 1
fi

echo "honeypot-challengecontainer is running.  ID: $(docker ps -aq --filter "name=honeypot-challenge-container")"
echo "You can view the logs with: docker logs honeypot-challenge-container"

exit 0
