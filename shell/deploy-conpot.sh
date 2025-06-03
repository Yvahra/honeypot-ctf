
#!/bin/bash

# Script to deploy a Conpot SSH honey pot service on localhost port 22001

# --- Configuration ---
SSH_PORT=$1
SSH_USER=$2  # The user that Conpot will run as.  Often better than a general user.
CONPOT_HOME="/opt/conpot"  # Assuming you install Conpot here or use an equivalent path.  Adjust as needed.
# --- End Configuration ---

# --- Setup Checks ---

# Check if the script is run as root (required)
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root.  Try 'sudo bash $0'"
  exit 1
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed.  Please install Docker before running this script."
  exit 1
fi

# Check if Conpot Docker container exists - and remove it if you want a fresh start.
CONPOT_CONTAINER_NAME="conpot"  # Or whatever name you've given your Conpot container
if docker ps -a --filter "name=${CONPOT_CONTAINER_NAME}" | grep -q "$CONPOT_CONTAINER_NAME"; then
  echo "Conpot container '$CONPOT_CONTAINER_NAME' already exists. Stopping and removing..."
  docker stop "$CONPOT_CONTAINER_NAME"
  docker rm "$CONPOT_CONTAINER_NAME"
fi

# --- Conpot Deployment ---

echo "Deploying Conpot SSH service on localhost port $CONPOT_SSH_PORT..."

#Pull the conpot image, or make sure it's already pulled.
echo "Pulling Conpot image (if not already present)..."
docker pull honeynet/conpot:latest || echo "Failed to pull conpot, check docker installation or the repository."

# Create the Conpot user, if it doesn't exist. This improves security.
id "$CONPOT_SSH_USER" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating user '$CONPOT_SSH_USER'..."
    useradd -m -s /bin/bash "$CONPOT_SSH_USER" # -m creates the home directory, -s sets the shell.
    # Optional: set a password (for troubleshooting/console access, but NOT recommended).
    #echo "$CONPOT_SSH_USER:honeytrap" | chpasswd
    #chown -R "$CONPOT_SSH_USER" "$CONPOT_HOME" # If necessary.  Adjust if you have a different home.
else
    echo "User '$CONPOT_SSH_USER' already exists."
fi

# Prepare Docker run command
docker_run_cmd="docker run --name ${CONPOT_CONTAINER_NAME}"
docker_run_cmd+=" -d"  # Detached mode.
docker_run_cmd+=" -p ${CONPOT_SSH_PORT}:22" # Expose SSH on the specified port.
#docker_run_cmd+=" -p 80:80" # Expose HTTP if you use the Conpot UI, or add additional ports.
docker_run_cmd+=" -v /var/run/docker.sock:/var/run/docker.sock" # Required for some features in the Conpot configuration.
docker_run_cmd+=" -u $(id -u "$CONPOT_SSH_USER"):$(id -g "$CONPOT_SSH_USER")" # Runs Conpot as the conpot user.
docker_run_cmd+=" honeynet/conpot:latest" # Replace with your Conpot image tag

# Run the Conpot container
echo "Running Conpot container..."
eval "$docker_run_cmd" # Uses eval to execute a string as a command.  Requires careful handling.
# docker run -d -p 22001:22 -p 80:80 -v /var/run/docker.sock:/var/run/docker.sock honeynet/conpot:latest

# Optional: Add your configuration file (e.g. /opt/conpot/conpot.cfg). Requires editing docker_run_cmd to add `-v /path/to/your/conpot.cfg:/opt/conpot/conpot.cfg`

echo "Conpot SSH service deployed.  Access via: ssh -p $CONPOT_SSH_PORT user@localhost"
echo "Remember to configure Conpot (e.g., by mounting your custom configuration files)."
echo "Logs can be viewed with: docker logs $CONPOT_CONTAINER_NAME"
