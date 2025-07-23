#!/usr/bin/env bash
set -euo pipefail

# Configuration
REPO="/mnt/hetzner-box/backup_server/borg-repo"
RESTORE_DATE="${1:-latest}"  # e.g., 2025-07-22 or "latest"
RESTORE_TARGET="/tmp/seafile-restore"
SEAFILE_DIR="/home/caldetas/git/seafile-docker-ce"

# Optional: Stop Seafile for safety
echo "Stopping Seafile stack..."
cd "$SEAFILE_DIR"
docker compose down

# Clean restore target
echo "Preparing restore directory at $RESTORE_TARGET"
rm -rf "$RESTORE_TARGET"
mkdir -p "$RESTORE_TARGET"

# Determine archive name
if [[ "$RESTORE_DATE" == "latest" ]]; then
  ARCHIVE=$(borg list "$REPO" --last 1 --short)
else
  ARCHIVE="auto-$RESTORE_DATE"
fi

echo "Restoring archive: $ARCHIVE"
borg extract "$REPO"::$ARCHIVE --destination "$RESTORE_TARGET"

# Restore rsync config (optional)
echo "Restoring docker config..."
rsync -aHv --delete "$RESTORE_TARGET/rsync/" "$SEAFILE_DIR/"

# Restore library data (seafile-data folder)
echo "Restoring library data..."
rsync -aHv --delete "$RESTORE_TARGET/seafile-data/" "/mnt/hetzner-box/seafile-data/"

# Optional: Set ownership if needed (UID:GID of running container)
chown -R 466367:466367 /mnt/hetzner-box/seafile-data

# Start Seafile again
echo "Starting Seafile stack..."
docker compose up -d

echo "✅ Restore completed from archive: $ARCHIVE"