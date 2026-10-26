{ config, pkgs, stable, unstable, gradient, ... }:

{
  environment.systemPackages = with pkgs; [
    google-chrome
    brave
    #    calibre #ebooks
    claude-code
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
    hypnotix
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
    #    terraform
    vlc
    vpsfree-client
    yarn
    yq
    gradient-cli-full
    #spring boot
    maven
  ]
  ++ (with unstable; [ steam ])
  #  ++ (with gradient; [ gradient-cli ])
  ++ (with stable; [ ]);

  flatpak = {
    enable = true;
    extraPackages = [
      "com.github.tchx84.Flatseal"
      "com.rtosta.zapzap"
      "org.signal.Signal"
      "ro.go.hmlendea.DL-Desktop"
      "com.stremio.Stremio"
      "com.surfshark.Surfshark"
    ];
  };
}
