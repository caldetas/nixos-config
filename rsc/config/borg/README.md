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
    last_archive=$(borg list --last 1 --short "ssh://$BORG_REPO")

### List Files
    borg list "ssh://$BORG_REPO::$last_archive"  #last archive specified

### Restore Vaultwarden Backup
    borg extract "ssh://$BORG_REPO::$last_archive" ./mnt/hetzner-box/backup/nixcz/vaultwarden/vaultwarden-backup.tar.gz.gpg --strip-components 5

