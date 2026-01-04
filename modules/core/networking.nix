{ config, lib, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
    nameservers = [ "194.169.169.169" ];
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "1.0.0.1" "1.1.1.1" ];
  };
  services.openssh.enable = true;
}
