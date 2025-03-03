#
# Hardware settings for a general VM.
# Works on QEMU Virt-Manager and Virtualbox
#
# flake.nix
#  └─ ./hosts
#      └─ ./vm
#          ├─ default.nix
#          └─ hardware-configuration.nix *
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
#

{ config, lib, pkgs, modulesPath, host, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
  #  boot.kernelParams = [ "i915.enable_guc=2" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/vda";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  networking = with host; {
    useDHCP = false; # Deprecated
    hostName = hostName;
    interfaces = {
      enp0s3.useDHCP = true;
    };
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #virtualisation.virtualbox.guest.enable = true;     #currently disabled because package is broken
}
