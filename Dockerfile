### PROD IMAGE 
### ------------

FROM alpine:3.22.1

# Install base dependencies
RUN apk add --no-cache ca-certificates tzdata curl

# Install supercronic from official github releases
ENV SUPERCRONIC_VERSION=v0.2.34
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-arm64 \
    SUPERCRONIC_SHA1SUM=4ab6343b52bf9da592e8b4bb7ae6eb5a8e21b71e \
    SUPERCRONIC=supercronic-linux-arm64
RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Install deps needed at runtime
RUN apk add --no-cache restic su-exec

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
