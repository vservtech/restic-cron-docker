#!/bin/sh
set -eu

LOG_PREFIX="ENTRYPOINT SCRIPT"

# 1) Resolve desired UID/GID
# Pass the env vars HOST_UID/HOST_GID to the container, BUT DO NOT run the container with the specified user! 
# aka no "user: ${HOST_UID}:${HOST_GID}" in compose.yaml
# This script may need to create the user and group inside the container and has to be root for that. 
# Afterwards it drops permissions to the desired user/group.
# Otherwise fall back to current process uid/gid inside the container (mostly root).
DESIRED_UID="${HOST_UID:-$(id -u)}"
DESIRED_GID="${HOST_GID:-$(id -g)}"
DESIRED_USER="${HOST_USER:-appuser}"
DESIRED_GROUP="${HOST_GROUP:-appgroup}"

echo "${LOG_PREFIX}: Running with UID: ${DESIRED_UID}"
echo "${LOG_PREFIX}: Running with GID: ${DESIRED_GID}"
echo "${LOG_PREFIX}: Running with USER: ${DESIRED_USER}"
echo "${LOG_PREFIX}: Running with GROUP: ${DESIRED_GROUP}"

# 2) Ensure group exists inside the container for DESIRED_GID
if ! getent group "${DESIRED_GID}" >/dev/null 2>&1 && \
   ! getent group "${DESIRED_GROUP}" >/dev/null 2>&1; then
  if ! addgroup -g "${DESIRED_GID}" "${DESIRED_GROUP}"; then
    echo "${LOG_PREFIX}: ERROR: addgroup failed for GID ${DESIRED_GID} and GROUP ${DESIRED_GROUP}" >&2
    exit 1
  fi
fi

# Resolve group name (by gid first; fallback to appgroup)
GROUP_NAME="$(getent group "${DESIRED_GID}" | cut -d: -f1 || true)"
[ -z "${GROUP_NAME}" ] && GROUP_NAME="${DESIRED_GROUP}"

# 3) Ensure user exists inside the container for DESIRED_UID
if ! getent passwd "${DESIRED_UID}" >/dev/null 2>&1 && \
   ! getent passwd "${DESIRED_USER}" >/dev/null 2>&1; then
  if ! adduser -D -u "${DESIRED_UID}" -G "${GROUP_NAME}" "${DESIRED_USER}"; then
    echo "${LOG_PREFIX}: ERROR: adduser failed for UID ${DESIRED_UID} and USER ${DESIRED_USER}" >&2
    exit 1
  fi
fi  

# Resolve user name (by uid first; fallback)
USER_NAME="$(getent passwd "${DESIRED_UID}" | cut -d: -f1 || true)"
[ -z "${USER_NAME}" ] && USER_NAME="${DESIRED_USER}"

# 4) Set up home directory and SSH
# Determine home directory path (root uses /root, others use /home/<username>)
if [ "${DESIRED_UID}" = "0" ]; then
  USER_HOME="/root"
else
  USER_HOME="/home/${USER_NAME}"
fi

echo "${LOG_PREFIX}: Setting up HOME: ${USER_HOME}"

# Create home directory if it doesn't exist
if [ ! -d "${USER_HOME}" ]; then
  mkdir -p "${USER_HOME}"
  chown "${USER_NAME}:${GROUP_NAME}" "${USER_HOME}"
  echo "${LOG_PREFIX}: Created home directory: ${USER_HOME}"
fi

# Create .ssh directory if it doesn't exist (with secure permissions)
# This allows users to mount SSH keys/config into the container
SSH_DIR="${USER_HOME}/.ssh"
if [ ! -d "${SSH_DIR}" ]; then
  mkdir -p "${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  chown "${USER_NAME}:${GROUP_NAME}" "${SSH_DIR}"
  echo "${LOG_PREFIX}: Created SSH directory: ${SSH_DIR}"
else
  # Ensure correct ownership even if directory was mounted
  chown "${USER_NAME}:${GROUP_NAME}" "${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  echo "${LOG_PREFIX}: SSH directory exists: ${SSH_DIR} (ensured ownership and permissions)"
fi

# Export HOME so it's available to all child processes (including supercronic jobs)
export HOME="${USER_HOME}"

# 5) Optionally chown working directory (disabled by default to avoid breaking mounted scripts)
# Set CHOWN_WORKDIR=true if scripts are created with different ownership and need to be fixed
CHOWN_WORKDIR="${CHOWN_WORKDIR:-false}"
if [ "${CHOWN_WORKDIR}" = "true" ] && [ -d /opt/cron ]; then
  echo "${LOG_PREFIX}: CHOWN_WORKDIR=true, changing ownership of /opt/cron to ${USER_NAME}:${GROUP_NAME}"
  chown -R "${USER_NAME}:${GROUP_NAME}" /opt/cron
else
  echo "${LOG_PREFIX}: CHOWN_WORKDIR=${CHOWN_WORKDIR}, skipping ownership change of /opt/cron"
fi

echo "${LOG_PREFIX}: Main command: $*"

# 6) If already correct uid/gid, just exec
if [ "$(id -u)" = "${DESIRED_UID}" ] && [ "$(id -g)" = "${DESIRED_GID}" ]; then

  # Run prestart script
  if [ -x /usr/local/bin/prestart ]; then
    echo "${LOG_PREFIX}: Running prestart script..."
    /usr/local/bin/prestart
  fi

  # Run main script
  exec "$@"
fi

# 7) Exec as that user (drop privileges via su-exec)
# Run prestart script as the desired user
if [ -x /usr/local/bin/prestart ]; then
  echo "${LOG_PREFIX}: Running prestart script..."
  su-exec "${USER_NAME}:${GROUP_NAME}" /usr/local/bin/prestart
fi
# Run main script as the desired user
exec su-exec "${USER_NAME}:${GROUP_NAME}" "$@"
