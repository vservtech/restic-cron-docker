FROM alpine:3.22.1

# Install dependencies
RUN apk add --no-cache restic dcron ca-certificates tzdata

# Set workdir
ENV CRON_DIR="/opt/cron"
RUN mkdir -p "${CRON_DIR}"
WORKDIR "${CRON_DIR}"



