{ config, pkgs, vars, ... }:

{
  # Enable Smart Card (PC/SC) daemon for hardware tokens (e.g., YubiKey)
  services.pcscd.enable = true;

  # Ensure D-Bus includes GCR for secure key management
  services.dbus.packages = [ pkgs.gcr ];

  # Enable GnuPG agent with pinentry support
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses; # Change to pinentry-gtk2 for GUI support
  };

  # Append lines to gpg-agent.conf and gpg.conf only if they don't exist
  # https://gist.github.com/mjul/56aa1494f65b7f9f38f1aba5b143f579
  #    systemd.tmpfiles.rules = [
  #      "L+ /home/${vars.user}/.gnupg/gpg-agent.conf - - - - allow-loopback-pinentry"
  #      "L+ /home/${vars.user}/.gnupg/gpg.conf - - - - use-agent"
  #      "L+ /home/${vars.user}/.gnupg/gpg.conf - - - - pinentry-mode loopback"
  #    ];

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
