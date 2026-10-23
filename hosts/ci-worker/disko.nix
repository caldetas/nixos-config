{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:
{

  imports =
    [
      inputs.disko.nixosModules.disko
    ];

  disko.devices.disk.disk1 = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        bios_boot = {
          name = "bios";
          size = "1M";
          type = "EF02";
        };
        boot = {
          name = "boot";
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          name = "root";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            extraArgs = [ "-L nixos" ];
          };
        };
      };
    };
  };
}

