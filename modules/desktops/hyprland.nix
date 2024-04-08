#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#

{ config, lib, pkgs, hyprland, vars, host, ... }:

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
    wlwm.enable = true;

    environment =
      let
        exec = "exec dbus-launch Hyprland";
      in
      {
        loginShellInit = ''
          if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
            ${exec}
          fi
        '';

        variables = {
          # WLR_NO_HARDWARE_CURSORS="1"; # Needed for VM
          # WLR_RENDERER_ALLOW_SOFTWARE="1";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
        };
        sessionVariables =
          if hostName == "work" then {
            # GBM_BACKEND = "nvidia-drm";
            # __GL_GSYNC_ALLOWED = "0";
            # __GL_VRR_ALLOWED = "0";
            # WLR_DRM_NO_ATOMIC = "1";
            # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            # _JAVA_AWT_WM_NONREPARENTING = "1";

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
          hyprpaper # Wallpaper
         swaylock-effects# Lock Screen
          wl-clipboard # Clipboard
          wlr-randr # Monitor Settings
          xwayland # X session
        ];
      };
    security.pam.services.swaylock = {
#      text = ''
#               auth sufficient pam_unix.so try_first_pass likeauth nullok
#               auth sufficient pam_fprintd.so
#               auth include login
#      '';
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

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=yes
    ''; # Clamshell Mode

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    home-manager.users.${vars.user} =
      let
        lid = if hostName != "onsite-gnome" then "LID0" else "LID";
        lockScript = pkgs.writeShellScript "lock-script" ''
          action=$1
          ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
          if [ $? == 1 ]; then
            if [ "$action" == "lock" ]; then
              ${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock
            elif [ "$action" == "suspend" ]; then
              ${pkgs.systemd}/bin/systemctl suspend
            fi
          fi
        '';
        swaylockConf=''
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
        macchiato= ''
        $rosewater = 0xfff4dbd6
        $flamingo  = 0xfff0c6c6
        $pink      = 0xfff5bde6
        $mauve     = 0xffc6a0f6
        $red       = 0xffed8796
        $maroon    = 0xffee99a0
        $peach     = 0xfff5a97f
        $green     = 0xffa6da95
        $teal      = 0xff8bd5ca
        $sky       = 0xff91d7e3
        $sapphire  = 0xff7dc4e4
        $blue      = 0xff8aadf4
        $lavender  = 0xffb7bdf8

        $text      = 0xffcad3f5
        $subtext1  = 0xffb8c0e0
        $subtext0  = 0xffa5adcb

        $overlay2  = 0xff939ab7s
        $overlay1  = 0xff8087a2
        $overlay0  = 0xff6e738d

        $surface2  = 0xff5b6078
        $surface1  = 0xff494d64
        $surface0  = 0xff363a4f

        $base      = 0xff24273a
        $mantle    = 0xff1e2030
        $crust     = 0xff181926
        '';
      in
      {
        imports = [
          hyprland.homeManagerModules.default
#          hyprlock.homeManagerModules.hyprlock
#          hypridle.homeManagerModules.hypridle
        ];

#        programs.hyprlock = {
#          enable = true;
#          general = {
#            hide_cursor = true;
#            no_fade_in = false;
#            disable_loading_bar = true;
#            grace = 0;
#          };
#          backgrounds = [{
#            monitor = "";
#            path = ".config/wall.jpg";
#            color = "rgba(25, 20, 20, 1.0)";
#            blur_passes = 1;
#            blur_size = 0;
#            brightness = 0.2;
#          }];
#          input-fields = [
#            {
#              monitor = "";
#              size = {
#                width = 250;
#                height = 60;
#              };
#              outline_thickness = 2;
#              dots_size = 0.2;
#              dots_spacing = 0.2;
#              dots_center = true;
#              outer_color = "rgba(0, 0, 0, 0)";
#              inner_color = "rgba(0, 0, 0, 0.5)";
#              font_color = "rgb(200, 200, 200)";
#              fade_on_empty = false;
#              placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
#              hide_input = false;
#              position = {
#                x = 0;
#                y = -120;
#              };
#              halign = "center";
#              valign = "center";
#            }
#          ];
#          labels = [
#            {
#              monitor = "";
#              text = "$TIME";
#              font_size = 120;
#              position = {
#                x = 0;
#                y = 80;
#              };
#              valign = "center";
#              halign = "center";
#            }
#          ];
#        };

#        services.hypridle = {
#          enable = true;
#          beforeSleepCmd = "${pkgs.systemd}/bin/loginctl lock-session";
#          afterSleepCmd = "${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on";
#          ignoreDbusInhibit = true;
#          lockCmd = "pidof ${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock || ${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock";
#          listeners = [
#            {
#              timeout = 300;
#              onTimeout = "${lockScript.outPath} lock";
#            }
#            {
#              timeout = 1800;
#              onTimeout = "${lockScript.outPath} suspend";
#            }
#          ];
#        };

        wayland.windowManager.hyprland = {
          enable = true;
          xwayland.enable = true;
          settings = {
            general = {
              border_size = 2;
              gaps_in = 3;
              gaps_out = 6;
              "col.active_border" = "0x994dbd6";
              "col.inactive_border" = "0x664dbd6";
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
            ] ++ (if hostName == "beelink" || hostName == "h310m" then [
              "${toString mainMonitor},1920x1080@60,1920x0,1"
              "${toString secondMonitor},1920x1080@60,0x0,1"
            ] else if hostName == "work" then [
              "${toString mainMonitor},1920x1080@60,0x0,1"
              "${toString secondMonitor},1920x1200@60,1920x0,1"
              "${toString thirdMonitor},1920x1200@60,3840x0,1"
            ] else if hostName == "xps" then [
              "${toString mainMonitor},3840x2400@60,0x0,2"
              "${toString secondMonitor},1920x1080@60,1920x0,1"
            ] else [
              "${toString mainMonitor},1920x1080@60,0x0,1"
            ]);
            workspace =
              if hostName == "beelink" || hostName == "h310m" then [
                "${toString mainMonitor},1"
                "${toString mainMonitor},2"
                "${toString mainMonitor},3"
                "${toString mainMonitor},4"
                "${toString secondMonitor},5"
                "${toString secondMonitor},6"
                "${toString secondMonitor},7"
                "${toString secondMonitor},8"
              ] else if hostName == "xps" || hostName == "work" then [
                "${toString mainMonitor},1"
                "${toString mainMonitor},2"
                "${toString mainMonitor},3"
                "${toString secondMonitor},4"
                "${toString secondMonitor},5"
                "${toString secondMonitor},6"
              ] else [ ];
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
            input = {
              kb_layout = "ch";
              # kb_layout=us,us
              # kb_variant=,dvorak
              # kb_options=caps:ctrl_modifier
              kb_options = "caps:escape";
              follow_mouse = 2;
              repeat_delay = 250;
              numlock_by_default = 0;
              accel_profile = "flat";
              sensitivity = 0.8;
              touchpad =
                if hostName != "work" || hostName == "xps" || hostName == "probook" then {
                  natural_scroll = true;
                  scroll_factor = 0.2;
                  middle_button_emulation = true;
                  tap-to-click = true;
                } else { };
            };
            gestures =
              if hostName != "work" || hostName == "xps" || hostName == "probook" then {
                workspace_swipe = true;
                workspace_swipe_fingers = 3;
                workspace_swipe_distance = 100;
                workspace_swipe_create_new = true;
                workspace_swipe_numbered = true;
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
#
            bindl = if hostName == "xps" || hostName != "work" then [
                ",switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh"
            ] else [ ] end;
            bind = [
                "SUPER,Return,exec,kitty"
                "SUPER,Q,killactive,"
                "ALT,F,killactive,"
                "#bind=SUPER,Escape,exit,"
                "#bind=SUPER,S,exec,systemctl suspend"
                "SUPER,L,exec,swaylock"
                "SUPER,E,exec,thunar"
                "SUPER,H,togglefloating,"
                "SUPER,Space,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"
                "bindr=SUPER,SUPER_L,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"
                "SUPER,P,pseudo,"
                "SUPER,F,fullscreen,"
                "SUPER,R,forcerendererreload"
                "SUPERSHIFT,R,exec,hyprctl reload"
                "SUPER,T,exec,kitty"
                "SUPER,left,movefocus,l"
                "SUPER,right,movefocus,r"
                "SUPER,up,movefocus,u"
                "SUPER,down,movefocus,d"
                "SUPER,Tab,cyclenext,"
                "SUPER,Tab,bringactivetotop,"
                "#bind=SUPER,Tab,exec,pypr toggle_minimized"
                "CTRL ALT SHIFT,1,movetoworkspace,1"
                "CTRL ALT SHIFT,2,movetoworkspace,2"
                "CTRL ALT SHIFT,3,movetoworkspace,3"
                "CTRL ALT SHIFT,4,movetoworkspace,4"
                "CTRL ALT SHIFT,5,movetoworkspace,5"
                "CTRL ALT SHIFT,6,movetoworkspace,6"
                "CTRL ALT SHIFT,7,movetoworkspace,7"
                "CTRL ALT SHIFT,8,movetoworkspace,8"
                "CTRL ALT SHIFT,9,movetoworkspace,9"
                "CTRL ALT SHIFT,0,movetoworkspace,10"
                "CTRL ALT,1,movetoworkspacesilent,1"
                "CTRL ALT,2,movetoworkspacesilent,2"
                "CTRL ALT,3,movetoworkspacesilent,3"
                "CTRL ALT,4,movetoworkspacesilent,4"
                "CTRL ALT,5,movetoworkspacesilent,5"
                "CTRL ALT,6,movetoworkspacesilent,6"
                "CTRL ALT,7,movetoworkspacesilent,7"
                "CTRL ALT,8,movetoworkspacesilent,8"
                "CTRL ALT,9,movetoworkspacesilent,9"
                "CTRL ALT,0,movetoworkspacesilent,10"
                "SUPERSHIFT,left,movewindow,l"
                "SUPERSHIFT,right,movewindow,r"
                "SUPERSHIFT,up,movewindow,u"
                "SUPERSHIFT,down,movewindow,d"
                "CTRLALT,right,workspace,+1"
                "CTRLALT,left,workspace,-1"
                "CTRLALT SHIFT,right,movetoworkspace,+1"
                "CTRLALT SHIFT,left,movetoworkspace,-1"
                "# bind=CTRL,right,resizeactive,20 0"
                "# bind=CTRL,left,resizeactive,-20 0"
                "# bind=CTRL,up,resizeactive,0 -20"
                "# bind=CTRL,down,resizeactive,0 20c"
                "SUPER,M,submap,resize"
                "submap=resize"
                "binde=,right,resizeactive,20 0"
                "binde=,left,resizeactive,-20 0"
                "binde=,up,resizeactive,0 -20"
                "binde=,down,resizeactive,0 20"
                "bind=,escape,submap,reset"
                "submap=reset"
                "SUPER,S,exec,spotify"
                "SUPER,Z,exec,pypr zoom"
                "SUPER,ESCAPE,exec,fish -c wlogout_uniqe"
            ];

            windowrulev2 = [
              "float,title:^(Volume Control)$"
              "keepaspectratio,class:^(brave)$,title:^(Picture-in-Picture)$"
              "noborder,class:^(brave)$,title:^(Picture-in-Picture)$"
              "float, title:^(Picture-in-Picture)$"
              "size 24% 24%, title:(Picture-in-Picture)"
              "move 75% 75%, title:(Picture-in-Picture)"
              "pin, title:^(Picture-in-Picture)$"
              "float, title:^(brave)$"
              "size 24% 24%, title:(brave)"
              "move 74% 74%, title:(brave)"
              "pin, title:^(brave)$"
              "opacity 0.9, class:^(kitty)"
            ];
            exec-once = [
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              #"${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock"
              "${pkgs.waybar}/bin/waybar"
              "${pkgs.eww-wayland}/bin/eww daemon"
              # "$HOME/.config/eww/scripts/eww" # When running eww as a bar
              "${pkgs.blueman}/bin/blueman-applet"
              "${pkgs.swaynotificationcenter}/bin/swaync"
              "${pkgs.hyprpaper}/bin/hyprpaper"
            ] ++ (if hostName != "work" then [
              "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
              #  "${pkgs.rclone}/bin/rclone mount --daemon gdrive: /GDrive --vfs-cache-mode=writes"
              # "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse /GDrive"
            ] else [ ]) ++ (if hostName == "xps" then [
              "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
            ] else [ ]);
          };
        };

        home.file = {
          ".config/hypr/script/clamshell.sh" = {
            text = ''
              #!/bin/sh

              if grep open /proc/acpi/button/lid/${lid}/state; then
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
            preload = ~/.config/wall.jpg
            wallpaper = ,~/.config/wall.jpg
          '';
        };
      };
  };
}