#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/caldetas/git/mailcow-dockerized
mkdir -p /tmp/backup/mailcow/

rm -rf /tmp/backup/mailcow*
tar xvpf ./backup-mailcow.tar.gz -C /tmp/backup/
cd /home/caldetas/git/mailcow-dockerized
rsync -aHv /tmp/backup/mailcow/rsync/* /home/caldetas/git/mailcow-dockerized/
rsync -aHv  /tmp/backup/mailcow/volumes/ /var/lib/docker/volumes/ # "--delete" deletes all other docker volumes.. careful

#deactivate local cert mounting for using nginx
mv /home/caldetas/git/mailcow-dockerized/docker-compose.override.yml /home/caldetas/git/mailcow-dockerized/docker-compose.override.yml.bak

#skip dns healthcheck, only if domain is not set up yet
sed -i 's/^SKIP_UNBOUND_HEALTHCHECK=n$/SKIP_UNBOUND_HEALTHCHECK=y/' mailcow.conf
sed -i 's/^SKIP_LETS_ENCRYPT=n$/SKIP_LETS_ENCRYPT=y/' mailcow.conf

docker compose up -d
BACKUP_LOCATION=/tmp/backup/mailcow /home/caldetas/git/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore mysql crypt redis

#todo: reenable checks and letsencrypt once the domain is properly set up
#sed -i 's/^SKIP_UNBOUND_HEALTHCHECK=y$/SKIP_UNBOUND_HEALTHCHECK=n/' mailcow.conf
#sed -i 's/^SKIP_LETS_ENCRYPT=y$/SKIP_LETS_ENCRYPT=n/' mailcow.conf
#mv /home/caldetas/git/mailcow-dockerized/docker-compose.override.yml.bak /home/caldetas/git/mailcow-dockerized/docker-compose.override.yml