{ config, pkgs, lib, vars, host, ... }:

let
  prepareEnvScript = pkgs.writeShellScript "prepare-borgmatic-env" ''
    mkdir -p /root/.ssh
    ${pkgs.openssh}/bin/ssh-keyscan -p 23 u466367.your-storagebox.de >> /root/.ssh/known_hosts
    ${pkgs.openssh}/bin/ssh-keyscan -p 23 u497568.your-storagebox.de >> /root/.ssh/known_hosts
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
    environment.etc."borgmatic/config.yaml".text = builtins.readFile ../../rsc/config/borg/borg.yml;

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
                    #          for terminal use
          #                    export BORG_PASSPHRASE="$(sudo more /run/secrets/borg/password)"
          #                    export BORG_REPO="$(sudo more /run/secrets/borg/repo)"
          #                    export BORG_RSH="ssh -i /home/caldetas/.ssh/hetzner_box_ed25519 -p23 -oBatchMode=yes" #ssh key has to be user readable
          #                    borgmatic borg key export --repository "ssh://$BORG_REPO"
                              export BORG_PASSPHRASE="$(cat ${config.sops.secrets."borg/password".path})"
                              export BORG_REPO="$(cat ${config.sops.secrets."borg/repo".path})"
                              export BORG_RSH="$(cat ${config.sops.secrets."borg/rsh".path})"
                              export PATH=${lib.makeBinPath [ pkgs.docker pkgs.bash pkgs.borgmatic pkgs.borgbackup pkgs.coreutils ]}:$PATH

                              ./backup.sh #mailcow server backup

                              mkdir -p /mnt/backup/nixcz/borgmatic || true
                              #${pkgs.borgmatic}/bin/borgmatic break-lock --repository "ssh://$BORG_REPO"
                              #${pkgs.borgmatic}/bin/borgmatic init --encryption=repokey-blake2 $BORG_REPO #uncomment to init repo, can lead to lock issues
                              ${pkgs.borgmatic}/bin/borgmatic --verbosity 1 --syslog-verbosity 1
        '';
        WorkingDirectory = "/home/${vars.user}/git/seafile-docker-ce";
      };
    };

    # Daily timer
    systemd.timers.borgmatic = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 02:03:00";
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
      };
      script = ''
        ${pkgs.curl}/bin/curl --ssl-reqd \
          --url 'smtp://mail.${vars.domain}.com:587' --insecure \
          --netrc /run/secrets/curl/.netrc \
          --mail-from 'info@${vars.domain}.com' \
          --mail-rcpt 'info@${vars.domain}.com' \
          --upload-file - <<EOF
        From: Server ${host.hostName} info@${vars.domain}.com
        To: Server Admin info@${vars.domain}.com
        Subject: Borgmatic backup failed on ${host.hostName}

        Please have a look..
        EOF
      '';
    };
    #Alert notifications
    systemd.services.borgmatic-test = {
      description = "Notify on Borgmatic Failure";
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        ${pkgs.curl}/bin/curl --ssl-reqd \
          --url 'smtp://mail.${vars.domain}.com:587' --insecure \
          --netrc /run/secrets/curl/.netrc \
          --mail-from 'info@${vars.domain}.com' \
          --mail-rcpt 'info@${vars.domain}.com' \
          --upload-file - <<EOF
        From: Server ${host.hostName} info@${vars.domain}.com
        To: Server Admin info@${vars.domain}.com
        Subject: Borgmatic backup failed on ${host.hostName}

        It runs locally..
        EOF
      '';
      restartIfChanged = true;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
