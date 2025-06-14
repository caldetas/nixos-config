#
#  Gnome Configuration
#  Enable with "gnome.enable = true;"
#

{ config, lib, pkgs, vars, ... }:

with lib;
{
  options = {
    gnome = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gnome.enable) {
    programs = {
      zsh.enable = true;
      kdeconnect = {
        # GSConnect
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    services = {
      displayManager.gdm.enable = true; # Display Manager
      desktopManager.gnome.enable = true; # Desktop Environment
      xserver = {
        enable = true;
        xkb = {
          layout = "ch";
        };
      };
      libinput.enable = true;

      #XRDP settings for remmina
      xrdp.enable = true;
      #        xrdp.defaultWindowManager =  "gnome-remote-desktop";
      xrdp.defaultWindowManager = "/run/current-system/sw/bin/gnome-session";
      xrdp.openFirewall = false;
      gnome.gnome-remote-desktop.enable = true;

      udev.packages = with pkgs; [
        gnome-settings-daemon
      ];
    };


    environment = {
      systemPackages = with pkgs; [
        # System-Wide Packages
        adwaita-icon-theme
        dconf-editor
        gnome-themes-extra
        gnome-tweaks
      ];
      gnome.excludePackages = (with pkgs; [
        # Ignored Packages
        atomix
        epiphany
        geary
        gnome-characters
        gnome-contacts
        gnome-initial-setup
        gnome-tour
        hitori
        iagno
        tali
        yelp
      ]);
    };

    home-manager.users.${vars.user} = {
      dconf.settings = {
        "org/gnome/shell" = {
          favorite-apps = [
            "brave-browser.desktop"
            "kitty.desktop"
            "org-gnome-nautilus.desktop"
            "steam.desktop"
            "idea-ai.desktop"
            "vlc.desktop"
          ];
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicator@ubuntu.com"
            "trayiconsreloaded@selfmade.pl"
            "blur-my-shell@aunetx"
            "drive-menu@gnome-shell-extensions.gcampax.github.com"
            #            "user-theme@gnome-shell-extensions.gcampax.github.com"
            #            "dash-to-panel@jderose9.github.com"
            "just-perfection-desktop@just-perfection"
            "caffeine@patapon.info"
            "clipboard-indicator@tudmotu.com"
            "horizontal-workspace-indicator@tty2.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
            "battery-indicator@jgotti.org"
            "gsconnect@andyholmes.github.io"
            #            "pip-on-top@rafostar.github.com"
            "forge@jmmaranan.com"
            #             "dash-to-dock@micxgx.gmail.com"           # Alternative Dash-to-Panel
            #            "fullscreen-avoider@noobsai.github.com"   # Dash-to-Panel Incompatable
          ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          clock-show-weekday = true;
        };
        "org/gnome/desktop/peripherals/touchpad " = {
          tap-to-click = true;
        };
        "org/gnome/desktop/input-sources" = {
          sources = [ (lib.gvariant.mkTuple [ "xkb" "ch" ]) ];
          #            xkb-options = "compose:ralt";
        };
        "org/gnome/desktop/privacy" = {
          report-technical-problems = "false";
        };
        "org/gnome/desktop/calendar" = {
          show-weekdate = true;
        };
        "org/gnome/desktop/wm/preferences" = {
          action-right-click-titlebar = "toggle-maximize";
          action-middle-click-titlebar = "minimize";
          resize-with-right-button = true;
          mouse-button-modifier = "<super>";
          button-layout = ":minimize,close";
        };
        "org/gnome/desktop/wm/keybindings" = {
          maximize = [ "<super>up" ]; # Floating
          unmaximize = [ "<super>down" ];
          switch-to-workspace-left = [ "<ctrl><alt>left" ];
          switch-to-workspace-right = [ "<ctrl><alt>right" ];
          move-to-workspace-left = [ "<ctrl><shift><alt>left" ];
          move-to-workspace-right = [ "<ctrl><shift><alt>right" ];
          move-to-monitor-left = [ "<super><alt>left" ];
          move-to-monitor-right = [ "<super><alt>right" ];
          close = [ "<super>q" "<alt>f4" ];
          toggle-fullscreen = [ "<super>f" ];
        };

        "org/gnome/mutter" = {
          workspaces-only-on-primary = false;
          center-new-windows = true;
          edge-tiling = false; # Tiling
        };
        #        "org/gnome/shell/extensions/gsconnect" = {
        #          enabled = false;
        #        };
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<super>left" ]; # Floating
          toggle-tiled-right = [ "<super>right" ];
        };

        "org/gnome/settings-daemon/plugins/power" = {
          sleep-interactive-ac-type = "nothing";
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<super>t";
          command = "kitty";
          name = "open-terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<ctrl><alt>t";
          command = "kgx";
          name = "default-terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<super>e";
          command = "nautilus";
          name = "open-file-browser";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          binding = "<super>b";
          command = "brave";
          name = "open-browser";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
          binding = "<super>i";
          command = "idea-ai";
          name = "open-intellij";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
          binding = "<super>r";
          command = "sh -c 'flatpak run io.github.mimbrero.WhatsAppDesktop & telegram-desktop &'";
          name = "open-messaging-apps";
        };

        "org/gnome/shell/extension/dash-to-panel" = {
          # Set Manually
          panel-position = ''{"0":"top","1":"top"}'';
          panel-sizes = ''{"0":64,"1":64}'';
          panel-element-positions-monitors-sync = true;
          appicon-margin = 0;
          appicon-padding = 4;
          dot-position = "top";
          dot-style-focused = "solid";
          dot-style-unfocused = "dots";
          animate-appicon-hover = true;
          animate-appicon-hover-animation-travel = "{'simple': 0.14999999999999999, 'ripple': 0.40000000000000002, 'plank': 0.0}";
          isolate-monitors = true;
        };
        "org/gnome/shell/extensions/just-perfection" = {
          theme = true;
          activities-button = false;
          app-menu = false;
          clock-menu-position = 1;
          clock-menu-position-offset = 7;
        };
        "org/gnome/shell/extensions/caffeine" = {
          enable-fullscreen = true;
          restore-state = true;
          show-indicator = true;
          show-notification = false;
        };
        "org/gnome/shell/extensions/blur-my-shell" = {
          brightness = 0.9;
        };
        "org/gnome/shell/extensions/blur-my-shell/panel" = {
          customize = true;
          sigma = 0;
        };
        "org/gnome/shell/extensions/blur-my-shell/overview" = {
          customize = true;
          sigma = 0;
        };
        "org/gnome/shell/extensions/horizontal-workspace-indicator" = {
          widget-position = "left";
          widget-orientation = "horizontal";
          icons-style = "circles";
        };
        "org/gnome/shell/extensions/bluetooth-quick-connect" = {
          show-battery-icon-on = true;
          show-battery-value-on = true;
        };
        "org/gnome/shell/extensions/pip-on-top" = {
          stick = true;
        };
        "org/gnome/shell/extensions/forge" = {
          dnd-center-layout = "stacked";
          tiling-mode-enabled = true;
          window-gap-size = 8;
        };
        "org/gnome/shell/extensions" = {
          user-theme = "Orchis-Dark-Compact";
        };
        "org/gnome/shell/extensions/forge/keybindings" = {
          # Set Manually
          focus-border-toggle = true;
          float-always-on-top-enabled = false;
          window-focus-up = [ "<super><shift>up" ];
          window-focus-down = [ "<super><shift>down" ];
          window-focus-left = [ "<super>j" ];
          window-focus-right = [ "<super>k" ];
          window-move-up = [ "<ctrl><super>up" ];
          window-move-down = [ "<ctrl><super>down" ];
          window-move-left = [ "<ctrl><super>left" ];
          window-move-right = [ "<ctrl><super>right" ];
          window-swap-last-active = [ "@as []" ];
          window-toggle-float = [ "<ctrl><super>f" ];
        };
        "org/gnome/shell/extensions/dash-to-dock" = {
          # If Dock Preferred
          multi-monitor = true;
          dock-fixed = true;
          dash-max-icon-size = 64;
          custom-theme-shrink = true;
          transparency-mode = "fixed";
          background-opacity = 0.0;
          show-apps-at-top = true;
          show-trash = true;
          hot-keys = false;
          click-action = "previews";
          scroll-action = "cycle-windows";
        };
        "org/gnome/desktop/background" = {
          "picture-uri" = "/home/${vars.user}/.background-image";
          "picture-uri-dark" = "/home/${vars.user}/.background-image";
          "picture-options" = "spanned"; # default: zoom
          #               primary-color = "#3465a4";
          #               secondary-color = "#000000";
        };
        "org/gnome/desktop/screensaver" = {
          "picture-uri" = "/home/${vars.user}/.background-image";
          "picture-uri-dark" = "/home/${vars.user}/.background-image";
          primary-color = "#3465a4";
          secondary-color = "#000000";
        };
      };

      home.packages = with pkgs.gnomeExtensions; [
        tray-icons-reloaded
        blur-my-shell
        removable-drive-menu
        #        dash-to-panel
        #        battery-indicator-upower
        just-perfection
        caffeine
        clipboard-indicator
        #        workspace-indicator-2
        bluetooth-quick-connect
        gsconnect
        pip-on-top
        pop-shell
        forge
        fullscreen-avoider
        # dash-to-dock
      ];
      home.file.".config/autostart/seafile.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Seafile (Flatpak)
        Exec=flatpak run com.seafile.Client
        X-GNOME-Autostart-enabled=true
        Terminal=false
        Icon=seafile
        Categories=Network;
      '';
    };
    # Disable the tty1 getty so that GDM isn’t interfered with at login https://discourse.nixos.org/t/gnome-keyring-slow-start/58364/6
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
