{ config, pkgs, stable, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    google-chrome
    brave
    calibre #ebooks
    discord
    exiftool
    feh
    firefox
    gedit
    ghostscript
    git
    gimp
    glmark2
    gparted
    nodejs
    openvpn
    pandoc
    pinentry-curses
    pdftk
    qbittorrent
    qemu
    remmina
    seafile-client
    spotify
    telegram-desktop
    teams-for-linux
    terraform
    vlc
    vpsfree-client
    yarn
    yq

    #spring boot
    maven
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
      "com.stremio.Stremio"
    ];
  };
}
