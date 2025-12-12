#!/bin/sh
set -e

command -v mc >/dev/null 2>&1 || apk add --no-cache minio-client >/dev/null

CRON_SCHEDULE="${CRON_SCHEDULE:-0 2 * * *}"

if [ "$1" = "run-once" ]; then
  exec sh /backup/run_backup.sh
fi

echo "${CRON_SCHEDULE} sh /backup/run_backup.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root
echo "Starting backup cron with schedule: ${CRON_SCHEDULE}"
exec crond -f -L /var/log/cron.log
