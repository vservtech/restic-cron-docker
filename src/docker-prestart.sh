#!/bin/sh
set -eu

echo "PRESTART SCRIPT: Checking crontab syntax..."
if supercronic -test -passthrough-logs /opt/cron/crontab; then
    echo "✓ Crontab valid"
else
    echo "✗ Crontab check failed! Please check your crontab syntax." >&2
    exit 1
fi