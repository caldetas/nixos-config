#
#  nginx
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  config = mkIf (config.server.enable) {
    services.nginx = {
      virtualHosts = {
        "_" = {
          default = true;
          locations."/" = {
            return = "302 https://duckduckgo.com";
          };
        };
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "info@${vars.domain}"; # Replace if needed
    };
  };
}
