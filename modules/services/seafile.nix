{ config, lib, pkgs, vars, ... }:

let
  inherit (lib) mkOption mkIf types;
  seafilePath = "/home/${vars.user}/git/seafile-docker-ce";
  envFile = "/home/${vars.user}/git/.env";
in
{
  options.seafile = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Dockerized Seafile service";
    };
  };

  config = mkIf config.seafile.enable {

    # Clone the repo if not already done (optional, or manage manually)
    systemd.services.seafile-setup = {
      description = "Initial clone of seafile-docker-ce repository";
      wantedBy = [ "multi-user.target" ];
      before = [ "docker-compose@seafile.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = vars.user;
        WorkingDirectory = "/home/${vars.user}/git";
        ExecStart = pkgs.writeShellScript "seafile-clone-once" ''
          set -e
          if [ ! -d "${dockerDir}/.git" ]; then
            ${pkgs.git}/bin/git clone https://github.com/caldetas/seafile-docker-ce.git ${seafilePath}
          fi
        '';

      };
    };

    # SOPS secret for .env
    sops.secrets."seafile/env" = {
      path = envFile;
      owner = vars.user;
      group = "users";
    };

    # Docker Compose service
    systemd.services."docker-compose@seafile" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "docker.service" ];
      serviceConfig = {
        WorkingDirectory = seafilePath;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        Restart = "always";
        User = vars.user;
        EnvironmentFile = envFile;
      };
    };

    # One-time setup: modify gunicorn + restart seahub
    systemd.services.seafile-postsetup = {
      description = "One-time Seafile config patch (gunicorn + CSRF)";
      after = [ "docker-compose@seafile.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          pkgs.writeShellScript "seafile-postsetup" ''
            set -e
            if [ ! -f "${seafilePath}/.setup" ]; then
            docker exec seafile sed -i 's/bind = "127.0.0.1:8000"/bind = "0.0.0.0:8000"/' /opt/seafile/conf/gunicorn.conf.py
            echo "CSRF_TRUSTED_ORIGINS = ['https://seafile.${vars.domain}']" >> ${seafilePath}/data/seafile/conf/seahub_settings.py
            docker exec seafile /opt/seafile/seafile-server-latest/seahub.sh restart
            touch ${seafilePath}/.setup
            fi
          '';
      };
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      virtualHosts."seafile.${vars.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8000";
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;
            '';
          };
          "/seafhttp" = {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = ''
              rewrite ^/seafhttp(.*)$ $1 break;
              client_max_body_size 0;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_connect_timeout 36000s;
              proxy_read_timeout 36000s;
              proxy_send_timeout 36000s;
              send_timeout 36000s;
            '';
          };
        };
      };
    };
  };
}
