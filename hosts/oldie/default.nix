#
#  Specific system configuration settings for libelula
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./libelula
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




  hyprland.enable = true;
  #  programs.hyprland.enable = true;
  #  programs.hyprland.nvidiaPatches = true;
  #  programs.hyprland.xwayland.enable = true;
  #
  #  environment.sessionVariables.LIBVA_DRIVER_NAME="nvidia";
  #  environment.sessionVariables.CLUTTER_BACKEND="wayland";
  #  environment.sessionVariables.XDG_SESSION_TYPE="wayland";
  #  environment.sessionVariables.QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
  #  environment.sessionVariables.MOZ_ENABLE_WAYLAND="1";
  #  environment.sessionVariables.GBM_BACKEND="nvidia-drm";
  #  environment.sessionVariables.__GLX_VENDOR_LIBRARY_NAME="nvidia";
  #  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS="1";
  #  environment.sessionVariables.WLR_BACKEND="vulkan";
  #  environment.sessionVariables.QT_QPA_PLATFORM="wayland";
  #  environment.sessionVariables.GDK_BACKEND="wayland";
  #  environment.sessionVariables.LIBSEAT_BACKEND="logind";
  #  environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE="1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
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

}

