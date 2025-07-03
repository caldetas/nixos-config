#
#  Main system configuration.
#

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:


with lib;
let
  args = { inherit config lib pkgs unstable inputs vars sops-nix host; };
in {
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
  hostName =  host.hostName;
};
}
