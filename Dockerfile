### PROD IMAGE 
### ------------

FROM alpine:3.22.1

# Install base dependencies
RUN apk add --no-cache ca-certificates tzdata curl

# Install supercronic from official github releases
ARG TARGETARCH

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_VERSION=v0.2.34
# Map Docker arch to the release filename and expected sha1
# Note: upstream uses amd64/arm64 in filenames
# Update checksums if you bump SUPERCRONIC_VERSION
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
# Installing bash because most users expect this to be available for cronjob scripts
RUN apk add --no-cache restic su-exec bash

# Set workdir
ENV CRON_DIR="/opt/cron"
RUN mkdir -p "${CRON_DIR}"
WORKDIR "${CRON_DIR}"

# Add entrypoint script 
COPY src/docker-entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
# Note: Entrypoint is always run with either CMD as params or the command passed to docker run
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/usr/local/bin/supercronic", "-passthrough-logs", "/opt/cron/crontab"]
