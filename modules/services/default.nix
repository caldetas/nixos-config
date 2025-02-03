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
  ./dunst.nix
  ./gnupg.nix
  ./picom.nix
  ./polybar.nix
  ./surfshark.nix
  ./sxhkd.nix
  #  ./udiskie.nix
]

