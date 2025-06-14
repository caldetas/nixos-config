#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{
  options = {
    server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf (config.seafile.enable) {
    home.file.".haveapi-client.yml".source = "/run/secrets/haveapi-client";
  };
}
