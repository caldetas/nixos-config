#
#  System Notifications
#

{ config, lib, pkgs, vars, host, ... }:


let
  LIBRARY_PATH =
    if config.networking.hostName != "nixcz"
    then "./library"
    else "/mnt/hetzner-box/immich-library";
  VERSION = "release"; #"v1.135.0";
  dbPassword =
    if config ? sops.secrets."server/db-password".path
    then "cat ${config.sops.secrets."server/db-password".path}"
    else "echo passwd";

in
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

    systemd.tmpfiles.rules = [ "d /var/lib/immich 0755 root root - -" ];

    systemd.services.immich-fetch-compose = {
      description = "Fetch latest Immich docker-compose.yml";
      before = [ "immich.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.curl}/bin/curl -L -o /var/lib/immich/docker-compose.yml \
            https://github.com/immich-app/immich/releases/download/${VERSION}/docker-compose.yml
        '';
      };
    };


    systemd.services.immich = {
      description = "Immich photo server using docker-compose";
      after = [ "docker.service" "immich-fetch-compose.service" ];
      requires = [ "immich-fetch-compose.service" ];
      wantedBy = [ "multi-user.target" ];

      #write env file to specify the locations
      preStart = ''
            cat > /var/lib/immich/.env <<EOF
        UPLOAD_LOCATION=${LIBRARY_PATH}
        DB_DATA_LOCATION=./postgres
        TZ=Europe/Zurich
        IMMICH_VERSION=${VERSION} #update automatically: release
        DB_PASSWORD=$(${dbPassword})
        DB_USERNAME=postgres
        DB_DATABASE_NAME=immich
        EOF
      '';
      serviceConfig = {
        ExecStart = "${pkgs.docker}/bin/docker compose -f /var/lib/immich/docker-compose.yml up -d";
        ExecStop = "${pkgs.docker}/bin/docker compose -f /var/lib/immich/docker-compose.yml down";
        WorkingDirectory = "/var/lib/immich";
        RemainAfterExit = true;
        Restart = "always";
        RestartSec = "5s";
      };
    };

  };
}
