#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  config = mkIf (config.server.enable) {

    # Persistent data directories
    systemd.tmpfiles.rules = [
      "d /mnt/nas/seafile-data 0755 root root -"
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

        memcached:
          image: memcached:latest
          container_name: seafile-memcached
          restart: always

        seafile:
          image: seafileltd/seafile-mc:latest
          container_name: seafile
          ports:
            - "8000:80"
            - "8082:8082"
          environment:
            - DB_HOST=db
            - DB_ROOT_PASSWD=seafile_root_pw
#            - SEAFILE_ADMIN_EMAIL=seafile@${vars.domain} #todo reactivate
            - SEAFILE_ADMIN_EMAIL=seafile@caldetas.com
            - SEAFILE_ADMIN_PASSWORD=admin_pw
            - SEAFILE_SERVER_HOSTNAME=seafile.${vars.domain}
            - SERVICE_URL=https://seafile.${vars.domain} #deprecated
            - FILE_SERVER_ROOT=https://seafile.${vars.domain}/seafhttp
            - ALLOWED_HOSTS=['.${vars.domain}']
            - MEMCACHED_HOST=memcached
          volumes:
            - /mnt/nas/seafile-data:/shared
          depends_on:
            - db
            - memcached
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
          ADMIN_EMAIL="admin@${vars.domain}"
          ADMIN_PASSWORD="admin_pw"
          FILE_SERVER_ROOT="https://seafile.${vars.domain}/seafhttp"

          echo "⏳ Waiting for container '$SEAFILE_CONTAINER' to start..."
          for i in {1..30}; do
            if $DOCKER ps --format '{{.Names}}' | grep -q "^$SEAFILE_CONTAINER$"; then
              break
            fi
            sleep 2
          done

          echo "🔍 Detecting Seafile path inside container..."
          SEAFILE_PATH=$($DOCKER exec $SEAFILE_CONTAINER sh -c 'ls -d /opt/seafile/seafile-server-* | sort -r | head -n1') || {
            echo "⚠️ Failed to detect SEAFILE_PATH, continuing anyway"
            exit 0
          }
          echo "📂 Using SEAFILE_PATH: $SEAFILE_PATH"

          echo "⏳ Waiting for settings.py to appear..."
          for i in {1..30}; do
            if $DOCKER exec $SEAFILE_CONTAINER test -f "$SEAFILE_PATH/seahub/seahub/settings.py"; then
              break
            fi
            sleep 2
          done

          if ! $DOCKER exec $SEAFILE_CONTAINER test -f "$SEAFILE_PATH/seahub/seahub/settings.py"; then
            echo "⚠️ settings.py not found, skipping patch."
            exit 0
          fi

          echo "⚙️ Patching settings.py if needed..."

          $DOCKER exec $SEAFILE_CONTAINER sh -c "
            set -e
            SETTINGS=\"$SEAFILE_PATH/seahub/seahub/settings.py\"

            echo \"CSRF_TRUSTED_ORIGINS = [\\\"https://seafile.${vars.domain}\\\"]\" >> \"\$SETTINGS\"

            # Append correct value
            echo \"FILE_SERVER_ROOT = \\\"https://seafile.${vars.domain}/seafhttp\\\"\" >> \"\$SETTINGS\"

            # Append correct value
            echo \"ALLOWED_HOSTS = [\\\".${vars.domain}\\\"]\" >> \"\$SETTINGS\"
          "
          echo "✅ Patch complete."
          exit 0
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
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;
            '';
          };
          "/seafhttp/" = {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = ''
              rewrite ^/seafhttp/(.*)$ /$1 break;
              proxy_set_header   Host $host;
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host $server_name;
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

  # Reinstall from scratch run this command
  #  cd /etc/seafile; sudo systemctl stop seafile; docker compose down; cd; sudo  rm -fr /var/lib/seafile; sudo rm -fr /etc/seafile; sudo rm -fr /mnt/nas/seafile*
  # TODO activate scripted init, for now you have to activate it in the admin profile and add the s to https paths
  # change initial password
}
