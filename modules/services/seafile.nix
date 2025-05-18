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
            - FILE_SERVER_ROOT=https://seafile.${vars.domain}/seafhttp
          volumes:
            - /mnt/nas/seafile-data:/shared
          depends_on:
            - db
    '';

    systemd.services.seafile = {
      enable = true;
      description = "Seafile via Docker Compose";
      after = [ "docker.service" ];
      wants = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        WorkingDirectory = "/etc/seafile";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        RemainAfterExit = true;
        Restart = "always";
        RestartSec = 5;

        # Run CSRF fix *after* containers have been started
        ExecStartPost = pkgs.writeShellScript "patch-seafile-csrf" ''
          set -e
          DOCKER=${pkgs.docker}/bin/docker
          SEAFILE_CONTAINER=seafile

          for i in {1..30}; do
            if $DOCKER ps --format '{{.Names}}' | grep -q "^$SEAFILE_CONTAINER$"; then
              break
            fi
            echo "Waiting for Seafile container to start..."
            sleep 2
          done

          for i in {1..30}; do
            if $DOCKER exec $SEAFILE_CONTAINER sh -c 'ls /opt/seafile/seafile-server-*/seahub/seahub/settings.py 1>/dev/null 2>&1'; then
              break
            fi
            echo "Waiting for settings.py to appear..."
            sleep 2
          done

          $DOCKER exec $SEAFILE_CONTAINER bash -c '
            set -e
            SEAFILE_PATH=$(ls -d /opt/seafile/seafile-server-* | tail -n1)
            SETTINGS="$SEAFILE_PATH/seahub/seahub/settings.py"
            echo "Using SEAFILE_PATH: $SEAFILE_PATH"

            if ! grep -q CSRF_TRUSTED_ORIGINS "$SETTINGS"; then
              echo "CSRF_TRUSTED_ORIGINS = [\"https://seafile.${vars.domain}\"]" >> "$SETTINGS"
            fi
            if ! grep -q FILE_SERVER_ROOT "$SETTINGS"; then
              echo "FILE_SERVER_ROOT = \"https://seafile.${vars.domain}/seafhttp\"" >> "$SETTINGS"
            fi

            echo "Ensuring Seafile backend is running..."
            "$SEAFILE_PATH/seafile.sh" start || echo "Seafile backend may already be running."

            echo "Restarting Seahub..."
            "$SEAFILE_PATH/seahub.sh" restart || echo "⚠️ Seahub restart failed or unnecessary, continuing anyway"
          '
        '';
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."seafile.${vars.domain}" = {
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain;
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8000";
            extraConfig = ''
              client_max_body_size 2000m;
            '';
          };
          "/seafhttp/" = {
            proxyPass = "http://127.0.0.1:8000/seafhttp/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;
              proxy_connect_timeout 36000;
              proxy_read_timeout 36000;
            '';
          };
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
