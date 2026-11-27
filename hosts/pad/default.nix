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
  # Use the GRUB UEFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    enableCryptodisk = true;
    useOSProber = true;
    configurationLimit = 20;
    default = 0;
  };
  boot.consoleLogLevel = 7;
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






