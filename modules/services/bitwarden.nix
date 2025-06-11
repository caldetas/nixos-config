#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
let
  ADMIN_TOKEN = "$(cat ${config.sops.secrets.my-secret.path})";
in
with lib;
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
      ADMIN_TOKEN=${ADMIN_TOKEN}
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

    # Written to /etc/vaultwarden.env on server
    #    systemd.services.vaultwarden.serviceConfig.Environment = "ADMIN_TOKEN=${config.sops.secrets."vaultwarden/admin-token".path}";
    systemd.services.vaultwarden.preStart = ''
      echo "Vaultwarden admin token: ${ADMIN_TOKEN}"
    '';
  };
}
