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
    #    texliveFull #for cv, large!
    tldr
    usbutils
    wget
    xdg-utils
    alsa-utils
    feh
    glmark2
    immich-go
    mpv
    pavucontrol
    pipewire
    usbimager
    vlc
    file-roller
    p7zip
    rsync
    unzip
    unrar
    zip
    sops
    python3
    tmux

    #cast
    gnome-network-displays
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi
    #          intel-media-driver  # or vaapiIntel for older Intel GPUs
    #                               libva-utils
    #                               intel-gpu-tools
  ] ++ (with stable; [ audacity ]);
  nixpkgs.config.permittedInsecurePackages = [
  ];
}
