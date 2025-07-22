#!/usr/bin/env bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
echo "🔁 Seafile backup started for $DATE"

# Directory layout
SEAFILE_DOCKER_DIR="/home/caldetas/git/seafile-docker-ce"
BACKUP_ROOT="/backup/seafile/${DATE}"
SEAFILE_VOLUMES_DIR="/mnt/hetzner-box/seafile-data"
HETZNER_TARGET="/mnt/hetzner-box/backup_server/seafile"

# Shut down containers safely
cd "$SEAFILE_DOCKER_DIR"
docker compose down

# Backup Seafile config & data
mkdir -p "$BACKUP_ROOT/rsync"
rsync -aHv --delete --exclude='.git/' "$SEAFILE_DOCKER_DIR/" "$BACKUP_ROOT/rsync/"
rsync -aHv --delete "$SEAFILE_VOLUMES_DIR" "$BACKUP_ROOT/volumes/"

# Dump MySQL (adjust user/pass or get from .env)
echo "🛢️ Dumping MySQL databases..."
MYSQL_ROOT_PW=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
docker exec seafile-mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --all-databases' > "$BACKUP_ROOT/seafile-db.sql"

# Start containers again
docker compose up -d

# Create compressed archive for Hetzner box
mkdir -p "$HETZNER_TARGET"
tar czpf "$HETZNER_TARGET/backup-seafile-$DATE.tar.gz" -C /backup/seafile "$DATE"

# Optionally: prune old backups (>7 days)
find "$HETZNER_TARGET" -name '*.tar.gz' -mtime +7 -exec rm {} \;

echo "✅ Backup complete: $HETZNER_TARGET/backup-seafile-$DATE.tar.gz"
