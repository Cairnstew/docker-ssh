# Development Container Setup

This project provides a Docker-based development environment, enabling SSH access with secure key-based authentication and GPU support. The setup includes a Dockerfile, Docker Compose configuration, and scripts to automate user and SSH key setup.

## Prerequisites

- **Docker**: Ensure Docker and Docker Compose are installed on your system.
- **SSH Keys**: Generate an SSH key pair (`id_rsa` or `id_ed25519`) on your client machine if you don't already have one.
- **GPU Drivers**: NVIDIA GPU drivers and the NVIDIA Container Toolkit must be installed for GPU support.

## Files Overview

- **Dockerfile**: Builds a container based on `ubuntu:22.04` with SSH server, essential tools (`git`, `sudo`, etc.), and user setup.
- **entrypoint.sh**: Configures SSH keys, user permissions, and starts the SSH server.
- **setup.sh**: Automates environment setup, including creating a `.env` file and a Docker secret for the password.
- **docker-compose.yaml**: Defines the `gym-dev` service with SSH port mapping, GPU support, and volume for project persistence.

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Cairnstew/docker-ssh.git
   cd https://github.com/Cairnstew/docker-ssh.git
   ```

2. **Run the Setup Script**

   Execute the `setup.sh` script to configure the environment:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   - The script prompts for a password for the SSH user (your system username).
   - It creates a `.env` file with the `USERNAME` variable and a `password.txt` file as a Docker secret.

3. **Add Your SSH Public Key**

   - Retrieve your SSH public key from your client machine:
     ```bash
     cat ~/.ssh/id_rsa.pub
     ```
     or, for Ed25519 keys:
     ```bash
     cat ~/.ssh/id_ed25519.pub
     ```

     For Windows:
     - PowerShell: `Get-Content $env:USERPROFILE\.ssh\id_rsa.pub`
     - Command Prompt: `type %USERPROFILE%\.ssh\id_rsa.pub`
     - Git Bash: Same as Linux commands.

   - Edit the `.env` file and add your SSH public key to the `AUTHORIZED_KEY` variable:
     ```bash
     nano .env
     ```
     Example:
     ```
     USERNAME=your-username
     AUTHORIZED_KEY="ssh-rsa AAAAB3NzaC1yc2E... your-comment"
     ```

4. **Update docker-compose.yaml**

   - Replace the placeholder `----replace-with-user----` in the `volumes` section with your username:
     ```yaml
     volumes:
       - projects:/home/your-username/projects
     ```

5. **Start the Container**

   Launch the container using Docker Compose:

   ```bash
   docker-compose -f docker-compose.yaml up -d
   ```

6. **Access the Container**

   Connect to the container via SSH:

   ```bash
   ssh -p 8999 your-username@localhost
   ```

   - The SSH server runs on port `8999`.
   - Use your private SSH key for authentication (password authentication is disabled).

## Directory Structure

- `/home/$USERNAME/projects`: Persistent volume for your project files.
- `/home/$USERNAME/.ssh`: Contains the `authorized_keys` file for SSH access.

## Security Notes

- **Password Authentication**: Disabled in the SSH configuration for enhanced security.
- **SSH Key**: Only the provided public key in the `.env` file is authorized.
- **Password Secret**: Stored securely as a Docker secret (`password.txt`).

## Troubleshooting

- **SSH Connection Issues**:
  - Ensure your SSH public key is correctly set in the `.env` file.
  - Verify the SSH port (`8999`) is not blocked by a firewall.
  - Check container logs: `docker logs gym-dev`.
- **GPU Issues**:
  - Confirm NVIDIA Container Toolkit is installed and configured.
  - Ensure `nvidia.com/gpu=all` is supported by your system.
- **Permission Errors**:
  - Verify the `USERNAME` in `.env` matches the volume path in `docker-compose.yaml`.

## Cleanup

To stop and remove the container:

```bash
docker-compose -f docker-compose.yaml down
```

To remove the Docker image:

```bash
docker rmi gym-dev
```

## Notes

- The container is configured to restart unless explicitly stopped (`restart: unless-stopped`).
- The `projects` volume persists data even if the container is removed.
- For additional tools or dependencies, modify the `Dockerfile` and rebuild the image.
