#!/bin/bash
set -e

# Creates the directories for the models inside of the volume that is mounted from the host
echo "Creating directories for models..."
MODEL_DIRECTORIES=(
    "checkpoints"
    "clip"
    "clip_vision"
    "configs"
    "controlnet"
    "diffusers"
    "diffusion_models"
    "embeddings"
    "gligen"
    "hypernetworks"
    "loras"
    "photomaker"
    "style_models"
    "text_encoders"
    "unet"
    "upscale_models"
    "vae"
    "vae_approx"
)

if [ ! -d /opt/comfyui/models/checkpoints ]; then
  echo "Creating model directories..."
  for MODEL_DIRECTORY in "${MODEL_DIRECTORIES[@]}"; do
      mkdir -p /opt/comfyui/models/$MODEL_DIRECTORY
  done
fi
# Install requirements for custom nodes
echo "Installing requirements for custom nodes..."
for CUSTOM_NODE_DIRECTORY in /opt/comfyui/custom_nodes/*; do
    if [ "$CUSTOM_NODE_DIRECTORY" != "/opt/comfyui/custom_nodes/ComfyUI-Manager" ] && [ "$CUSTOM_NODE_DIRECTORY" != "/opt/comfyui/custom_nodes/ComfyScript" ]; then
        if [ -f "$CUSTOM_NODE_DIRECTORY/requirements.txt" ]; then
            CUSTOM_NODE_NAME=${CUSTOM_NODE_DIRECTORY##*/}
            CUSTOM_NODE_NAME=${CUSTOM_NODE_NAME//[-_]/ }
            echo "Installing requirements for $CUSTOM_NODE_NAME..."
            /opt/conda/bin/pip install --requirement "$CUSTOM_NODE_DIRECTORY/requirements.txt"
        fi
    fi
done

# Check if the 'comfy' module is installed
echo "[wrapper] Checking if 'comfy' Python package is installed..."
if /opt/conda/bin/python -c "import comfy" &> /dev/null; then
    echo "[wrapper] 'comfy' package is installed."
else
    echo "[wrapper] ERROR: 'comfy' package is NOT installed."
    # exit 1
fi

if [ -z "$AUTHORIZED_KEY" ] || [ -z "$USERNAME" ]; then
  echo "AUTHORIZED_KEY and USERNAME must be set"
  exit 1
fi

if [ -f /run/secrets/password ]; then
  PASSWORD=$(cat /run/secrets/password)
  echo "${USERNAME}:${PASSWORD}" | chpasswd
else
  echo "Password secret file not found!"
  exit 1
fi

unset PASSWORD

SSH_DIR="/home/$USERNAME/.ssh"
PROJECT_DIR="/opt/projects"
mkdir -p "$SSH_DIR"
mkdir -p "$PROJECT_DIR"
echo "$AUTHORIZED_KEY" > "$SSH_DIR/authorized_keys"


chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
chown -R "$USERNAME:$USERNAME" "$PROJECT_DIR"
chmod 700 "$SSH_DIR"
chmod 700 "$PROJECT_DIR"
chmod 600 "$SSH_DIR/authorized_keys"

echo "SSH key for user '$USERNAME' has been set up."
echo "SSH Key: '$AUTHORIZED_KEY'"

ssh-keygen -A

echo "[entry.sh] Starting SSH server..."
/usr/sbin/sshd -D &

echo "[entry.sh] Starting ComfyUI as ${COMFY_USERNAME}..."
runuser -l ${COMFY_USERNAME} -c "/opt/conda/bin/python /opt/comfyui/main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch" &

# Wait for either process to exit
wait -n


