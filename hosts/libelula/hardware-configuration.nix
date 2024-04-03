{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4fa2402b-7269-4c33-a06b-d4fed7b90f3d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-ecb54e9e-7f1c-48a1-951d-9368f8d81787".device = "/dev/disk/by-uuid/ecb54e9e-7f1c-48a1-951d-9368f8d81787";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2392-2B8B";
      fsType = "vfat";
    };


  networking = {
    useDHCP = false;                        # Deprecated
    networkmanager = {
        enable = true;
        plugins = [ pkgs.networkmanager-openvpn pkgs.networkmanager_strongswan];
#        extraConfig =''
##           supersede domain-name-servers 127.0.0.53;
##            prepend domain-name-servers 208.67.222.222;
#          '';
        };
     interfaces = {
       lo = {
         useDHCP = true;                     # For versatility sake, manually edit IP on nm-applet.
         #ipv4.addresses = [ {
         #    address = "192.168.0.51";
         #    prefixLength = 24;
         #} ];
       };
       wlp0s20f3 = {
         useDHCP = true;
         #ipv4.addresses = [ {
         #  address = "192.168.0.51";
         #  prefixLength = 24;
         #} ];
       };
     };
 #    defaultGateway = "192.168.0.1";
 #    nameservers = [ "192.168.0.4" ];
     firewall = {
       enable = false;
       allowedUDPPorts = [ 500 4500 3389 5900];
       allowedTCPPorts = [ 500 4500 3389 5900];
     };
   };
   powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
   hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

   services.resolved.enable = true;
   services.openvpn.servers = {
   };
}