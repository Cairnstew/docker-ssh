# Docker SSH Server Setup

This project provides a Docker-based setup for running a secure SSH server with GPU support, designed for general development environments. It automates SSH key setup, user creation, and container configuration using Docker Compose.

## File Structure

- **`setup.sh`**: Bash script to automate SSH key setup and environment configuration. It prompts for a password, creates a `.env` file, and generates a Docker secret file (`password.txt`).
- **`docker-compose.yml`**: Defines the Docker service (`docker-ssh`), including SSH port mapping, GPU access, and volume mounts.
- **`Docker/`**:
  - **`Dockerfile`**: Base Dockerfile for the main SSH server setup, based on Ubuntu 22.04, with secure SSH configurations and user setup.
  - **`entrypoint.sh`**: Entry script for the container, sets up SSH keys, user permissions, and starts the SSH server.
- **`Docker/<specific-use-case>/`** (e.g., `Docker/Python/`):
  - Contains additional Dockerfiles and `entrypoint.sh` scripts tailored for specific use cases (e.g., Python development).
  - Each subfolder includes its own `Dockerfile` and `entrypoint.sh` for specialized configurations.

## Prerequisites

- **Docker** and **Docker Compose** installed on your system.
- An SSH public key (`~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`) from your client machine.
- For GPU support, ensure NVIDIA drivers and the NVIDIA Container Toolkit are installed (required for `cdi` driver in `docker-compose.yml`).

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Cairnstew/docker-ssh.git
   cd docker-ssh
   ```

2. **Run the Setup Script**
   - Execute the `setup.sh` script to configure the environment:
     ```bash
     chmod +x setup.sh
     ./setup.sh
     ```
   - Enter a password when prompted. This will create:
     - A `.env` file with the username.
     - A `password.txt` file as a Docker secret.

3. **Add Your SSH Public Key**
   - Retrieve your SSH public key from your client machine:
     ```bash
     # Linux/MacOS/Git Bash
     cat ~/.ssh/id_rsa.pub
     # or
     cat ~/.ssh/id_ed25519.pub
     ```
     ```powershell
     # Windows PowerShell
     Get-Content $env:USERPROFILE\.ssh\id_rsa.pub
     # or
     Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
     ```
     ```cmd
     # Windows Command Prompt
     type %USERPROFILE%\.ssh\id_rsa.pub
     # or
     type %USERPROFILE%\.ssh\id_ed25519.pub
     ```
   - Edit the `.env` file and add your SSH public key to the `AUTHORIZED_KEY` variable:
     ```bash
     nano .env
     ```
     Example:
     ```
     USERNAME=your-username
     AUTHORIZED_KEY="ssh-rsa AAAAB3NzaC1yc2E... your-key-comment"
     ```

4. **Start the Container**
   - Run the Docker Compose command to start the container:
     ```bash
     docker-compose -f docker-compose.yml up -d
     ```
   - The container (`docker-ssh`) will start with SSH exposed on port `8999` (configurable in `docker-compose.yml`).

5. **Connect to the Container**
   - Use SSH to connect to the container:
     ```bash
     ssh -p 8999 <USERNAME>@localhost
     ```
   - The password is the one you provided during the `setup.sh` execution, but SSH key authentication is preferred (PasswordAuthentication is disabled by default).

## Customizing for Specific Use Cases

- The `Docker/` directory supports modular configurations for different use cases (e.g., `Docker/Python/`).
- To use a specific configuration:
  1. Update the `build.context` in `docker-compose.yml` to point to the desired folder (e.g., `./Docker/Python`).
  2. Ensure the corresponding `Dockerfile` and `entrypoint.sh` are present in that folder.
  3. Re-run `docker-compose up -d`.

## Notes

- **Security**: The `Dockerfile` disables root login and password authentication, enforcing SSH key-based access for security.
- **GPU Support**: The `docker-compose.yml` includes GPU access via the `cdi` driver for NVIDIA GPUs. Ensure your system supports this.
- **Volumes**: The `/opt/projects` directory is mounted as a volume for persistent project data.
- **Port Configuration**: The SSH port is set to `8999` by default. Modify the `ports` section in `docker-compose.yml` if needed.

## Troubleshooting

- **SSH Connection Issues**:
  - Verify the `AUTHORIZED_KEY` in the `.env` file matches your public key.
  - Ensure the SSH port (`8999`) is not blocked by your firewall.
- **GPU Errors**:
  - Confirm NVIDIA Container Toolkit is installed and configured.
  - Check that `nvidia.com/gpu=all` is valid for your system.
- **Container Fails to Start**:
  - Check logs with `docker logs docker-ssh`.
  - Ensure `password.txt` and `.env` files are correctly set up.
