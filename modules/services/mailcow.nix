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
        WorkingDirectory = "/home/${vars.user}/git/mailcow-dockerized";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        Restart = "always";
        RestartSec = 10;
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

}
