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

# 4) Ensure working directories are owned
if [ -d /opt/cron ]; then
  chown -R "${USER_NAME}:${GROUP_NAME}" /opt/cron
fi

echo "${LOG_PREFIX}: Command passed to docker exec: $*"

# 5) If already correct uid/gid, just exec
if [ "$(id -u)" = "${DESIRED_UID}" ] && [ "$(id -g)" = "${DESIRED_GID}" ]; then

  # Run prestart script
  if [ -x /usr/local/bin/prestart ]; then
    echo "${LOG_PREFIX}: Running prestart script..."
    /usr/local/bin/prestart
  fi

  # Run main script
  exec "$@"
fi

# 6) Exec as that user
# Run prestart script as the desired user
if [ -x /usr/local/bin/prestart ]; then
  echo "${LOG_PREFIX}: Running prestart script..."
  su-exec "${USER_NAME}:${GROUP_NAME}" /usr/local/bin/prestart
fi
# Run main script as the desired user
exec su-exec "${USER_NAME}:${GROUP_NAME}" "$@"
