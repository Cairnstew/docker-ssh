#!/bin/bash
set -e


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

# Permissions
chown -R "$USERNAME:$USERNAME" "$SSH_DIR" "$PROJECT_DIR"
chmod 700 "$SSH_DIR" "$PROJECT_DIR"
chmod 600 "$SSH_DIR/authorized_keys"

echo "SSH key for user '$USERNAME' has been set up."
echo "SSH Key: '$AUTHORIZED_KEY'"

ssh-keygen -A

sudo -u "$USERNAME" bash -c "(
  cd ${PROJECT_DIR} || exit
  uv venv --seed --python 3.12
  uv pip install comfy-cli
  uv run comfy --skip-prompt --workspace=${PROJECT_DIR}/ComfyUI install --nvidia
  git clone https://github.com/Chaoses-Ib/ComfyScript.git ${PROJECT_DIR}/ComfyUI/custom_nodes/ComfyScript
  uv pip install -e \"./ComfyUI/custom_nodes/ComfyScript[default]\"
  uv pip install ipykernel
)"

echo "[entry.sh] Starting SSH server..."
/usr/sbin/sshd -D
