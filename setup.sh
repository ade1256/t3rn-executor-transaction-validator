#!/bin/bash
# Function to print the introduction
print_intro() {
  echo "🤑 === T3rn Multi Wallet Executor ==="
  echo "💻 Developed by:"
  echo " __      _______ _____        _____           _                    _         _                 "
  echo " \ \    / /_   _|  __ \      / ____|         | |             /\   (_)       | |                "
  echo "  \ \  / /  | | | |__) |____| (___   ___  ___| |_ ___  _ __ /  \   _ _ __ __| |_ __ ___  _ __   "
  echo "   \ \/ /   | | |  ___/______\___ \ / _ \/ __| __/ _ \| '__/ /\ \ | | '__/ _\` | '__/ _ \| '_ \ "
  echo "    \  /   _| |_| |          ____) |  __/ (__| || (_) | | / ____ \| | | | (_| | | | (_) | |_) |"
  echo "     \/   |_____|_|         |_____/ \___|\___|\__\___/|_|/_/    \_\_|_|  \__,_|_|  \___/| .__/  "
  echo "                                                                                        | |    "
  echo "                                                                                        |_|    "
}

# Run the introduction function
print_intro

# Variables
DOCKERFILE="Dockerfile"
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.21.0/executor-linux-v0.21.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.21.0.tar.gz"
IMAGE_NAME="my-executor-image"
PRIVATE_KEYS_FILE="private_keys.txt"

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker

    # Verify Docker installation
    docker --version
}

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo "Docker is already installed."
fi

# Create Dockerfile
cat <<EOF > $DOCKERFILE
# Use a base image with necessary tools
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \\
    apt-get install -y curl tar

# Copy the executor binary
COPY executor /executor

# Set environment variables
ENV NODE_ENV=testnet \\
    LOG_LEVEL=debug \\
    LOG_PRETTY=false \\
    ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn

# Define the command to run the executor
ENTRYPOINT ["/executor/executor/bin/executor"]
EOF

# Download the executor binary
echo "Retrieving the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

if [ $? -ne 0 ]; then
    echo "Unable to download the Executor binary. Please check your internet connection and retry."
    exit 1
fi

# Unpack the binary
echo "Unpacking the binary..."
tar -xzvf $EXECUTOR_FILE

# Build the Docker image
echo "Building Docker image $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

# Check if private_keys.txt exists
if [ ! -f $PRIVATE_KEYS_FILE ]; then
  echo "Error: $PRIVATE_KEYS_FILE file not found!"
  exit 1
fi

# Read private keys from the file
keys=($(cat $PRIVATE_KEYS_FILE))

# Loop over the keys and start each in a separate Docker container
for i in "${!keys[@]}"; do
  key=${keys[$i]}

  echo "Starting executor with PRIVATE_KEY_LOCAL=$key..."
  docker run -d \
    -e PRIVATE_KEY_LOCAL=$key \
    -e NODE_ENV=testnet \
    -e LOG_LEVEL=debug \
    -e LOG_PRETTY=false \
    -e ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn \
    --name "executor_$key" \
    $IMAGE_NAME

  echo "Started executor with PRIVATE_KEY_LOCAL=$key in Docker container 'executor_$key'"
done

echo "All executors have been started."


# Instructions for Docker management
cat <<EOF

Docker commands to manage your containers:

1. **List Running Containers**
   To view all running Docker containers:
   \`\`\`
   docker ps
   \`\`\`

2. **View Logs**
   To view logs of a specific container (replace <container_name> with the container name or ID):
   \`\`\`
   docker logs <container_name>
   \`\`\`

3. **Remove a Container**
   To remove a specific container (replace <container_name> with the container name or ID):
   \`\`\`
   docker rm <container_name>
   \`\`\`

4. **Stop a Running Container**
   To stop a specific running container (replace <container_name> with the container name or ID):
   \`\`\`
   docker stop <container_name>
   \`\`\`

5. **Remove an Image**
   To remove a Docker image (replace <image_name> with the image name):
   \`\`\`
   docker rmi <image_name>
   \`\`\`

You can find more Docker commands and documentation on the official Docker website: https://docs.docker.com/

EOF