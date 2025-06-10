#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  options = {
    immich = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf (config.immich.enable) {

    systemd.tmpfiles.rules = [
      "d /var/lib/immich 0755 root root - -"
    ];

    systemd.services.immich-fetch-compose = {
      description = "Fetch latest Immich docker-compose.yml";
      before = [ "immich.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.curl}/bin/curl -L -o /var/lib/immich/docker-compose.yml \
            https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
        '';
      };
    };


    systemd.services.immich = {
      description = "Immich photo server using docker-compose";
      after = [ "docker.service" "immich-fetch-compose.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.docker}/bin/docker compose -f /var/lib/immich/docker-compose.yml up -d";
        ExecStop = "${pkgs.docker}/bin/docker compose -f /var/lib/immich/docker-compose.yml down";
        preStart = ''
              cat > /var/lib/immich/.env <<EOF
          UPLOAD_LOCATION=./library
          DB_DATA_LOCATION=./postgres
          TZ=Europe/Zurich
          IMMICH_VERSION=release
          DB_PASSWORD=postgres
          DB_USERNAME=postgres
          DB_DATABASE_NAME=immich
          EOF
        '';
        WorkingDirectory = "/var/lib/immich";
        Restart = "always";
        RestartSec = "5s";
      };
    };

  };
}
