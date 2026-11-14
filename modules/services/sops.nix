#
#  System Notifications
#

{ config, lib, pkgs, vars, sops-nix, ... }:
with lib;
{
  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../../secrets/common.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
}

