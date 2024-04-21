{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/4fa2402b-7269-4c33-a06b-d4fed7b90f3d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-ecb54e9e-7f1c-48a1-951d-9368f8d81787".device = "/dev/disk/by-uuid/ecb54e9e-7f1c-48a1-951d-9368f8d81787";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2392-2B8B";
      fsType = "vfat";
    };


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with networking.interfaces.<interface>.useDHCP.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  #  services.resolved.enable = true;
}
