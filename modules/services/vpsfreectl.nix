#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:

with lib;
let
  isDesktop = !config.server.enable;
in
{
  config = mkMerge [
    (mkIf isDesktop {
      systemd.user.services.link-haveapi-client = {
        description = "Symlink vpsfreectl haveapi-client.yml secret";
        after = [ "graphical-session.target" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            /run/current-system/sw/bin/ln -sf /run/secrets/vpsfreectl/haveapi-client %h/.haveapi-client.yml
          '';
        };
      };
    })

    (mkIf (!isDesktop) {
      console.enable = true;
      systemd.services."getty@tty2".enable = lib.mkForce true;

      services.getty = {
        autologinUser = vars.user;
        extraArgs = [ "--noclear" ];
      };
    })
  ];
}
