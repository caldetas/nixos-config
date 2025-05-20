#
#  hochrheinisches.ch
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  config = mkIf (config.server.enable) {
    services.nginx = {
      enable = true;
      virtualHosts."hochrheinisches.ch" = {
        forceSSL = false; # No HTTPS in this case
        locations."/" = {
          return = "301 http://hochrheinisches.clubdesk.ch$request_uri";
        };
      };
    };
  };
}
