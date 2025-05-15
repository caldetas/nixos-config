#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:

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
