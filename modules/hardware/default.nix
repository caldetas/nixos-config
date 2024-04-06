#
#  Hardware
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ default.nix
#   └─ ./modules
#       └─ ./hardware
#           ├─ default.nix *
#           └─ ...
#

[
  ./bluetooth.nix
  ./power.nix
]
