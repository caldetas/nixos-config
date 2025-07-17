#
#  Main system configuration.
#

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:


with lib;

{
  imports =
    [
    ] ++
    (
      import "${inputs.self}/modules/desktop"
    );

}
