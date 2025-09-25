#!/bin/sh
set -eu

LOG_PREFIX="PRESTART SCRIPT"
echo "${LOG_PREFIX}: Checking crontab syntax..."
if [ -f /opt/cron/crontab ]; then
    if supercronic -test -passthrough-logs /opt/cron/crontab; then
        echo "${LOG_PREFIX}: ✓✓✓ Crontab valid ✓✓✓"
    else
        echo "${LOG_PREFIX}: ✗✗✗ Crontab check failed! ✗✗✗ Please check your crontab syntax. " >&2
        exit 1
    fi
else
    echo "${LOG_PREFIX}: WARNING: No crontab file found at /opt/cron/crontab"
    echo "${LOG_PREFIX}: This might be ok if using the container for restoring a backup,"
    echo "${LOG_PREFIX}: otherwise this points to a missing volume mount in your docker compose or docker run command!"
fi