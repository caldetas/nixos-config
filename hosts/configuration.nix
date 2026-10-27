#
#  Main system configuration.
#

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:
with lib;
{
  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ] ++
    (
      import ../modules/core ++
      import ../modules/desktops ++
      import ../modules/editors ++
      import ../modules/hardware ++
      import ../modules/programs ++
      import ../modules/services ++
      import ../modules/shell ++
      import ../modules/theming
    );
  networking = {
    hostName = host.hostName;
  };
  nixpkgs.overlays = [
    (final: prev: {
      "gradient-frontend" =
        (prev."gradient-frontend").overrideAttrs (old: {
          pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
            outputHash = "sha256-7LhcfB/O0p2KipGNe3ixEBe9bYhKRFVdzP8chKwBd3I=";
          });
        });
    })
  ];
}
