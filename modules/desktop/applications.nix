{ config, pkgs, stable, unstable, ... }:

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
    gradient-cli
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
    stremio-linux-shell
    telegram-desktop
    #    terraform
    vlc
    vpsfree-client
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
      "com.surfshark.Surfshark"
    ];
  };
}
