#!/bin/bash

# Script to automate SSH key setup and start the ComfyUI container

# Configuration
COMPOSE_FILE="docker-compose.yml"
USERNAME=$(whoami)  # Get current system username

# Prompt for password input
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

echo "[DONE] Setup complete."
echo "You can now run your container with: docker-compose -f $COMPOSE_FILE up -d"
echo "Make sure your docker-compose.yml references the secret 'password.txt'."
echo
echo "[INFO] To get your SSH public key, run this command on your client machine:"
echo "cat ~/.ssh/id_rsa.pub"
echo "Or if you use Ed25519 keys:"
echo "cat ~/.ssh/id_ed25519.pub"
echo
echo "[INFO] For Windows users:"
echo "  - In PowerShell, run:"
echo "      Get-Content \$env:USERPROFILE\\.ssh\\id_rsa.pub"
echo "      or"
echo "      Get-Content \$env:USERPROFILE\\.ssh\\id_ed25519.pub"
echo
echo "  - In Command Prompt, run:"
echo "      type %USERPROFILE%\\.ssh\\id_rsa.pub"
echo "      or"
echo "      type %USERPROFILE%\\.ssh\\id_ed25519.pub"
echo
echo "  - In Git Bash, run the same commands as Linux:"
echo "      cat ~/.ssh/id_rsa.pub"
echo "      cat ~/.ssh/id_ed25519.pub"
