{ config, pkgs, vars, ... }:

{
  # Enable Smart Card (PC/SC) daemon for hardware tokens (e.g., YubiKey)
  services.pcscd.enable = true;

  # Ensure D-Bus includes GCR for secure key management
  services.dbus.packages = [ pkgs.gcr_4 ];

  # Enable GnuPG agent with pinentry support
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses; # Change to pinentry-gtk2 for GUI support
  };


  home-manager.users.${vars.user} = {
    home.file.".gnupg/gpg.conf" = {
      text = ''
        # Ensure gpg.conf has required settings
        use-agent
        pinentry-mode loopback
      '';
    };
  };
}
