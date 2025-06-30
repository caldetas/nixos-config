{ config, lib, pkgs, unstable, vars, ... }:

{
  environment.variables = {
    TERMINAL = vars.terminal;
    EDITOR = vars.editor;
    VISUAL = vars.editor;
    TERM = vars.term;
  };

  environment.systemPackages = with unstable; [
    btop
    ctop
    coreutils
    dig
    file
    git
    glxinfo
    htop
    hwinfo
    killall
    kitty.terminfo
    lshw
    nano
    neofetch
    nix-tree
    nixpkgs-fmt
    pciutils
    powertop
    psmisc
    ranger
    screen
    sshfs
    tldr
    usbutils
    wget
    xdg-utils
    alsa-utils
    audacity
    feh
    glmark2
    immich-go
    mpv
    pavucontrol
    pipewire
    usbimager
    vlc
    file-roller
    pcmanfm
    p7zip
    rsync
    unzip
    unrar
    zip
    sops
    python3
  ];
}
