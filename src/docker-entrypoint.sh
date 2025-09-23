#!/bin/sh
set -eu
# 1) Resolve desired UID/GID
# When setting `user: "${MY_UID}:${MY_GID}"` in compose.yaml, the HOST_UID and HOST_GID values are set
# MY_UID and MY_GID are intended to be set by ansible on deploymentDESIRED_UID="${HOST_UID:-$(id -u)}"
DESIRED_UID="${HOST_UID:-$(id -u)}"
DESIRED_GID="${HOST_GID:-$(id -g)}"

echo "ENTRY DEBUG: Running with UID: ${DESIRED_UID}"
echo "ENTRY DEBUG: Running with GID: ${DESIRED_GID}"

# 2) Ensure group exists inside the container for DESIRED_GID
if ! getent group "${DESIRED_GID}" >/dev/null 2>&1 && \
   ! getent group "appgroup" >/dev/null 2>&1; then
  if ! addgroup -g "${DESIRED_GID}" appgroup; then
    echo "ENTRY ERROR: addgroup failed for GID ${DESIRED_GID}" >&2
    exit 1
  fi
fi

# Resolve group name (by gid first; fallback to appgroup)
GROUP_NAME="$(getent group "${DESIRED_GID}" | cut -d: -f1 || true)"
[ -z "${GROUP_NAME}" ] && GROUP_NAME="appgroup"

# Ensure user exists
if ! getent passwd "${DESIRED_UID}" >/dev/null 2>&1 && \
   ! getent passwd "appuser" >/dev/null 2>&1; then
  if ! adduser -D -u "${DESIRED_UID}" -G "${GROUP_NAME}" appuser; then
    echo "ENTRY ERROR: adduser failed for UID ${DESIRED_UID}" >&2
    exit 1
  fi
fi

# Resolve user name (by uid first; fallback)
USER_NAME="$(getent passwd "${DESIRED_UID}" | cut -d: -f1 || true)"
[ -z "${USER_NAME}" ] && USER_NAME="appuser"

# Own only if path exists; avoid glob failing with set -u
if [ -d /opt/cron ]; then
  # Use a safe path expansion
  chown -R "${USER_NAME}:${GROUP_NAME}" /opt/cron
fi

echo "ENTRY DEBUG: Command which should be run: $*"

# If already correct uid/gid, exec directly
if [ "$(id -u)" = "${DESIRED_UID}" ] && [ "$(id -g)" = "${DESIRED_GID}" ]; then
  exec "$@"
fi

# Else exec through su-exec
exec su-exec "${USER_NAME}:${GROUP_NAME}" "$@"