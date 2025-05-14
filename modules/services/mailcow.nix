#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  options = {
    mailcow = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.bitwarden.enable) {
    services.nginx = {
      enable = true;

      virtualHosts."mail.${vars.domain}" = {

        locations."/" = {
          proxyPass = "http://127.0.0.1:8088";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };
}
