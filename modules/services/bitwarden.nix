#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
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

  config = mkIf (config.bitwarden.enable) {
    services.vaultwarden = {
      enable = true;
      environmentFile = config.sops.secrets."vaultwarden/env".path;
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

    services.nginx = {
      enable = true;
      virtualHosts."vault.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain;
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.vaultwarden.serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
