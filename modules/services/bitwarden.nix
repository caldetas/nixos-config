#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
let
  # at build-time, load the plain-text token from the sops-nix–decrypted file
  adminToken = builtins.readFile config.sops.secrets."vaultwarden/admin-token".path;
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

  config = mkIf config.bitwarden.enable {
    # -- vaultwarden service
    services.vaultwarden = {
      enable = true;
      environmentFile = "/etc/vaultwarden.env";
      config = {
        DOMAIN = "http://${vars.domain}";
        SIGNUPS_ALLOWED = true;
        WEBSOCKET_ENABLED = true;
        ROCKET_PORT = 8222;
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
      };
      preStart = ''
        echo "Vaultwarden admin token is being written."
      '';
    };

    # -- write the .env file at /etc/vaultwarden.env
    environment.etc."vaultwarden.env".text = ''
      DATABASE_URL=/var/lib/bitwarden_rs/vaultwarden.db
      ADMIN_TOKEN=${adminToken}
    '';

    # -- ensure the data dir exists
    systemd.tmpfiles.rules = [
      "d /var/lib/bitwarden_rs 0750 vaultwarden vaultwarden -"
    ];

    # -- nginx reverse-proxy
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

    # Written to /etc/vaultwarden.env on server
    #    systemd.services.vaultwarden.serviceConfig.Environment = "ADMIN_TOKEN=$(cat ${ADMIN_TOKEN_PATH})";
    #    systemd.services.vaultwarden.preStart = ''
    #      echo "Vaultwarden admin token: $(cat ${ADMIN_TOKEN_PATH})"
    #    '';
  };
}
