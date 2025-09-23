#
#  System Notifications
#

{ config, lib, pkgs, vars, host, ... }:


let
  LIBRARY_PATH =
    if config.networking.hostName != "nixcz"
    then "./library"
    else "/mnt/hetzner-box/immich-library";
  VERSION = "v1.143.0"; #"release";
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
    environment.etc."immich/docker-compose.yml".text = builtins.readFile ../../rsc/config/immich/docker-compose.yml;
    environment.etc."immich/prometheus.yml".text = builtins.readFile ../../rsc/config/immich/prometheus.yml;
    environment.etc."immich/create-admin.sh" = {
      text = builtins.readFile ../../rsc/config/immich/create-admin.sh;
      mode = "0755"; # executable permissions
    };

    systemd.services.immich = {
      description = "Immich photo server using docker-compose";
      after = [ "docker.service" "immich-fetch-compose.service" ];
      wantedBy = [ "multi-user.target" ];

      #write env file to specify the locations
      preStart = ''
          set -euo pipefail

          # Write .env file line by line
          echo "UPLOAD_LOCATION=${LIBRARY_PATH}" > /var/lib/immich/.env
          echo "DB_DATA_LOCATION=./postgres" >> /var/lib/immich/.env
          echo "TZ=Europe/Zurich" >> /var/lib/immich/.env
          echo "IMMICH_VERSION=${VERSION}" >> /var/lib/immich/.env
          echo "DB_PASSWORD=$(${dbPassword})" >> /var/lib/immich/.env
          echo "DB_USERNAME=postgres" >> /var/lib/immich/.env
          echo "DB_DATABASE_NAME=immich" >> /var/lib/immich/.env
          echo "IMMICH_TELEMETRY_INCLUDE=all" >> /var/lib/immich/.env

          #preload images for qemu qcow2 images
          if [ -f /mnt/shared/immich-images.tar ]; then
            echo "Loading Docker images from shared folder..."
            ${pkgs.docker}/bin/docker load -i /mnt/shared/immich-images.tar
          else
            echo "Shared image tarball not found — skipping load."
          fi

        echo "Replacing docker-compose.yml..."
        rm -f /var/lib/immich/docker-compose.yml
        cp /etc/immich/docker-compose.yml /var/lib/immich/docker-compose.yml

        echo "Replacing prometheus.yml..."
        rm -f /var/lib/immich/prometheus.yml
        cp /etc/immich/prometheus.yml /var/lib/immich/prometheus.yml

        echo "Pulling latest images (optional)..."
        ${pkgs.docker}/bin/docker compose -f /var/lib/immich/docker-compose.yml pull || true
      '';

      serviceConfig = {
        ExecStart = "${pkgs.docker}/bin/docker compose up -d";
        ExecStop = "${pkgs.docker}/bin/docker compose -f /etc/immich/docker-compose.yml down";
        WorkingDirectory = "/var/lib/immich";
        RemainAfterExit = true;
        TimeoutStartSec = 600; #10min
        Restart = "always";
        RestartSec = "5s";
      };
    };
    systemd.services.mount-hetzner-box = {
      description = "Mount Hetzner Storage Box via SSHFS";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.mkForce (pkgs.writeShellScript "mount-hetzner-box" ''
          ${pkgs.coreutils}/bin/mkdir -p /mnt/hetzner-box
          ${pkgs.sshfs}/bin/sshfs \
            -o IdentityFile=/root/.ssh/hetzner_box_ed25519 \
            -o reconnect \
            -o allow_other \
            -o StrictHostKeyChecking=no \
            u466367@u466367.your-storagebox.de:/ /mnt/hetzner-box
        '');
      };
    };
  };
}
