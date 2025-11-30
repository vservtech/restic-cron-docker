### PROD IMAGE 
### DEFAULT USER: root
### Set HOST_UID and HOST_GID vars to run the container as a specific user/group
### => will be used in docker-prestart.sh and docker-entrypoint.sh to ensure the correct user/group is used for the container
### ------------

FROM alpine:3.22.2

# Install base dependencies
RUN apk add --no-cache ca-certificates tzdata curl

# Install supercronic from official github releases
ARG TARGETARCH

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_VERSION=v0.2.34
# Map Docker arch to the release filename and expected sha1
# Note: upstream uses amd64/arm64 in filenames
# Update checksums if you bump SUPERCRONIC_VERSION
# TODO: Check if SHA256 checksums are available
ENV SUPERCRONIC_AMD64=supercronic-linux-amd64 \
    SUPERCRONIC_AMD64_SHA1=e8631edc1775000d119b70fd40339a7238eece14 \
    SUPERCRONIC_ARM64=supercronic-linux-arm64 \
    SUPERCRONIC_ARM64_SHA1=4ab6343b52bf9da592e8b4bb7ae6eb5a8e21b71e

# Resolve name and checksum based on TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) BIN="${SUPERCRONIC_AMD64}"; SUM="${SUPERCRONIC_AMD64_SHA1}";; \
    arm64) BIN="${SUPERCRONIC_ARM64}"; SUM="${SUPERCRONIC_ARM64_SHA1}";; \
    *) echo "Unsupported TARGETARCH: ${TARGETARCH}"; exit 1;; \
  esac; \
  URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/${BIN}"; \
  curl -fsSLO "$URL"; \
  echo "${SUM}  ${BIN}" | sha1sum -c -; \
  install -m 0755 "${BIN}" /usr/local/bin/${BIN}; \
  ln -sf "/usr/local/bin/${BIN}" /usr/local/bin/supercronic

# Install deps needed at runtime
# - bash, because most users expect this to be available for cronjob scripts
# - openssh, to allow restic to use ssh client for backups + having scp binary (also installs sshd, but this is not needed here)
# - vim, and nano, for easy in-container file editing
# - sqlite package with sqlite3 command, for easy sqlite db backups
# - rsync, for file synchronization (mostly for preparing a backup folder for restic)
# - postgresql-client, for pg_dump command
# - mysql-client, for mysqldump command
# - unzip, for unzipping files, especially for installing bun
RUN apk add --no-cache restic su-exec bash openssh vim nano sqlite rsync postgresql-client mysql-client unzip

ENV BUN_INSTALL="/opt/bun"
ENV PATH="${BUN_INSTALL}/bin:$PATH"
RUN curl -fsSL https://bun.com/install | bash


# Set workdir
ENV CRON_DIR="/opt/cron"
RUN mkdir -p "${CRON_DIR}"
WORKDIR "${CRON_DIR}"

# Add entrypoint and startup scripts
COPY src/docker-entrypoint.sh /usr/local/bin/entrypoint
COPY src/docker-prestart.sh /usr/local/bin/prestart
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/prestart

# Note: Entrypoint is always run with either CMD as params or the command passed to docker run
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/usr/local/bin/supercronic", "-passthrough-logs", "/opt/cron/crontab"]
