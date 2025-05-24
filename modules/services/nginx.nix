#
#  hochrheinisches.ch
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  config = mkIf (config.server.enable) {
    services.nginx = {
      "_" = {
        default = true;
        listen = [
          { addr = "0.0.0.0"; port = 80; }
          { addr = "[::]"; port = 80; }
        ];
        locations."/" = {
          return = "302 https://duckduckgo.com";
        };
      };
      virtualHosts."hochrheinisches.ch" = {
        serverName = "hochrheinisches.ch";
        forceSSL = true; # Redirect HTTP to HTTPS
        enableACME = true; # Automatically fetch a Let's Encrypt certificate
        locations."/" = {
          return = "301 http://hochrheinisches.clubdesk.ch$request_uri";
        };
      };
    };
  };
};
}
