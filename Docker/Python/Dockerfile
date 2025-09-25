FROM ubuntu:22.04

ARG USERNAME

ENV USERNAME=${USERNAME} \
    USER_UID=1001 \
    USER_GID=1001 \
    OPT_PATH=/opt \
    USER_HOME=/home/${USERNAME}

RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
        sudo \
        openssh-server \
        libgl1-mesa-glx \
        libglib2.0-0 \
        python3 \
        python3-pip \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Set python3 as the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1


# Create group and user by name only, if they don't already exist
RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USERNAME}


# Add user to sudoers, set password, and configure SSH securely
RUN usermod -aG sudo "${USERNAME}" && \
    mkdir -p /var/run/sshd && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's|^#\?AuthorizedKeysFile .*|AuthorizedKeysFile .ssh/authorized_keys|' /etc/ssh/sshd_config || echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config && \
    grep -q '^PubkeyAcceptedAlgorithms' /etc/ssh/sshd_config || echo 'PubkeyAcceptedAlgorithms +ssh-rsa' >> /etc/ssh/sshd_config



EXPOSE 22

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

