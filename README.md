# Docker SSH Server Setup

This project provides a Docker-based setup for running a secure SSH server with GPU support, designed for general development environments. It automates SSH key setup, user creation, and container configuration using Docker Compose.

## Features

- Generates a `docker-compose.yml` file for an SSH-enabled Docker service.
- Supports GPU access using NVIDIA CDI (Container Device Interface).
- Creates a `.env` file with the username and placeholders for SSH authorized keys.
- Creates a `password.txt` secret file for the SSH user password.
- Allows selection of Docker build context from available `Dockerfile` locations.
- Configures a persistent volume for data storage.

## Prerequisites

- Docker and Docker Compose installed on the system.
- A `Docker` directory containing a `Dockerfile` or subdirectories with `Dockerfile`s for build context selection.
- NVIDIA drivers and CDI support for GPU access (if applicable).
- Bash shell environment.

## Usage

1. **Run the Script**:
   ```bash
   chmod +x script.sh
   ./script.sh
   ```

2. **Follow Prompts**:
   - **Service/Container Name**: Defaults to the current directory name.
   - **SSH Port**: Defaults to `8999`.
   - **Volume Name**: Defaults to `projects`.
   - **Container Mount Path**: Defaults to `/opt/<volume_name>`.
   - **Build Context**: Choose from available `Dockerfile` locations in the `Docker` directory or its subdirectories.
   - **SSH Password**: Enter a password for the SSH user (current system username).

3. **Output Files**:
   - `docker-compose.yml`: Docker Compose configuration for the service.
   - `.env`: Environment variables (username and placeholder for authorized keys).
   - `password.txt`: Secret file containing the SSH user password (restricted permissions).

4. **Add Your SSH Public Key**

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

5. **Start the Container**:
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```

## Generated Files

- **`.env`**:
  Contains the username and a placeholder for SSH authorized keys.
  ```env
  USERNAME=<your-username>
  AUTHORIZED_KEY=""
  ```

- **`password.txt`**:
  Stores the SSH user password securely (permissions set to `600`).

- **`docker-compose.yml`**:
  Defines the service with SSH access, GPU support, and volume mounting. Example:
  ```yaml
  services:
    <service_name>:
      secrets:
        - password
      build:
        context: ./Docker/<selected_context>
        dockerfile: Dockerfile
        args:
          - USERNAME=${USERNAME}
      container_name: <container_name>
      restart: unless-stopped
      env_file:
        - .env
      ports:
        - "<ssh_port>:22"
      volumes:
        - <volume_name>:<mount_path>
      deploy:
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
    <volume_name>:
  ```

## Notes

- The script assumes the `Docker` directory exists and contains at least one `Dockerfile` (either in the root or a subdirectory).
- The SSH password is captured securely and unset from memory after use.
- The volume specified will persist data at the chosen mount path inside the container.
- GPU support requires NVIDIA CDI and compatible hardware/drivers.
- Ensure the `Dockerfile` in the selected build context is configured to use the `USERNAME` build argument and handle the `password` secret appropriately.

## Example Workflow

1. Run the script:
   ```bash
   ./script.sh
   ```
2. Input:
   - Service name: `my-ssh-service`
   - SSH port: `8999`
   - Volume name: `mydata`
   - Mount path: `/opt/mydata`
   - Build context: Select `Docker (default)` or a subdirectory.
   - Password: Enter a secure password.
3. Run the container:
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
4. Connect via SSH:
   ```bash
   ssh <username>@localhost -p 8999
   ```

## Troubleshooting

- **No Dockerfile Found**: Ensure the `Docker` directory contains a `Dockerfile` or subdirectories with valid `Dockerfile`s.
- **Permission Issues**: Verify you have write permissions in the current directory for generating files.
- **GPU Errors**: Confirm NVIDIA CDI is installed and configured correctly.
- **SSH Connection Issues**: Check the `docker-compose.yml` port mapping and ensure the container is running (`docker ps`).