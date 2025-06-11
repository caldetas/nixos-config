#
#  nginx
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  services.nginx = {
    virtualHosts = {
      "foto.wurstix.com" = {
        serverName = "foto.wurstix.com";
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
    };
  };
}
