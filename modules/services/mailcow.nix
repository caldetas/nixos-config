#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
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
      systemd.services.mailcow-cert-sync = {
      User = "acme";
          group = "users";
        description = "Copy ACME certs for Mailcow";
        after = [ "acme-finished.service" ];
        wantedBy = [ "multi-user.target" ];
        postRun = "systemctl restart mailcow.service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "mailcow-cert-sync" ''
            set -euo pipefail

            install -d -m 0750 -o root -g mail /etc/ssl/mailcow
            install -m 0640 -o root -g mail /var/lib/acme/mail.caldetas.com/fullchain.pem /etc/ssl/mailcow/mailcow.pem
            install -m 0640 -o root -g mail /var/lib/acme/mail.caldetas.com/privkey.pem /etc/ssl/mailcow/mailcow.key
          '';
        };
      };

      # Optional: run on boot and on cert renewal
      systemd.timers.mailcow-cert-sync = {
      user = "acme";
          group = "users";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
      user.groups.mail = {};
  };

  ##  MIGRATION
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
