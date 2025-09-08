#!/usr/bin/env bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
echo $DATE
mkdir -p /home/caldetas/git/mailcow-dockerized-restore
mkdir -p /tmp/backup/mailcow/$DATE/
tar xvpf backup-mailcow-$DATE.tar.gz -C /tmp/backup/mailcow/$DATE/
cd /home/caldetas/git/mailcow-dockerized-restore
rsync -aHv --delete /tmp/backup/mailcow/$DATE/rsync/ /home/caldetas/git/mailcow-dockerized-restore/
rsync -aHv  /tmp/backup/mailcow/$DATE/volumes/ /var/lib/docker/volumes/ #delete deletes all other docker volumes.. careful
docker compose up -d
BACKUP_LOCATION=/tmp/backup/mailcow/$DATE/ /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore mysql crypt redis
