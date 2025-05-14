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
        forceSSL = pkgs.lib.strings.hasInfix "." vars.domain;
        enableACME = pkgs.lib.strings.hasInfix "." vars.domain;

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

        locations."/SOGo/" = {
          proxyPass = "http://127.0.0.1:8088/SOGo/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header x-webobjects-server-protocol HTTP/1.0;
            proxy_set_header x-webobjects-remote-host 127.0.0.1;
            proxy_set_header x-webobjects-server-name $host;
            proxy_set_header x-webobjects-server-port $server_port;
            proxy_set_header x-webobjects-server-url $scheme://$host;
            proxy_http_version 1.1;
          '';
        };
      };
    };
  };
}
