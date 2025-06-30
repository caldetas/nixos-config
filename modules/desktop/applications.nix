{ config, pkgs, unstable, ... }:

{
  environment.systemPackages = with unstable; [
    appimage-run
    google-chrome
    libreoffice
    brave
    calibre
    discord
    exiftool
    firefox
    gedit
    ghostscript
    git
    gimp
    gparted
    netbird
    netbird-ui
    nodejs
    openvpn
    pandoc
    pinentry
    pdftk
    qbittorrent
    qemu
    remmina
    spotify
    stremio
    strongswan
    telegram-desktop
    teams-for-linux
    vpsfree-client
    wpsoffice
    yarn
    yq
  ] ++ (with unstable; [ megasync steam ]);
#  ] ++ (with pkgs; [ megasync steam ]);

  flatpak = {
    enable = true;
    extraPackages = [
      "com.github.tchx84.Flatseal"
      "io.github.mimbrero.WhatsAppDesktop"
      "org.signal.Signal"
      "ro.go.hmlendea.DL-Desktop"
      "com.seafile.Client"
      "ch.protonmail.protonmail-import-export-app"
    ];
  };
}
