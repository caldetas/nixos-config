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
  ./mailcow.nix
  ./picom.nix
  ./polybar.nix
  ./surfshark.nix
  ./sxhkd.nix
  #  ./udiskie.nix
]

