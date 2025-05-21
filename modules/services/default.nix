#
#  Services
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./services
#           └─ default.nix *
#               └─ ...
#

[
  ./bitwarden.nix
  ./dunst.nix
  ./gnupg.nix
  ./hochrheinisches.nix
  ./mailcow.nix
  ./nix.nix
  ./picom.nix
  ./polybar.nix
  ./seafile.nix
  ./seafile2.nix
  ./server.nix
  ./sops.nix
  ./surfshark.nix
  ./sxhkd.nix
  #  ./udiskie.nix
]

