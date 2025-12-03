#!/bin/sh
set -euo pipefail
#folders are already created in vaultwarden.nix
OUT="/mnt/hetzner-box/backup/nixcz/vaultwarden/vaultwarden-backup.tar.gz.gpg"

#copy as tar to hetzner box as tar to preserve permissions
tar czpf - -C /tmp/backup vaultwarden |  \
gpg \
--batch --yes \
--symmetric --cipher-algo AES256 \
--passphrase-file "$PASSPHRASE_FILE" \
-o "$OUT"