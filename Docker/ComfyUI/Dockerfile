# Defines the versions of ComfyUI, ComfyUI Manager, and PyTorch to use
ARG PYTORCH_VERSION=2.7.1-cuda12.6-cudnn9-runtime


# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
FROM pytorch/pytorch:${PYTORCH_VERSION}
ARG COMFYUI_VERSION=v0.3.40
ARG COMFYUI_MANAGER_VERSION=3.33
ARG COMFYSCRIPT_VERSION=v0.5.1

ARG USERNAME

ENV USERNAME=${USERNAME} \
    USER_UID=1001 \
    USER_GID=1001 \
    OPT_PATH=/opt \
    USER_HOME=/home/${USERNAME} \
    COMFY_PATH=/opt/comfyui \
    COMFY_CUSTOM_NODES_PATH=/opt/comfyui/custom_nodes \
    COMFY_MANAGER_PATH=/opt/comfyui-manager \
    COMFYSCRIPT_PATH=/opt/comfyscript


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


WORKDIR ${COMFY_PATH}

RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git ${COMFY_PATH} && \
    cd ${COMFY_PATH} && \
    git fetch origin ${COMFYUI_VERSION} && \
    git checkout FETCH_HEAD && \
    chown -R $COMFY_USER_UID:$COMFY_USER_GID ${COMFY_PATH}

RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git ${COMFY_MANAGER_PATH} && \
    cd ${COMFY_MANAGER_PATH} && \
    git fetch origin ${COMFYUI_MANAGER_VERSION} && \
    git checkout FETCH_HEAD && \
    chown -R $COMFY_USER_UID:$COMFY_USER_GID ${COMFY_MANAGER_PATH}

RUN git clone --depth=1 https://github.com/Chaoses-Ib/ComfyScript.git ${COMFYSCRIPT_PATH} && \
    chown -R $COMFY_USER_UID:$COMFY_USER_GID ${COMFYSCRIPT_PATH} && \
    cd ${COMFYSCRIPT_PATH} && \
    /opt/conda/bin/python -m pip install -e ".[default]"



RUN ln -s $COMFY_MANAGER_PATH $COMFY_CUSTOM_NODES_PATH/ComfyUI-Manager


RUN /opt/conda/bin/pip install \
    --requirement ${COMFY_PATH}/requirements.txt \
    --requirement ${COMFY_MANAGER_PATH}/requirements.txt

RUN /opt/conda/bin/pip install ipykernel

EXPOSE 22

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

