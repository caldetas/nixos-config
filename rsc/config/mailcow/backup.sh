#!/usr/bin/env bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
echo $DATE
cd /home/caldetas/git/mailcow-dockerized/;
docker compose down
mkdir -p /backup/mailcow/$DATE/rsync
rsync -aHv --delete /home/caldetas/git/mailcow-dockerized/ /backup/mailcow/$DATE/rsync/
rsync -aHv --delete /var/lib/docker/volumes/ /backup/mailcow/$DATE/volumes/
docker compose up -d
BACKUP_LOCATION=/backup/mailcow/$DATE/ /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3
#copy to hetzner box
mkdir -p /mnt/hetzner-box/backup_server
rsync -aHv /backup/ /mnt/hetzner-box/backup_server
