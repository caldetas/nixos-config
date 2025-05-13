#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:

with lib;
let
  # Create a deterministic admin token
  adminToken = builtins.hashString "sha256" "vaultwarden-${vars.domain}";
in
{
  options = {
    bitwarden = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  ## Activate SURFSHARK VPN
  # systemctl start openvpn-ch-zur.service
  # systemctl status openvpn-ch-zur.service
  # systemctl stop openvpn-ch-zur.service

  config = mkIf (config.bitwarden.enable) {
    services.vaultwarden = {
      enable = true;
      environmentFile = "/etc/vaultwarden.env";
      config = {
        DOMAIN = "http://${vars.domain}";
        SIGNUPS_ALLOWED = true;
        WEBSOCKET_ENABLED = true;
        ROCKET_PORT = 8222;
      };
    };

    #create db file if not exists
    systemd.tmpfiles.rules = [
      "d /var/lib/bitwarden_rs 0750 vaultwarden vaultwarden -"
    ];
    #create secret token
    environment.etc."vaultwarden.env".text = ''
      DATABASE_URL=/var/lib/bitwarden_rs/vaultwarden.db
      ADMIN_TOKEN=${adminToken}
    '';

    services.nginx = {
      enable = true;
      virtualHosts."vault.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain; # Use SSL only for real domain
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
        };
      };
    };

    #    networking.firewall.allowedTCPPorts = [ 80 443 8222 ];

    systemd.services.vaultwarden.serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };

    systemd.services.vaultwarden.preStart = ''
      echo "Vaultwarden admin token: ${adminToken}"
    '';

    security.acme = {
      acceptTerms = true;
      defaults.email = "info@${vars.domain}"; # Replace if needed
    };
  };
}
