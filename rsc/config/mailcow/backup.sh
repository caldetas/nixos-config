#!/usr/bin/env bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
echo $DATE
cd /home/caldetas/git/mailcow-dockerized/;
docker compose down

mkdir -p /tmp/backup/mailcow/$DATE/rsync
rsync -aHv --delete --exclude='.git/' /home/caldetas/git/mailcow-dockerized/ /tmp/backup/mailcow/$DATE/rsync/
rsync -aHv --delete /var/lib/docker/volumes/*mailcow* /tmp/backup/mailcow/$DATE/volumes/
docker compose up -d

BACKUP_LOCATION=/tmp/backup/mailcow/$DATE/ /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3

#copy to hetzner box as tar to preserve permissions
mkdir -p /mnt/hetzner-box/backup/nixcz/mailcow
tar czpf /mnt/hetzner-box/backup/nixcz/mailcow/backup-mailcow-$DATE.tar.gz -C /tmp/backup/mailcow/$DATE