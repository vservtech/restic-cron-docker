FROM python:3.13.7-alpine3.22

# Install system dependencies
RUN apk add --no-cache rsync sshpass openssh-client vim bash zsh openssl

# Install pipx and Ansible via pipx (isolated)
RUN python -m pip install --no-cache-dir pipx
RUN python -m pipx install ansible-core==2.18.9  # Pin to latest 2.18 patch for stability

# Ensure pipx binaries are in PATH (critical for Docker root user)
ENV PATH="/root/.local/bin:${PATH}"
ENV PIPX_BIN_DIR="/root/.local/bin"

# Optional: Enable shell completion (if needed for zsh/bash)
RUN pipx inject ansible-core argcomplete

# Set workdir
ENV ANSIBLE_WORKDIR="/opt/ansible-workdir"
RUN mkdir -p "${ANSIBLE_WORKDIR}"
WORKDIR "${ANSIBLE_WORKDIR}"