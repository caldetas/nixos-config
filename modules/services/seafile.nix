{ config, lib, pkgs, vars, ... }:

with lib;

let
  seafileImage = "seafileltd/seafile-mc:11.0.13"; # Use pinned version
in
{
  config = mkIf config.server.enable {

    # Persistent volumes
    systemd.tmpfiles.rules = [
      "d /var/lib/seafile/seafile-data 0755 root root -"
      "d /var/lib/seafile/mysql-data 0755 root root -"
    ];

    # docker-compose config
    environment.etc."seafile/docker-compose.yml".text = ''
      version: '3'

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
          restart: unless-stopped

        seafile:
          image: ${seafileImage}
          container_name: seafile
          ports:
            - "8000:80"
            - "8082:8082"
          environment:
            - DB_HOST=db
            - DB_ROOT_PASSWD=seafile_root_pw
            - SEAFILE_ADMIN_EMAIL=admin@${vars.domain}
            - SEAFILE_ADMIN_PASSWORD=admin_pw
            - SEAFILE_SERVER_HOSTNAME=seafile.${vars.domain}
            - SERVICE_URL=https://seafile.${vars.domain}
            - FILE_SERVER_ROOT=https://seafile.${vars.domain}/seafhttp
          volumes:
            - /var/lib/seafile/seafile-data
          depends_on:
            - db
          restart: unless-stopped
    '';

    # Seafile systemd service
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
      };
    };

    # NGINX reverse proxy
    services.nginx = {
      enable = true;
      virtualHosts."seafile.${vars.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8000";
            extraConfig = "client_max_body_size 2000m;";
          };
          "/seafhttp/" = {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = ''
              rewrite ^/seafhttp/(.*)$ /$1 break;
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

    # SSL cert
    security.acme = {
      acceptTerms = true;
      defaults.email = "info@${vars.domain}";
    };
  };
}
