#!/bin/bash

# Script to automate SSH key setup and generate docker-compose.yml

# ==========================
# User Configurable Inputs
# ==========================

# Default service/container name = current directory name
DEFAULT_NAME=$(basename "$(pwd)")

echo "Press Enter to Select Default"

read -p "[INPUT] Enter service/container name (default $DEFAULT_NAME): " SERVICE_NAME
SERVICE_NAME=${SERVICE_NAME:-$DEFAULT_NAME}
CONTAINER_NAME=$SERVICE_NAME

# SSH Port
read -p "[INPUT] Enter SSH port (default 8999): " SSH_PORT
SSH_PORT=${SSH_PORT:-8999}

# Volume name
read -p "[INPUT] Enter volume name (default projects): " VOLUME_NAME
VOLUME_NAME=${VOLUME_NAME:-projects}

# Container mount path
read -p "[INPUT] Enter container mount path (default /opt/$VOLUME_NAME): " MOUNT_PATH
MOUNT_PATH=${MOUNT_PATH:-/opt/$VOLUME_NAME}

# ==========================
# Select Build Context
# ==========================
DOCKER_BASE="./Docker"

echo "[INFO] Available build contexts in $DOCKER_BASE:"
# Show directories and root Dockerfile
OPTIONS=()
if [ -f "$DOCKER_BASE/Dockerfile" ]; then
  OPTIONS+=("Docker (default)")
fi
for dir in "$DOCKER_BASE"/*/; do
  dirname=$(basename "$dir")
  if [ -f "$dir/Dockerfile" ]; then
    OPTIONS+=("$dirname")
  fi
done

# Display menu
select choice in "${OPTIONS[@]}"; do
  if [ "$choice" == "Docker (default)" ]; then
    BUILD_CONTEXT="$DOCKER_BASE"
    break
  elif [ -n "$choice" ]; then
    BUILD_CONTEXT="$DOCKER_BASE/$choice"
    break
  else
    echo "[ERROR] Invalid choice. Try again."
  fi
done

COMPOSE_FILE="docker-compose.yml"
USERNAME=$(whoami)  # Get current system username

# ==========================
# Capture Password
# ==========================
echo "[INPUT] Enter a password for SSH user '$USERNAME':"
read -s PASSWORD
echo
echo "[INFO] Password captured."

# Create .env file for Docker Compose with username
echo "[INFO] Creating .env file with environment variables..."
cat << EOF > .env
USERNAME=$USERNAME
AUTHORIZED_KEY=""
EOF
echo "[SUCCESS] .env file created successfully."

# Create Docker secret file for the password
echo "[INFO] Creating Docker secret file for password..."
echo "$PASSWORD" > password.txt
chmod 600 password.txt
echo "[SUCCESS] Docker secret file 'password.txt' created."

# Clean up password variable from memory
unset PASSWORD

# ==========================
# Generate docker-compose.yml
# ==========================
echo "[INFO] Generating $COMPOSE_FILE ..."
cat << EOF > $COMPOSE_FILE
services:
  $SERVICE_NAME:
    secrets:
      - password
    build:
      context: $BUILD_CONTEXT
      dockerfile: Dockerfile
      args:
        - USERNAME=\${USERNAME}
    container_name: $CONTAINER_NAME
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "$SSH_PORT:22"  # SSH
    volumes:
      - $VOLUME_NAME:$MOUNT_PATH
    deploy: # GPU access
      resources:
        reservations:
          devices:
          - driver: cdi
            capabilities:
              - gpu
            device_ids:
              - nvidia.com/gpu=all

secrets:
  password:
    file: ./password.txt

volumes:
  $VOLUME_NAME:
EOF
echo "[SUCCESS] $COMPOSE_FILE generated."

# ==========================
# Final Info
# ==========================
echo "[DONE] Setup complete."
echo "You can now run your container with:"
echo "  docker-compose -f $COMPOSE_FILE up -d"
echo
echo "[INFO] Build context selected: $BUILD_CONTEXT"
echo "[INFO] Service/Container name: $SERVICE_NAME"
echo "[INFO] Volume '$VOLUME_NAME' will mount to: $MOUNT_PATH"
