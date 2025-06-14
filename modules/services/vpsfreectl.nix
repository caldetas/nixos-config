#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  config = mkIf (!config.server.enable) {
    systemd.user.services.link-haveapi-client = {
      description = "Symlink vpsfreectl haveapi-client.yml secret";
      after = [ "default.target" ]; # or `graphical-session.target` if using GUI

      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          /run/current-system/sw/bin/ln -sf /run/secrets/vpsfreectl/haveapi-client %h/.haveapi-client.yml
        '';
      };
    };

  };
}
