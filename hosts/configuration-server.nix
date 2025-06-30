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
    (import ../../modules/core ++
             import ../../modules/desktop ++
      import ../modules/desktops ++
      import ../modules/editors ++
      import ../modules/hardware ++
      import ../modules/programs ++
      import ../modules/services ++
      import ../modules/shell ++
      import ../modules/theming
    );

}
