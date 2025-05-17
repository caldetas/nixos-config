#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  config = mkIf (config.server.enable) {
    packages.default = pkgs.writeShellScriptBin "start-seafile" ''
      docker run -d \
        --name seafile-mysql \
        -e MYSQL_ROOT_PASSWORD=db_root_password \
        -e MYSQL_DATABASE=seafile_db \
        -e MYSQL_USER=seafile \
        -e MYSQL_PASSWORD=seafile_pw \
        -v /var/lib/seafile/mysql-data:/var/lib/mysql \
        mariadb:10.5

      docker run -d \
        --name seafile \
        --link seafile-mysql:db \
        -e DB_HOST=db \
        -e DB_ROOT_PASSWD=db_root_password \
        -e SEAFILE_ADMIN_EMAIL=admin@example.com \
        -e SEAFILE_ADMIN_PASSWORD=admin_password \
        -v /var/lib/seafile/seafile-data:/shared \
        -p 8000:80 \
        seafileltd/seafile-mc:latest
    '';

    # For use as a NixOS module
    nixosModules.seafile = { config, pkgs, ... }: {
      systemd.services.seafile = {
        description = "Seafile Docker Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        serviceConfig = {
          ExecStart = "${pkgs.docker}/bin/docker compose -f /var/lib/seafile/docker-compose.yml up -d";
          ExecStop = "${pkgs.docker}/bin/docker compose -f /var/lib/seafile/docker-compose.yml down";
          WorkingDirectory = "/var/lib/seafile";
          Restart = "on-failure";
        };
      };
    };
  };
  services.nginx = {
    enable = true;
    virtualHosts."seafile.${vars.domain}" = {
      forceSSL = pkgs.lib.strings.hasInfix "." vars.domain; # Use SSL only for real domain
      enableACME = pkgs.lib.strings.hasInfix "." vars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
      };
    };
  };
}
