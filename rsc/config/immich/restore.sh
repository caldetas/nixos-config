export BORG_PASSPHRASE="$(sudo more /run/secrets/borg/password)"
export BORG_REPO="$(sudo more /run/secrets/borg/repo)"
export BORG_RSH="ssh -i /home/caldetas/.ssh/hetzner_box_ed25519 -p23 -oBatchMode=yes"
borg list "ssh://$BORG_REPO"

tmux new-session -d -s seafile 'borg extract "ssh://$BORG_REPO::nixcz-2026-06-13T04:32:21.122875" mnt/nas/seafile-data --strip-components 3 >> logfile.txt 2>&1'

# proceed to restore the library via the graphic interface of immich (point immich to library folder)

