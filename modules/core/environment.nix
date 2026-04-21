{ config, lib, pkgs, stable, unstable, vars, ... }:

{
  environment.variables = {
    TERMINAL = vars.terminal;
    EDITOR = vars.editor;
    VISUAL = vars.editor;
    TERM = vars.term;
  };

  environment.systemPackages = with unstable; [
    borgmatic
    btop
    ctop
    coreutils
    dig
    file
    git
    mesa-demos
    htop
    hwinfo
    jq
    killall
    kitty.terminfo
    lshw
    nano
    nix-tree
    nixpkgs-fmt
    openssl
    pciutils
    powertop
    psmisc
    ranger
    sshfs
    #    texliveFull #for cv, large!
    usbutils
    wget
    xdg-utils
    alsa-utils
    immich-go
    mpv
    pavucontrol
    pipewire
    usbimager
    file-roller
    p7zip
    rsync
    unzip
    unrar
    zip
    sops
    python3
    tmux
  ] ++ (with stable; [ audacity ]);
  nixpkgs.config.permittedInsecurePackages = [
  ];
}
