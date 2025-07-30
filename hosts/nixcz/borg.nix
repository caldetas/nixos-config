{ config, pkgs, lib, vars, host, ... }:

let
  prepareEnvScript = pkgs.writeShellScript "prepare-borgmatic-env" ''
    mkdir -p /root/.ssh
    ${pkgs.openssh}/bin/ssh-keyscan -p 23 u466367.your-storagebox.de >> /root/.ssh/known_hosts
    chmod 600 /root/.ssh/known_hosts
  '';

in
with lib;
{
  options = {
    backup = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf (config.backup.enable) {
    environment.etc."borgmatic/config-seafile.yml".text = builtins.readFile ../../rsc/config/borg/borg-seafile.yml;
    environment.etc."borgmatic/config-immich.yml".text = builtins.readFile ../../rsc/config/borg/borg-immich.yml;

    # Prepare environment file before running borgmatic
    systemd.services.borgmatic-prepare-env = {
      description = "Prepare env for borgmatic from SOPS secrets";
      onFailure = [ "borgmatic-alert.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = prepareEnvScript;
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Main borgmatic backup service
    systemd.services.borgmatic = {
      description = "Run borgmatic backup";
      after = [ "network-online.target" "borgmatic-prepare-env.service" ];
      requires = [ "network-online.target" "borgmatic-prepare-env.service" ];
      onFailure = [ "borgmatic-alert.service" ];
      environment = { };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "borgmatic-wrapper" ''
          export BORG_PASSPHRASE="$(cat ${config.sops.secrets."borg/password".path})"
          export BORG_REPO="$(cat ${config.sops.secrets."borg/repo".path})"
          export BORG_RSH="$(cat ${config.sops.secrets."borg/rsh".path})"
          export PATH=${lib.makeBinPath [ pkgs.docker pkgs.bash pkgs.borgmatic pkgs.borgbackup pkgs.coreutils ]}:$PATH

          ./backup.sh
          ${pkgs.borgmatic}/bin/borgmatic init --encryption=repokey-blake2 /mnt/hetzner-box/backup/nixcz/borgmatic
          ${pkgs.borgmatic}/bin/borgmatic -c /etc/borgmatic/config-seafile.yml --verbosity 1 --syslog-verbosity 1

          ${pkgs.borgmatic}/bin/borgmatic init --encryption=repokey-blake2 /mnt/nas/backup/immich
          ${pkgs.borgmatic}/bin/borgmatic -c /etc/borgmatic/config-immich.yml --verbosity 1 --syslog-verbosity 1
        '';
        WorkingDirectory = "/home/${vars.user}/git/seafile-docker-ce";
      };
    };

    # Daily timer
    systemd.timers.borgmatic = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    # Restore service
    systemd.services.borgmatic-restore = {
      description = "Restore latest Immich backup from Hetzner";
      after = [ "network-online.target" "borgmatic-prepare-env.service" ];
      requires = [ "network-online.target" "borgmatic-prepare-env.service" ];
      onFailure = [ "borgmatic-alert.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "echo alert"; #borgRestoreScript;
      };
    };

    #Alert notifications
    systemd.services.borgmatic-alert = {
      description = "Notify on Borgmatic Failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "echo alert"; #alertScript;
      };
    };
  };
}
