#!/usr/bin/env bash
set -euo pipefail

#adapt date if necessary
DATE=$(date '+%Y-%m-%d')
echo $DATE

mkdir -p /home/caldetas/git/mailcow-dockerized-restore
tar xvpf /mnt/hetzner-box/backup/mailcow/backup-mailcow-$DATE.tar.gz -C /home/caldetas/git/mailcow-dockerized-restore
cd /home/caldetas/git/mailcow-dockerized-restore/
rsync -aHv $DATE/rsync/ .
rsync -aHv --delete $DATE/volumes/ /var/lib/docker/volumes/
docker compose up -d

BACKUP_LOCATION=/home/caldetas/git/mailcow-dockerized-restore/$DATE/ helper-scripts/backup_and_restore.sh restore mysql crypt redis

#rm remove restore folder?