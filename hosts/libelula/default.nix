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

{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

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
    import ../../modules/theming);

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.useOSProber = true;

  #  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      enableCryptodisk = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 20;
      default = 0;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  #  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.





  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system. (gnome?)
  #  services.xserver.enable = true;




  # Enable Desktop Environment.
  #      bspwm.enable = true;
  gnome.enable = true;
  #    kde.enable = true;
  #  hyprland.enable = true;

  #VPN
  surfshark.enable = true;

  #  environment.systemPackages = with unstable; [
  #  mesa #elden ring
  #  directx-headers # elden ring
  #  directx-shader-compiler #elden ring
  #  ];
  networking.interfaces.wlp0s20f3 = {
    useDHCP = true;
    mtu = 1380;
  };

}

