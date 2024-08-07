#
#  Bar
#

{ config, lib, host, system, pkgs, vars, home, ... }:
let
  swaylockConf = ''
    ignore-empty-password
    daemonize
    indicator
    clock
    screenshots

    effect-blur=11x11
    effect-compose=1110,-170;40%x-1;${vars.location}/modules/theming/rani.png
    effect-compose=120,-100;${vars.location}/modules/theming/warrior.png
    font=JetBrains Mono
    indicator-radius=80
    indicator-thickness=8
    timestr=%I:%M %p
    datestr=%F

    inside-color=#181926
    ring-color=#8bd5ca
    key-hl-color=#a6da95
    text-color=#cad3f5
    layout-text-color=#cad3f5
    layout-bg-color=#181926
    text-caps-lock-color=#cad3f5

    inside-clear-color=#f4dbd6
    ring-clear-color=#f0c6c6
    text-clear-color=#1e2030

    inside-ver-color=#91d7e3
    ring-ver-color=#7dc4e4
    text-ver-color=#1e2030

    inside-wrong-color=#ee99a0
    ring-wrong-color=#ed8796
    text-wrong-color=#1e2030
  '';
in
with lib;
with host;
{
  config = lib.mkIf (config.hyprland.enable) {
    home-manager.users.${vars.user} = {
      home.file = {
        ".config/swaylock/config".text = swaylockConf;
      };
    };
  };
}
