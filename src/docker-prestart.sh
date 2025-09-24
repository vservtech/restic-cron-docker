#!/bin/sh
set -eu

LOG_PREFIX="PRESTART SCRIPT"
echo "${LOG_PREFIX}: Checking crontab syntax..."
if supercronic -test -passthrough-logs /opt/cron/crontab; then
    echo "${LOG_PREFIX}: ✓✓✓ Crontab valid ✓✓✓"
else
    echo "${LOG_PREFIX}: ✗✗✗ Crontab check failed! ✗✗✗ Please check your crontab syntax. " >&2
    exit 1
fi