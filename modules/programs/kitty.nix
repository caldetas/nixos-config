#
#  Terminal Emulator
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      kitty = {
        enable = true;
        theme = "Afterglow";
        settings = {
          confirm_os_window_close=0;
          enable_audio_bell=0;
        };
      };
    };
  };
}
