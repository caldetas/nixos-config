#
#  Specific system configuration settings for onsite-gnome
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./onsite-gnome
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

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.enableStrongSwan = true;

  # Enable the X11 windowing system. (gnome?)
  #  services.xserver.enable = true;




  # Enable the GNOME Desktop Environment.
  #  services.xserver.displayManager.gdm.enable = true;
  #  services.xserver.desktopManager.gnome.enable = true;
  gnome.enable = true;
  #hyprland.enable = true;
  #  bspwm.enable = true;
  #laptop.enable = true;                     # Laptop Modules



  #  # Enable CUPS to print documents.
  #  services.printing.enable = true;
  #
  #  # Enable sound with pipewire. (needed for gnome.enabled)
  #  sound.enable = true;
  #  hardware.pulseaudio.enable = false;
  #  security.rtkit.enable = true;
  #  services.pipewire = {
  #    enable = true;
  #    alsa.enable = true;
  #    alsa.support32Bit = true;
  #    pulse.enable = true;
  #  };
  #
  #  # Allow unfree packages
  #  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #  environment.systemPackages = with unstable; [
  #  mesa #elden ring
  #  directx-headers #elden ring
  #  directx-shader-compiler #elden ring
  #  ];

  services.printing.drivers = with pkgs; [
    cnijfilter2
  ];

  environment.interactiveShellInit = ''
    alias commit='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs --commit-lock-file && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs --commit-lock-file'
    alias update='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs'
    alias rebuild='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace'
    alias remminaResetRDP='rm -fr ~/.config/remmina && rm -f ~/.config/freerdp/known_hosts2'
  '';



  ### Adaptions to stay awake as a remote server.
  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.logind.lidSwitch = "ignore"; #Remmina stay accessible when lid is closed

  services.xserver.displayManager.gdm.autoSuspend = false;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
        {
            return polkit.Result.NO;
        }
    });
  '';
}

