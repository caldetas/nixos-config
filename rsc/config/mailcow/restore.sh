#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/caldetas/git/mailcow-dockerized
mkdir -p /tmp/backup/mailcow/

#make it a git repo again
git init
git remote add origin https://github.com/mailcow/mailcow-dockerized.git
git fetch

tar xvpf backup-mailcow.tar.gz -C /tmp/backup/mailcow/
cd /home/caldetas/git/mailcow-dockerized
rsync -aHv --delete /tmp/backup/mailcow/rsync/ /home/caldetas/git/mailcow-dockerized/
rsync -aHv  /tmp/backup/mailcow/volumes/ /var/lib/docker/volumes/ # "--delete" deletes all other docker volumes.. careful
docker compose up -d
BACKUP_LOCATION=/tmp/backup/mailcow /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore mysql crypt redis