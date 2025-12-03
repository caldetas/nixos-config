#
#  Vaultwarden Password Manager
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
      # Enable the built-in backup service - this creates backup-vaultwarden.service
      backupDir = "/tmp/backup/vaultwarden";
      config = {
        DOMAIN = "http://${vars.domain}";
        SIGNUPS_ALLOWED = true;
        WEBSOCKET_ENABLED = true;
        ROCKET_PORT = 8222;
      };
    };

    # Create required directories
    systemd.tmpfiles.rules = [
      "d /var/lib/bitwarden_rs 0750 vaultwarden vaultwarden -"
      "d /tmp/backup/vaultwarden 0750 vaultwarden vaultwarden -"
    ];

    # Schedule the backup to run daily (adjust as needed)
    systemd.timers.backup-vaultwarden = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        OnCalendar = "*-*-* 01:15:00";
        RandomizedDelaySec = "5m";
      };
    };

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
