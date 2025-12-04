#!/usr/bin/env bash
set -euo pipefail

# Stop vaultwarden
systemctl stop vaultwarden

mkdir -p /tmp/backup/vaultwarden/

rm -rf /tmp/backup/vaultwarden/* || true
gpg vaultwarden-backup.tar.gz.gpg
tar xvpf ./vaultwarden-backup.tar.gz -C /tmp/backup/vaultwarden
rsync -aHv /tmp/backup/vaultwarden/vaultwarden/ /var/lib/bitwarden_rs

# Start vaultwarden
systemctl start vaultwarden

# Watch logs
journalctl -u vaultwarden -f

