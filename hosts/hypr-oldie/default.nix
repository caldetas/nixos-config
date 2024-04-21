#
#  Specific system configuration settings for hypr-oldie
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./hypr-oldie
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktops
#           ├─ bspwm.nix
#           └─ ./virtualisation
#               └─ docker.nix
#

{ pkgs, config, lib, unstable, inputs, vars, modulesPath, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ../../modules/desktops/virtualisation/docker.nix
    ] ++
    (import ../../modules/desktops ++
    import ../../modules/editors ++
    import ../../modules/hardware ++
    import ../../modules/programs ++
    import ../../modules/services ++
    import ../../modules/shell ++
    import ../../modules/theming
    );

  #  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  #  boot.initrd.kernelModules = [ ];
  #  boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
  #  boot.kernelParams = [ "i915.enable_guc=2" ];
  #  boot.kernelModules = [ "kvm-intel" ];
  #  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.plymouth = {
    enable = true;
    # logo = pkgs.fetchurl {
    #         url = "https://pluspng.com/img-png/black-lagoon-png-revy-1-png-1594-1080-anime-boysdjblack-lagoon-1594.png";
    #         sha256 = "e0CZmXTVIJv6BDXXYksTsncl9t/QGkYC/BavNy4fcnQ=";
    #       };
    font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
    themePackages = [ pkgs.catppuccin-plymouth ];
    theme = "catppuccin-macchiato";
  };


  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/18fd3508-94a9-4d44-8b18-d7971fbb86c5";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
  #  bspwm.enable = true;
  #  gnome.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };




  gnome.enable = true;
  #  programs.hyprland.enable = true;
  #  programs.hyprland.nvidiaPatches = true;
  #  programs.hyprland.xwayland.enable = true;
  #

  #VPN
  #  surfshark.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      libsForQt5.qt5ct
      libva
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.interactiveShellInit = ''
    alias update='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#hypr-oldie --show-trace --update-input nixpkgs && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs'
    alias rebuild='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#hypr-oldie --show-trace && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace'
  '';
}

