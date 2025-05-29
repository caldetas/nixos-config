#
#  GTK
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    home = {
      file.".face".source = ./face;
      #      file.".config/wall.png".source = ./wall.png;
      #      file.".background-image".source = ./wall.jpg;
      file.".background-image".source = ./stars.jpeg;
      file."stars.jpeg".source = ./stars.jpeg;
      file.".config/wall.mp4".source = ./wall.mp4;
      pointerCursor = {
        # System-Wide Cursor
        gtk.enable = true;
        #        name = "Dracula-cursors";
        name = "catppuccin-mocha-dark-cursors";
        #        package = pkgs.dracula-theme;
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 16;
      };
    };

    gtk = {
      # Theming
      enable = true;
      theme = {
        #        name = "Dracula";
        #        name = "Yaru-Dark";
        #        name = "Catppuccin-Macchiato-Compact-Blue-Dark";
        name = "Orchis-Dark-Compact";
        package = pkgs.orchis-theme;
        #        name = "Flat-Remix-Orange-Dark";
        #        package = pkgs.flat-remix-gtk;
        #        package = pkgs.yaru-theme;
        #        package = pkgs.dracula-theme;
        #        package = pkgs.catppuccin-gtk.override {
        #          accents = ["blue"];
        #          tweaks = [ "rimless" "black" ];
        #          size = "compact";
        #          variant = "mocha";
        #        };

      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
        #        name = "Flat-Remix";
        #        package = pkgs.flat-remix-icon-theme;
        #        name = "cat-mocha-mauve";
        #       package = pkgs.catppuccin-papirus-folders.override {
        #           flavor = "mocha";

        #           accent = "mauve";
        #         };
      };
      font = {
        name = "Ubuntu";
      };
    };
  };
  programs.dconf.enable = true;
  # Script to copy .face to AccountsService
  systemd.tmpfiles.rules = [
    "f+ /var/lib/AccountsService/users/${vars.user} 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${vars.user}\\n"
    "L+ /var/lib/AccountsService/icons/${vars.user} - - - - ${./face}"
  ];
}
