## Borgmatic Restore Archive

*Borg has no config file requirement - use raw `borg` commands directly*

### Environment Setup
    nix-shell -p borgbackup
    export BORG_PASSPHRASE="$(sudo more /run/secrets/borg/password)"
    export BORG_REPO="$(sudo more /run/secrets/borg/repo)"
    export BORG_RSH="ssh -i /home/caldetas/.ssh/hetzner_box_ed25519 -p23 -oBatchMode=yes"

### SSH Host Key (One-time)
    ssh-keygen -R "$(echo $BORG_REPO | sed 's|ssh://||; s|/.*||')"
    ssh -i /home/caldetas/.ssh/hetzner_box_ed25519 -p 23 -oBatchMode=no $(echo $BORG_REPO | sed 's|ssh://||; s|:.*||')


### List Archives
    borg list "ssh://$BORG_REPO" #last archive on bottom of the list is the most recent!

### List Files
    borg list "ssh://$BORG_REPO::nixcz-2026-02-09T02:53:02.449215"  #last archive specified

### Restore Vaultwarden Backup
    borg extract "ssh://$BORG_REPO::nixcz-2026-02-09T02:53:02.449215" ./mnt/hetzner-box/backup/nixcz/vaultwarden/vaultwarden-backup.tar.gz.gpg --strip-components 5

