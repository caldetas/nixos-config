#
#  Specific system configuration settings for server
#


{ pkgs, config, lib, unstable, inputs, vars, host, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/desktops/virtualisation/docker.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "fbcon=rotate:3"
  ];
  console.packages = [ pkgs.terminus_font ];
  console.font = lib.mkForce "ter-v32n";


  # Enable Desktop Environment.
  gnome.enable = true;


}






