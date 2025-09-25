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
PROJECT_DIR="/home/$USERNAME/projects"
mkdir -p "$SSH_DIR"
mkdir -p "$PROJECT_DIR"
echo "$AUTHORIZED_KEY" > "$SSH_DIR/authorized_keys"


chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
chown - R "$USERNAME:$USERNAME" "$PROJECT_DIR"
chmod 700 "$SSH_DIR"
chmod 700 "$PROJECT_DIR"
chmod 600 "$SSH_DIR/authorized_keys"

echo "SSH key for user '$USERNAME' has been set up."
echo "SSH Key: '$AUTHORIZED_KEY'"

ssh-keygen -A

echo "[entry.sh] Starting SSH server..."
/usr/sbin/sshd -D

