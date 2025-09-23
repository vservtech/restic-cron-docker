#!/bin/sh
set -eu

# 1) Resolve desired UID/GID
# When setting `user: "${MY_UID}:${MY_GID}"` in compose.yaml, HOST_UID/HOST_GID are set.
# Otherwise fall back to current process uid/gid inside the container (mostly root).
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

# 3) Ensure user exists inside the container for DESIRED_UID
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

# 4) Ensure working directories are owned
if [ -d /opt/cron ]; then
  chown -R "${USER_NAME}:${GROUP_NAME}" /opt/cron
fi

echo "ENTRY DEBUG: Command which should be run: $*"

# 5) If already correct uid/gid, just exec
if [ "$(id -u)" = "${DESIRED_UID}" ] && [ "$(id -g)" = "${DESIRED_GID}" ]; then
  exec "$@"
fi

# 6) Exec as that user
exec su-exec "${USER_NAME}:${GROUP_NAME}" "$@"