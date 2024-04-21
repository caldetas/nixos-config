#
#  Specific system configuration settings for vm
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./vm
#   │       ├─ default.nix *
#   │       └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktops
#           └─ bspwm.nix
#

{ pkgs, config, lib, unstable, inputs, vars, modulesPath, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  #  users.users.${vars.user} = {              # System User
  #    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" ];
  #  };
  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.${vars.user}.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };

  boot = {
    # Boot Options
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
      };
      timeout = 1;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  #hyprland.enable = true;
  #  bspwm.enable = true;                          # Window Manager
  #  security.rtkit.enable = true;
  #gnome.enable = true;                          # Window Manager
  hyprland.enable = true; #did not work on vm                      # Window Manager
  #  laptop.enable = true;                          # Window Manager

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 16384; # memory.
      cores = 1;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # System Wide Packages
      hello # Test Package
      lolcat # Test Package
      cowsay # Test Package
    ];
  };

  services = {
    xserver = {
      enable = true;
      resolutions = [
        { x = 1920; y = 1080; }
        { x = 1920; y = 1200; }
        #        { x = 1600; y = 900; }
        #        { x = 3840; y = 2160; }
      ];
    };
  };
}
