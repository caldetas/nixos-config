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
    environment.etc."vaultwarden/backup.sh" = { text = builtins.readFile ../../rsc/config/vaultwarden/backup.sh; mode = "0755"; };
    # Create required directories
    systemd.tmpfiles.rules = [
      "d /var/lib/bitwarden_rs 0750 vaultwarden vaultwarden -"
      "d /tmp/backup/vaultwarden 0750 vaultwarden vaultwarden -"
    ];
    # Timer that triggers BOTH backup services
    # (backup-vaultwarden first, then backup-vaultwarden-post)
    systemd.timers.backup-vaultwarden = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 01:15:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

    # Override the unit to also trigger the post-backup service
    systemd.units."backup-vaultwarden.timer".unit.Unit.Unit = mkForce ''
      [Unit]
      Description=Daily backup of Vaultwarden
      PartOf=backup-vaultwarden-post.timer

      [Timer]
      OnCalendar=*-*-* 01:15:00
      Persistent=true
      RandomizedDelaySec=5m

      [Install]
      WantedBy=timers.target
    '';

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
