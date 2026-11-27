{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" =
    {
      device = "/dev/mapper/luks-6143d407-9cea-4c13-9ecf-fec87c81c664";
      fsType = "ext4";
    };
  boot.initrd.luks.devices."luks-6143d407-9cea-4c13-9ecf-fec87c81c664".device = "/dev/disk/by-uuid/6143d407-9cea-4c13-9ecf-fec
87c81c664";
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/BF5E-8AFD";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
