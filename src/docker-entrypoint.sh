#!/bin/sh
set -eu

# 1) Resolve desired UID/GID
DESIRED_UID="${HOST_UID:-$(id -u)}"
DESIRED_GID="${HOST_GID:-$(id -g)}"

# 2) Ensure group exists inside the container for DESIRED_GID
if ! getent group "${DESIRED_GID}" >/dev/null 2>&1; then
  addgroup -g "${DESIRED_GID}" appgroup >/dev/null 2>&1 || true
fi

# Find group name or fallback
GROUP_NAME="$(getent group "${DESIRED_GID}" | cut -d: -f1 || echo appgroup)"

# 3) Ensure user exists inside the container for DESIRED_UID
if ! getent passwd "${DESIRED_UID}" >/dev/null 2>&1; then
  adduser -D -u "${DESIRED_UID}" -G "${GROUP_NAME}" appuser >/dev/null 2>&1 || true
fi

# Find user name or fallback
USER_NAME="$(getent passwd "${DESIRED_UID}" | cut -d: -f1 || echo appuser)"

# 4) Ensure working directories are owned
chown -R "${USER_NAME}:${GROUP_NAME}" /opt/cron

# 5) If current uid/gid already match, just exec
if [ "$(id -u)" = "${DESIRED_UID}" ] && [ "$(id -g)" = "${DESIRED_GID}" ]; then
  exec "$@"
fi

# 6) Exec as that user
exec su-exec "${USER_NAME}:${GROUP_NAME}" "$@"