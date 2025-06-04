# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
RUN mkdir -p app/
WORKDIR /app

# Install Git (required for cloning repos)
RUN apk add --no-cache git

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Copy the Dockerfiles and other relevant files
COPY . /app

# Install Python dependencies for the analyzer
# RUN pip3 install --no-cache-dir -r analyzer_requirements.txt

# Make the scripts executable
# RUN chmod +x /scripts/build_and_run.sh /scripts/log_analyzer.py

# Run the build and run script, and then the log analyzer in the background
# CMD ["/scripts/build_and_run.sh"]
