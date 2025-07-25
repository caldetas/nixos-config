{ config, lib, pkgs, vars, ... }:

let
  inherit (lib) mkOption mkIf types;
  seafilePath = "/home/${vars.user}/git/seafile-docker-ce";
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
    #make shure folder exists
    systemd.tmpfiles.rules = [
      "d /home/${vars.user}/git 0755 ${vars.user} users -"
      "d ${seafilePath} 0755 ${vars.user} users -"
    ];
    # Clone the repo if not already done (optional, or manage manually)
    systemd.services.seafile-setup = {
      description = "Initial clone of seafile-docker-ce repository";
      wantedBy = [ "multi-user.target" ];
      before = [ "seafile-docker-compose.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = vars.user;
        WorkingDirectory = "/home/${vars.user}/git";
        ExecStart = pkgs.writeShellScript "seafile-clone-once" ''
          set -e
          if [ ! -d "${seafilePath}/.git" ]; then
            ${pkgs.git}/bin/git clone https://github.com/caldetas/seafile-docker-ce.git ${seafilePath}
          fi
        '';

      };
    };

    # SOPS secret for .env
    sops.secrets."seafile/.env" = {
      group = "users";
      owner = "${vars.user}";
    };
    systemd.services.link-seafile-env = {
      wantedBy = [ "multi-user.target" "seafile-docker-compose.service" ];
      requires = [ "docker.service" "seafile-setup.service" ];
      after = [ "sops-nix.service" "seafile-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "link-env" ''
          ln -sf /run/secrets/seafile/.env /home/${vars.user}/git/seafile-docker-ce/.env
        '';
      };
    };
    # Docker Compose service
    systemd.services."seafile-docker-compose" = {
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "docker.service"
        "link-seafile-env.service"
        "seafile-setup.service"
      ];
      requires = [
        "network-online.target"
        "docker.service"
        "link-seafile-env.service"
        "seafile-setup.service"
      ];
      unitConfig.ConditionPathExists = "/run/secrets/seafile/.env";
      serviceConfig = {
        WorkingDirectory = seafilePath;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        # Restart = "always";
        User = vars.user;
      };
    };

    # One-time setup: modify gunicorn + restart seahub
    systemd.services.seafile-postsetup = {
      description = "One-time Seafile config patch (gunicorn + CSRF)";
      after = [ "seafile-docker-compose.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          pkgs.writeShellScript "seafile-postsetup" ''
            set -e
            if [ ! -f "${seafilePath}/.setup" ]; then
                echo "Waiting to execute seafile-postsetup.."
                ${pkgs.coreutils}/bin/sleep 30
                #${pkgs.docker}/bin/docker exec seafile sed -i 's/bind = "127.0.0.1:8000"/bind = "0.0.0.0:8000"/' /opt/seafile/conf/gunicorn.conf.py
                echo "CSRF_TRUSTED_ORIGINS = ['https://seafile.${vars.domain}']" | ${pkgs.coreutils}/bin/tee -a ${seafilePath}/data/seafile/conf/seahub_settings.py > /dev/null
                ${pkgs.docker}/bin/docker exec seafile /opt/seafile/seafile-server-latest/seahub.sh restart
                ${pkgs.coreutils}/bin/touch ${seafilePath}/.setup
            else
                echo "not executing seafile-postsetup.."
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
