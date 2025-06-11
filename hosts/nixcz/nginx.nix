#
#  nginx
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  services.nginx = {
    virtualHosts = {
      "immich.${vars.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:2283";
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
      "hochrheinisches.ch" = {
        serverName = "hochrheinisches.ch";
        forceSSL = true; # Redirect HTTP to HTTPS
        enableACME = true; # Automatically fetch a Let's Encrypt certificate
        locations."/" = {
          return = "301 http://hochrheinisches.clubdesk.ch$request_uri";
        };
      };
      "emanuelgraf.art" = {
        serverName = "emanuelgraf.art";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "301 https://emanuel-graf.kleio.com$request_uri";
        };
      };

      "wurstix.com" = {
        serverName = "wurstix.com";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "301 https://emanuel-graf.kleio.com$request_uri";
        };
      };
    };
  };
}
