#!/usr/bin/env bash
set -euo pipefail

cd /home/caldetas/git/mailcow-dockerized/;
docker compose down

mkdir -p /tmp/backup/mailcow/rsync
rm -fr /tmp/backup/mailcow/*
rsync -aHv /home/caldetas/git/mailcow-dockerized/ /tmp/backup/mailcow/rsync/
rsync -aHv /var/lib/docker/volumes/*mailcow* /tmp/backup/mailcow/volumes/
docker compose up -d

BACKUP_LOCATION=/tmp/backup/mailcow/ /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 1

#copy to hetzner box as tar to preserve permissions
mkdir -p /mnt/hetzner-box/backup/nixcz/mailcow
tar czpf /mnt/hetzner-box/backup/nixcz/mailcow/backup-mailcow.tar.gz -C /tmp/backup mailcow

#ps might need to open ports, switch off firewall!