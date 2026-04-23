{ config, lib, ... }:

{
  system.nssDatabases.hosts = [ "dns" ];
  networking = {
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
    nameservers = [ "194.169.169.169" "1.1.1.1" ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "192.168.178.1" "1.1.1.1" ];
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [ "1.0.0.1" "1.1.1.1" ];
    };
  };
  services.openssh.enable = true;
}
