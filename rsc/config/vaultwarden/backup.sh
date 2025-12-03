#!/usr/bin/env bash
set -euo pipefail
#folders are already created in vaultwarden.nix

#copy as tar to hetzner box as tar to preserve permissions
mkdir -p /mnt/hetzner-box/backup/nixcz/vaultwarden
tar czpf /mnt/hetzner-box/backup/nixcz/vaultwarden/backup-vaultwarden.tar.gz -C /tmp/backup vaultwarden