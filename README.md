# T3rn Multi Wallet Executor Transaction Validator Setup

This repository provides a `setup.sh` script to automate the setup of T3rn executor instances using Docker.

## Prerequisites

Before running the setup script, ensure you have the following prerequisites:

1. **A Unix-based operating system** (Linux or macOS is preferred)
2. **`wget`** - for downloading the setup script
3. **`chmod`** - for changing file permissions
4. **`bash`** - the script is written in Bash
5. **Basic understanding of Docker** - the script will install Docker if it's not already present

## Create `private_keys.txt` 
Before running the `setup.sh` script, you need to create a `private_keys.txt` file in the same directory as the script. This file should contain the private keys, one per line.

## Setup Instructions

1. **Download the `setup.sh` script**

   Use `wget` to download the `setup.sh` script from the repository:

   ```bash
   wget https://raw.githubusercontent.com/ade1256/t3rn-executor-transaction-validator/main/setup.sh

2.  **Make the script executable**
    
    Change the file permissions to make the script executable:
    
    chmod +x setup.sh
    
3.  **Run the `setup.sh` script**
    
    Execute the script to start the setup process:
    
    `./setup.sh` 
    
    This script will:
    
    -   Install Docker if it is not already installed
    -   Download and unpack the T3rn executor binary
    -   Create a Docker image using a Dockerfile
    -   Start Docker containers for each private key listed in `private_keys.txt`

## Docker Management

After running the `setup.sh` script, you can use the following Docker commands to manage your containers:

1.  **List Running Containers**
    
    `docker ps` 
    
2.  **View Logs**
    
    Replace `<container_name>` with the name of the Docker container you want to view logs for:
    
    `docker logs <container_name>` 
    
3.  **Stop a Running Container**
    
    Replace `<container_name>` with the name of the Docker container you want to stop:
    
    `docker stop <container_name>` 
    
4.  **Remove a Container**
    
    Replace `<container_name>` with the name of the Docker container you want to remove:
    
    `docker rm <container_name>` 
    
5.  **Remove an Image**
    
    Replace `<image_name>` with the name of the Docker image you want to remove:

    `docker rmi <image_name>` 
    

## Additional Information

For more details on Docker commands and usage, refer to the official Docker documentation.