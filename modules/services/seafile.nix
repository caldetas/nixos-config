#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  config = mkIf (config.server.enable) {

    # Persistent data directories
    systemd.tmpfiles.rules = [
      "d /var/lib/seafile/seafile-data 0755 root root -"
      "d /var/lib/seafile/mysql-data 0755 root root -"
    ];

    # Docker Compose file
    environment.etc."seafile/docker-compose.yml".text = ''

      services:
        db:
          image: mariadb:10.5
          container_name: seafile-mysql
          environment:
            - MYSQL_ROOT_PASSWORD=seafile_root_pw
            - MYSQL_DATABASE=seafile_db
            - MYSQL_USER=seafile
            - MYSQL_PASSWORD=seafile_pw
          volumes:
            - /var/lib/seafile/mysql-data:/var/lib/mysql

        seafile:
          image: seafileltd/seafile-mc:latest
          container_name: seafile
          ports:
            - "8000:80"
          environment:
            - DB_HOST=db
            - DB_ROOT_PASSWD=seafile_root_pw
            - SEAFILE_ADMIN_EMAIL=admin@${vars.domain}
            - SEAFILE_ADMIN_PASSWORD=admin_pw
            - SEAFILE_SERVER_HOSTNAME=seafile.${vars.domain}
            - SERVICE_URL=https://seafile.${vars.domain}
          volumes:
            - /var/lib/seafile/seafile-data:/shared
          depends_on:
            - db
          command: >
            sh -c "
              SETTINGS=/opt/seafile/seafile-server-latest/seahub/seahub/settings.py &&
              grep -q CSRF_TRUSTED_ORIGINS $$SETTINGS || \
              echo 'CSRF_TRUSTED_ORIGINS = [\"https://seafile.${vars.domain}\"]' >> $$SETTINGS &&
              /scripts/enterpoint.sh
            "
    '';

    # Systemd service for docker-compose
    systemd.services.seafile = {
      description = "Seafile via Docker Compose";
      after = [ "docker.service" ];
      wants = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        WorkingDirectory = "/etc/seafile";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        serviceConfig = {
          Type = "oneshot";
          # trusted domain fix
          # https://github.com/haiwen/seafile/issues/2118#issuecomment-537282437
          ExecStart = "${pkgs.docker}/bin/docker exec seafile bash -c '
      SETTINGS=/opt/seafile/seafile-server-latest/seahub/seahub/settings.py &&
      grep -q CSRF_TRUSTED_ORIGINS \"$SETTINGS\" || {
        echo \"CSRF_TRUSTED_ORIGINS = [\\\"https://seafile.${vars.domain}\\\"]\" >> \"$SETTINGS\"
        /opt/seafile/seafile-server-latest/seahub.sh restart
      }'";
        };
        #        Restart = "always";
      };
    };
    services.nginx = {
      enable = true;
      virtualHosts."seafile.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain;
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8000";
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "info@${vars.domain}";
    };
  };

  # Reinstall run this command
  #  cd /etc/seafile && sudo systemctl stop seafile && docker compose down && cd && sudo  rm -fr /var/lib/seafile && sudo rm -fr /etc/seafile
}
