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
}
