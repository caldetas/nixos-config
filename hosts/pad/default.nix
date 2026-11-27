#
#  Specific system configuration settings for server
#


{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/desktops/virtualisation/docker.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.consoleLogLevel = 7;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "fbcon=rotate:3"
    "ignore_loglevel"
  ];
  console.earlySetup = true;
  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-v32n";

  boot.initrd.luks.devices."luks-9f6e46ed-c2e8-4f75-986f-11cfdda386e4".device = "/dev/disk/by-uuid/9f6e46ed-c2e8-4f75-986f-11cfdda386e4";

  # Enable Desktop Environment.
  gnome.enable = true;


}






