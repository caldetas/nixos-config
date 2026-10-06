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
  ./vaultwarden.nix
  ./dunst.nix
  ./gnupg.nix
  ./immich.nix
  ./mailcow.nix
  ./nginx.nix
  ./nix.nix
  ./picom.nix
  ./polybar.nix
  ./seafile.nix
  ./server.nix
  ./sops.nix
  ./sxhkd.nix
  ./vpsfreectl.nix
]

