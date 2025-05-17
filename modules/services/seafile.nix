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
        #        Restart = "always";
      };
    };
    systemd.services.seafile-csrf-fix = {
      description = "Patch CSRF_TRUSTED_ORIGINS into settings.py";
      after = [ "seafile.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "patch-seafile-csrf" ''
          set -e

          SEAFILE_CONTAINER=seafile
          DOCKER=${pkgs.docker}/bin/docker

          # Wait for container to exist and run
          for i in {1..30}; do
            if $DOCKER ps --format '{{.Names}}' | grep -q "^$SEAFILE_CONTAINER$"; then
              break
            fi
            echo "Waiting for Seafile container to start..."
            sleep 2
          done

          if ! $DOCKER ps --format '{{.Names}}' | grep -q "^$SEAFILE_CONTAINER$"; then
            echo "Container $SEAFILE_CONTAINER is not running"
            exit 1
          fi

          # Wait for settings.py to exist inside the container
          for i in {1..30}; do
            if $DOCKER exec $SEAFILE_CONTAINER test -f /opt/seafile/seafile-server-latest/seahub/seahub/settings.py; then
              break
            fi
            echo "Waiting for settings.py to appear inside the container..."
            sleep 2
          done

          if ! $DOCKER exec $SEAFILE_CONTAINER test -f /opt/seafile/seafile-server-latest/seahub/seahub/settings.py; then
            echo "settings.py not found after waiting"
            exit 1
          fi

          $DOCKER exec $SEAFILE_CONTAINER bash -c '
            SETTINGS=/opt/seafile/seafile-server-latest/seahub/seahub/settings.py
            if ! grep -q CSRF_TRUSTED_ORIGINS "$SETTINGS"; then
              echo "CSRF_TRUSTED_ORIGINS = [\"https://seafile.${vars.domain}\"]" >> "$SETTINGS"
              /opt/seafile/seafile-server-latest/seahub.sh restart
            fi
          '
        '';
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
