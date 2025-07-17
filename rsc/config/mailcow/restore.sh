#!/usr/bin/env bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
echo $DATE
mkdir -p cd /home/caldetas/git/mailcow-dockerized-restore || true
cd /home/caldetas/git/mailcow-dockerized-restore/;
rsync -aHv --delete /backup/mailcow/$DATE/rsync/ /home/caldetas/git/mailcow-dockerized-restore/
rsync -aHv --delete /backup/mailcow/$DATE/volumes/ /var/lib/docker/volumes/
docker compose up -d
BACKUP_LOCATION=/backup/mailcow/$DATE/ /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore mysql crypt redis
tar xvpf backup-mailcow-$DATE.tar.gz -C /restore-location
