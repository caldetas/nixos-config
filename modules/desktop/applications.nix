{ config, pkgs, stable, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
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
    jq
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
    telegram-desktop
    teams-for-linux
    terraform
    vpsfree-client
    wpsoffice
    yarn
    yq
  ]
  ++ (with unstable; [ steam ])
  ++ (with stable; [ ]);

  flatpak = {
    enable = true;
    extraPackages = [
      "com.github.tchx84.Flatseal"
      "com.rtosta.zapzap"
      "org.signal.Signal"
      "ro.go.hmlendea.DL-Desktop"
      "com.seafile.Client"
      "com.stremio.Stremio"
      "ch.protonmail.protonmail-import-export-app"
    ];
  };
}
