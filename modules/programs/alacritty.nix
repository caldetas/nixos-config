#
#  Terminal Emulator
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font = {
            normal.family = "UbuntuMono";
            bold = { style = "Regular"; };
            size = 11;
          };
          #          offset = {
          #            x = -1;
          #            y = 0;
          #          };
        };
      };
    };
  };
}
