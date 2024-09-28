#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#

{ config, lib, system, pkgs, unstable, hyprland, inputs, vars, host, ... }:

let
  colors = import ../theming/colors.nix;
in
with lib;
with host;
{
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true; # Wayland Window Manager

    environment =
      let
        exec = "exec dbus-launch Hyprland";
      in
      {
        loginShellInit = ''
          if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
            ${exec}
          fi
        ''; # Start from TTY1

        variables = {
          #WLR_NO_HARDWARE_CURSORS="1";         # Needed for VM
          #WLR_RENDERER_ALLOW_SOFTWARE="1";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XCURSOR = "Catppuccin-Mocha-Dark-Cursors";
          XCURSOR_SIZE = 24;
        };
        sessionVariables =
          if hostName == "work" then {
            #GBM_BACKEND = "nvidia-drm";
            #__GL_GSYNC_ALLOWED = "0";
            #__GL_VRR_ALLOWED = "0";
            #WLR_DRM_NO_ATOMIC = "1";
            #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
            #_JAVA_AWT_WM_NONREPARENTING = "1";

            QT_QPA_PLATFORM = "wayland";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

            GDK_BACKEND = "wayland";
            WLR_NO_HARDWARE_CURSORS = "1";
            MOZ_ENABLE_WAYLAND = "1";
          } else {
            QT_QPA_PLATFORM = "wayland";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

            GDK_BACKEND = "wayland";
            WLR_NO_HARDWARE_CURSORS = "1";
            MOZ_ENABLE_WAYLAND = "1";
          };
        systemPackages = with pkgs; [
          grimblast # Screenshot
          hyprcursor # Cursor
          hyprpaper # Wallpaper
          nwg-look # Theme
          swaylock-effects # Lock Screen
          wl-clipboard # Clipboard
          wlogout # Logout
          wlr-randr # Monitor Settings
          xwayland # X session
        ];
      };

    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
          command = "${config.programs.hyprland.package}/bin/Hyprland"; # tuigreet not needed with exec-once hyprlock
          user = vars.user;
        };
      };
      vt = 7;
    };
    #
    programs = {
      hyprland = {
        enable = true;
        # set the flake package
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=yes
    ''; # Clamshell Mode

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    }; # Cache

    home-manager.users.${vars.user} =
      let
      in
      {
        wayland.windowManager.hyprland = with colors.scheme.default.hex; {
          enable = true;
          package = hyprland.packages.${pkgs.system}.hyprland;
          xwayland.enable = true;
          #                    plugins = [
          #                      hyprspace.packages.${pkgs.system}.Hyprspace
          #                    ];
          # plugin settings
          #          extraConfig = ''
          #            bind=SUPER,Tab,overview:toggle
          #            plugin:overview:panelHeight=150
          #            plugin:overview:drawActiveWorkspace=false
          #            plugin:overview:gapsIn=3
          #            plugin:overview:gapsOut=6
          #          '';
          settings = {
            general = {
              border_size = 2;
              gaps_in = 3;
              gaps_out = 6;
              "col.active_border" = "0x99${active}";
              "col.inactive_border" = "0x66${inactive}";
              resize_on_border = true;
              hover_icon_on_border = false;
              layout = "dwindle";
            };
            decoration = {
              rounding = 6;
              active_opacity = 1;
              inactive_opacity = 1;
              fullscreen_opacity = 1;
              drop_shadow = false;
            };
            monitor = [
              ",preferred,auto,1,mirror,${toString mainMonitor}"
            ] ++ (if hostName == "libelula" then [
              "${toString mainMonitor},1920x1080@60,0x0,1"
              "${toString secondMonitor},1920x1080@60,1920x0,1"
            ] else if hostName == "onsite-gnome" then [
              "${toString mainMonitor},1920x1080@60,0x0,1"
              "${toString secondMonitor},1920x1200@60,1920x0,1"
              "${toString thirdMonitor},1920x1200@60,3840x0,1"
            ] else [
              "${toString mainMonitor},1920x1080@60,0x0,1"
            ]);
            workspace =
              if (hostName == "libelula" && secondMonitor != "") then [
                "1, monitor:${toString mainMonitor}"
                "2, monitor:${toString secondMonitor}"
                "3, monitor:${toString mainMonitor}"
                "4, monitor:${toString secondMonitor}"
                "5, monitor:${toString mainMonitor}"
                "6, monitor:${toString secondMonitor}"
                "7, monitor:${toString mainMonitor}"
                "8, monitor:${toString secondMonitor}"
              ] else if hostName == "onsite-gnome" then [
                "1, monitor:${toString mainMonitor}"
                "2, monitor:${toString secondMonitor}"
                "3, monitor:${toString thirdMonitor}"
                "4, monitor:${toString secondMonitor}"
                "5, monitor:${toString thirdMonitor}"
                "6, monitor:${toString secondMonitor}"
                "7, monitor:${toString thirdMonitor}"
              ] else [
                "1, monitor:${toString mainMonitor}"
                "2, monitor:${toString mainMonitor}"
                "3, monitor:${toString mainMonitor}"
                "4, monitor:${toString mainMonitor}"
                "5, monitor:${toString mainMonitor}"
                "6, monitor:${toString mainMonitor}"
                "7, monitor:${toString mainMonitor}"
                "8, monitor:${toString mainMonitor}"
              ];

            animations = {
              enabled = false;
              bezier = [
                "overshot, 0.05, 0.9, 0.1, 1.05"
                "smoothOut, 0.5, 0, 0.99, 0.99"
                "smoothIn, 0.5, -0.5, 0.68, 1.5"
                "rotate,0,0,1,1"
              ];
              animation = [
                "windows, 1, 4, overshot, slide"
                "windowsIn, 1, 2, smoothOut"
                "windowsOut, 1, 0.5, smoothOut"
                "windowsMove, 1, 3, smoothIn, slide"
                "border, 1, 5, default"
                "fade, 1, 4, smoothIn"
                "fadeDim, 1, 4, smoothIn"
                "workspaces, 1, 4, default"
                "borderangle, 1, 20, rotate, loop"
              ];
            };
            cursor = {
              no_hardware_cursors = true;
            };
            input = {
              kb_layout = "ch";
              # kb_layout=us,us
              # kb_variant=,dvorak
              # kb_options=caps:ctrl_modifier
              kb_options = "caps:escape";
              follow_mouse = 2;
              repeat_delay = 250;
              numlock_by_default = 1;
              accel_profile = "flat";
              sensitivity = 0.8;
              touchpad =
                if hostName == "libelula" || hostName == "onsite-gnome" || hostName == "oldie" then {
                  natural_scroll = true;
                  scroll_factor = 0.2;
                  middle_button_emulation = true;
                  tap-to-click = true;
                } else { };
            };
            gestures =
              if hostName == "libelula" || hostName == "onsite-gnome" || hostName == "oldie" then {
                workspace_swipe = true;
                workspace_swipe_fingers = 3;
                workspace_swipe_distance = 100;
                workspace_swipe_create_new = true;
              } else { };

            dwindle = {
              pseudotile = false;
              force_split = 2;
              preserve_split = true;
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              mouse_move_enables_dpms = true;
              mouse_move_focuses_monitor = true;
              key_press_enables_dpms = true;
              background_color = "0x111111";
            };
            debug = {
              damage_tracking = 2;
            };
            bindm = [
              "SUPER,mouse:272,movewindow"
              "SUPER,mouse:273,resizewindow"
            ];
            bind = [

              "SUPER,Return,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal}"
              "SUPER,B,exec,brave"
              "SUPER,I,exec,idea-ultimate"
              "SUPER,Q,killactive,"
              "SUPER,L,exec,swaylock"
              "SUPER,E,exec,thunar"
              "SUPER,H,togglefloating,"
              "SUPER,Space,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"
              "SUPER,SUPER_L,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"
              "SUPER,Escape,exec,wlogout"
              "SUPER,P,pseudo,"
              "SUPER,F,fullscreen,"
              "SUPER,R,forcerendererreload"
              "SUPERSHIFT,R,exec,hyprctl reload"
              "SUPER,T,exec,kitty"
              "SUPER,left,movefocus,l"
              "SUPER,right,movefocus,r"
              "SUPER,up,movefocus,u"
              "SUPER,down,movefocus,d"
              "SUPERSHIFT,left,movewindow,l"
              "SUPERSHIFT,right,movewindow,r"
              "SUPERSHIFT,up,movewindow,u"
              "SUPERSHIFT,down,movewindow,d"
              "SUPER,Tab,cyclenext,"
              "SUPER,Tab,bringactivetotop,"
              "CTRLALTSHIFT,1,movetoworkspace,1"
              "CTRLALTSHIFT,2,movetoworkspace,2"
              "CTRLALTSHIFT,3,movetoworkspace,3"
              "CTRLALTSHIFT,4,movetoworkspace,4"
              "CTRLALTSHIFT,5,movetoworkspace,5"
              "CTRLALTSHIFT,6,movetoworkspace,6"
              "CTRLALTSHIFT,7,movetoworkspace,7"
              "CTRLALTSHIFT,8,movetoworkspace,8"
              "CTRLALTSHIFT,9,movetoworkspace,9"
              "CTRLALTSHIFT,0,movetoworkspace,10"
              "CTRLALT,1,movetoworkspacesilent,1"
              "CTRLALT,2,movetoworkspacesilent,2"
              "CTRLALT,3,movetoworkspacesilent,3"
              "CTRLALT,4,movetoworkspacesilent,4"
              "CTRLALT,5,movetoworkspacesilent,5"
              "CTRLALT,6,movetoworkspacesilent,6"
              "CTRLALT,7,movetoworkspacesilent,7"
              "CTRLALT,8,movetoworkspacesilent,8"
              "CTRLALT,9,movetoworkspacesilent,9"
              "CTRLALT,0,movetoworkspacesilent,10"
              "SUPERSHIFT,1,movetoworkspace,1"
              "SUPERSHIFT,2,movetoworkspace,2"
              "SUPERSHIFT,3,movetoworkspace,3"
              "SUPERSHIFT,4,movetoworkspace,4"
              "SUPERSHIFT,5,movetoworkspace,5"
              "SUPERSHIFT,6,movetoworkspace,6"
              "SUPERSHIFT,7,movetoworkspace,7"
              "SUPERSHIFT,8,movetoworkspace,8"
              "SUPERSHIFT,9,movetoworkspace,9"
              "SUPERSHIFT,0,movetoworkspace,10"
              "SUPERSHIFT,1,movetoworkspacesilent,1"
              "SUPERSHIFT,2,movetoworkspacesilent,2"
              "SUPERSHIFT,3,movetoworkspacesilent,3"
              "SUPERSHIFT,4,movetoworkspacesilent,4"
              "SUPERSHIFT,5,movetoworkspacesilent,5"
              "SUPERSHIFT,6,movetoworkspacesilent,6"
              "SUPERSHIFT,7,movetoworkspacesilent,7"
              "SUPERSHIFT,8,movetoworkspacesilent,8"
              "SUPERSHIFT,9,movetoworkspacesilent,9"
              "SUPERSHIFT,0,movetoworkspacesilent,10"
              "CTRLALT,RIGHT,workspace,+1"
              "CTRLALT,LEFT,workspace,-1"
              "CTRLALTSHIFT,RIGHT,movetoworkspace,+1"
              "CTRLALTSHIFT,LEFT,movetoworkspace,-1"


              "SUPER,Z,layoutmsg,togglesplit"
              ",print,exec,${pkgs.grimblast}/bin/grimblast --notify --freeze --wait 1 copysave area ~/Pictures/$(date +%Y-%m-%dT%H%M%S).png"
              ",XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 5"
              ",XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 5"
              ",XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t"
              "SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
              ",XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
              ",XF86MonBrightnessDown,exec,sudo ${pkgs.light}/bin/light -U 5"
              ",XF86MonBrightnessUP,exec,sudo ${pkgs.light}/bin/light -A 5"
            ];
            binde = [
              "SUPERCTRL,right,resizeactive,60 0"
              "SUPERCTRL,left,resizeactive,-60 0"
              "SUPERCTRL,up,resizeactive,0 -60"
              "SUPERCTRL,down,resizeactive,0 60"
            ];
            bindl =
              if hostName == "libelula" || hostName == "onsite-gnome" || hostName == "oldie" then [
                ",switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh"
              ] else [ ];
            windowrulev2 = [
              "float,title:^(Volume Control)$"
              "keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$"
              "noborder,class:^(firefox)$,title:^(Picture-in-Picture)$"
              "float, title:^(Picture-in-Picture)$"
              "size 24% 24%, title:(Picture-in-Picture)"
              "move 75% 75%, title:(Picture-in-Picture)"
              "pin, title:^(Picture-in-Picture)$"
              "float, title:^(Firefox)$"
              "size 24% 24%, title:(Firefox)"
              "move 74% 74%, title:(Firefox)"
              "pin, title:^(Firefox)$"
              "opacity 0.9, class:^(kitty)"
            ];
            exec-once = [
              #                              exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
              #                              exec-once=${pkgs.waybar}/bin/waybar
              #                              exec-once=${pkgs.eww}/bin/eww daemon
              #                              #exec-once=$HOME/.config/eww/scripts/eww        # When running eww as a bar
              #                              exec-once=${pkgs.blueman}/bin/blueman-applet
              #                              exec-once=${pkgs.swaynotificationcenter}/bin/swaync
              #                              exec-once=${pkgs.hyprpaper}/bin/hyprpaper
              #                              ${execute}
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "${pkgs.waybar}/bin/waybar"
              "${pkgs.eww}/bin/eww daemon"
              # "$HOME/.config/eww/scripts/eww" # When running eww as a bar
              "${pkgs.blueman}/bin/blueman-applet"
              "${pkgs.swaynotificationcenter}/bin/swaync"
              "${pkgs.hyprpaper}/bin/hyprpaper"
              "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
            ];
          };
        };

        home.file = {
          ".config/hypr/script/clamshell.sh" = {
            text = ''
              #!/bin/sh

              if grep open /proc/acpi/button/lid/LID/state; then
                ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, 1920x1080, 0x0, 1"
              else
                if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
                  ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, disable"
                else
                  ${pkgs.swaylock}/bin/swaylock -f
                  ${pkgs.systemd}/bin/systemctl suspend
                fi
              fi
            '';
            executable = true;
          };
          ".config/hypr/hyprpaper.conf".text = ''
            preload = /home/${vars.user}/stars.jpeg
            wallpaper = ${mainMonitor},/home/${vars.user}/stars.jpeg
            wallpaper = ${secondMonitor},/home/${vars.user}/stars.jpeg
            wallpaper = ${thirdMonitor},/home/${vars.user}/stars.jpeg
          '';
        };
      };
  };
}
