#
#  Specific system configuration settings for server
#


{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../configuration-desktop.nix
      ../../modules/desktops/virtualisation/docker.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.consoleLogLevel = 7;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "fbcon=rotate:1"
    "ignore_loglevel"
  ];
  console.earlySetup = true;
  console.packages = with pkgs; [ terminus_font ];
  console.font = lib.mkForce "ter-v32n";

  boot.initrd.luks.devices."luks-c013d73a-37ec-4a8c-9eb9-55a489a50c93".device = "/dev/disk/by-uuid/c013d73a-37ec-4a8c-9eb9-55a489a50c93";

  # Enable Desktop Environment.
  gnome.enable = true;


}






