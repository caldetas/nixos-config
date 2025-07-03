{ config, lib, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
    nameservers = [ "149.154.159.92" "162.252.172.57" ];
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "1.0.0.1" "1.1.1.1" ];
  };
  services.openssh.enable = true;
}
