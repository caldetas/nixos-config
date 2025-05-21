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

    #    systemd.services.mailcow = {
    #      description = "Mailcow Docker Compose Service";
    #      after = [ "docker.service" "network.target" ];
    #      wants = [ "docker.service" ];
    #      wantedBy = [ "multi-user.target" ];
    #
    #      serviceConfig = {
    #        WorkingDirectory = "/home/${vars.user}/git/mailcow-dockerized";
    #        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
    #        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    #        Restart = "always";
    #        RestartSec = 10;
    #        User = "${vars.user}";
    #      };
    #    };

    services.nginx = {
      enable = true;

      virtualHosts."mail.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain;
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;

        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; }
          { addr = "0.0.0.0"; port = 443; ssl = true; }
        ];

        root = "/var/www/empty"; # Required for ACME HTTP challenge

        locations."/" = {
          proxyPass = "http://127.0.0.1:8088";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host mail.caldetas.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
          '';
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
