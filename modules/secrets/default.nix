{ host }:

[
  ./core.nix
  ./gradient.nix
  ./nixcz.nix
  ./desktops.nix
]

++ (if (host.hostName == "nixcz")
then [ ]
else [ ]
)
++ (if builtins.elem host.hostName [ "libelula" "onsite-gnome" ]
then [ ./desktops.nix ]
else [ ]
)
