#
#  nginx
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  config = mkIf (config.server.enable) {
    services.nginx = {
      virtualHosts = {
        "hochrheinisches.ch" = {
          serverName = "hochrheinisches.ch";
          forceSSL = true; # Redirect HTTP to HTTPS
          enableACME = true; # Automatically fetch a Let's Encrypt certificate
          locations."/" = {
            return = "301 http://hochrheinisches.clubdesk.ch$request_uri";
          };
        };

        "_" = {
          default = true;
          locations."/" = {
            return = "302 https://duckduckgo.com";
          };
        };
      };
    };
  };
}
