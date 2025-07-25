#
#  System Notifications
#

{ config, lib, pkgs, vars, host, ... }:
with lib;
let
  isNixcz = host.hostName == "nixcz";
in

{

  options = {
    mailcow = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.mailcow.enable) {

    systemd.services.mailcow = {
      description = "Mailcow Docker Compose";
      after = [ "network-online.target" "docker.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/home/${vars.user}/git/mailcow-dockerized";
        ExecStartPre = "/run/current-system/sw/bin/test -d /home/${vars.user}/git/mailcow-dockerized";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        User = vars.user;
      };
    };

    services.nginx = {
      virtualHosts."mail.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain; # Use SSL only for real domain
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8088";
          proxyWebsockets = true;
        };
      };
    };
    systemd.services.mailcow-reload-after-cert-renewal = {
      wantedBy = [ "acme-finished.mail.caldetas.com.target" ];
      script = ''
        docker restart mailcowdockerized-dovecot-mailcow-1
        docker restart mailcowdockerized-postfix-mailcow-1
        docker restart mailcowdockerized-nginx-mailcow-1
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };
    #backup
    environment.etc."mailcow/backup.sh" = { text = builtins.readFile ../../rsc/config/mailcow/backup.sh; mode = "0755"; };
    environment.etc."mailcow/restore.sh" = { text = builtins.readFile ../../rsc/config/mailcow/restore.sh; mode = "0755"; };

    # backup service
    systemd.services.mailcow-backup = {
      description = "Run mailcow backup";
      stopIfChanged = false;
      unitConfig = {
        RefuseManualStart = false; # Allow timer to start it
        RefuseManualStop = false;
        DefaultDependencies = false; # Prevent link to default.target or rescue.target
      };
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      #      onFailure = [ ];
      wantedBy = [ ]; #  Don't auto-start on boot or rebuild
      #      environment = { };
      serviceConfig = {
        Type = "oneshot";
        Environment = "PATH=/run/wrappers/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        ExecStart = "${pkgs.bash}/bin/bash /etc/mailcow/backup.sh";
      };
    };

    # Daily timer
    systemd.timers.mailcow-backup = mkIf isNixcz {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:30:00";
        Persistent = true;
      };
    };
  };

  #new migration scripts in rsc/mailcow

  ##  OLD MIGRATION
  ## On old server
  #docker compose down
  #sudo tar czf mailcow-volumes.tar.gz -C /var/lib/docker/volumes $(docker volume ls -q | grep mailcowdockerized_)
  #sudo tar czf mailcow-config.tar.gz mailcow-dockerized/
  #
  ## Transfer files
  #scp *.tar.gz newserver:
  #
  ## On new server
  #tar xzf mailcow-config.tar.gz
  #sudo tar xzf mailcow-volumes.tar.gz -C /var/lib/docker/volumes
  #cd mailcow-dockerized && docker-compose up -d

  ### Installation
  #  Before enabling mailcow clone the repo to /home/caldetas/git/
  #  git clone https://github.com/mailcow/mailcow-dockerized /home/caldetas/git/mailcow-dockerized

}
