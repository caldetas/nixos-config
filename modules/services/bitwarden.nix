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

    # Copy tar command after backing up
    # backup service
    systemd.services.backup-vaultwarden-copy = {
      description = "Vaultwarden copy backup to Hetzner box";
      after = [ "backup-vaultwarden.service" ];
      wants = [ "backup-vaultwarden.service" ];
      wantedBy = [ ]; # Don't auto-start; triggered by timer only
      environment = {
        PASSPHRASE_FILE = config.sops.secrets."borg/password".path;
      };
      path = with pkgs; [ bash coreutils gnutar gnupg gzip ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Environment = "PATH=/run/wrappers/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        ExecStart = "${pkgs.bash}/bin/bash /etc/vaultwarden/backup.sh";
      };
    };

    systemd.timers.backup-vaultwarden-copy = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 01:30:00";
        Persistent = true;
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
