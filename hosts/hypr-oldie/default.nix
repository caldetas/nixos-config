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
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ../../modules/desktops/virtualisation/docker.nix
    ] ++
    ( import ../../modules/desktops ++
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
    { device = "/dev/disk/by-uuid/18fd3508-94a9-4d44-8b18-d7971fbb86c5";
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
#    sound.enable = true;
#    hardware.pulseaudio.enable = false;
#    security.rtkit.enable = true;
#    services.pipewire = {
#      enable = true;
#      alsa.enable = true;
#      alsa.support32Bit = true;
#      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
#    };


  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # # Enable Hyprland
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

   # Enable Theme
    environment.variables.GTK_THEME = "Catppuccin-Macchiato-Standard-Teal-Dark";
    environment.variables.XCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    environment.variables.XCURSOR_SIZE = "24";
    console = {
      earlySetup = true;
      colors = [
        "24273a"
        "ed8796"
        "a6da95"
        "eed49f"
        "8aadf4"
        "f5bde6"
        "8bd5ca"
        "cad3f5"
        "5b6078"
        "ed8796"
        "a6da95"
        "eed49f"
        "8aadf4"
        "f5bde6"
        "8bd5ca"
        "a5adcb"
      ];
    };

    # Setup Env Variables
    environment.variables.SPOTIFY_PATH = "${pkgs.spotify}/";
    environment.variables.JDK_PATH = "${pkgs.jdk11}/";
    environment.variables.NODEJS_PATH = "${pkgs.nodePackages_latest.nodejs}/";

    environment.variables.CI = "1";
    # environment.variables.CLIPBOARD_EDITOR = "hx";
    environment.variables.CLIPBOARD_NOAUDIO = "1";
    # environment.variables.CLIPBOARD_NOGUI = "1";
    # environment.variables.CLIPBOARD_NOPROGRESS = "1";
    # environment.variables.CLIPBOARD_NOREMOTE = "1";
    environment.variables.CLIPBOARD_SILENT = "1";

    # Change runtime directory size
    services.logind.extraConfig = "RuntimeDirectorySize=8G";


    # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;


    # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-font-patcher
  ];

 # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 3000 ];
  # networking.firewall.allowedUDPPorts = [ 3000 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable Encrypted Proxy DNS
  networking = {
    nameservers = [ "127.0.0.1" "::1"];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [ "cloudflare" "cloudflare-ipv6" "cloudflare-security" "cloudflare-security-ipv6" "adguard-dns-doh" "mullvad-adblock-doh" "mullvad-doh" "nextdns" "nextdns-ipv6" "quad9-dnscrypt-ipv4-filter-pri" "google" "google-ipv6" "ibksturm" ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  # Enable MAC Randomize
  # systemd.services.macchanger = {
  #   enable = true;
  #   description = "Change MAC address";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.macchanger}/bin/macchanger -r wlp0s20f3";
  #     ExecStop = "${pkgs.macchanger}/bin/macchanger -p wlp0s20f3";
  #     RemainAfterExit = true;
  #   };
  # };

  # Enable security services
  users.users.root.hashedPassword = "!";
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };
  security.apparmor = {
    enable = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };
  services.fail2ban.enable = true;
  # security.polkit.enable = true;
  services.usbguard = {
    enable = false;
#    dbus.enable = true;
#    implicitPolicyTarget = "block";
#    # FIXME: set yours pref USB devices (change {id} to your trusted USB device), use `lsusb` command (from usbutils package) to get list of all connected USB devices including integrated devices like camera, bluetooth, wifi, etc. with their IDs
#    rules = ''
#      allow id {id} # device 1
#      allow id {id} # device 2
#    '';
  };
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    updater.interval = "daily"; #man systemd.time
    updater.frequency = 12;
  };
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = {
        executable = "${lib.getBin pkgs.mpv}/bin/mpv";
        profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
      };
      imv = {
        executable = "${lib.getBin pkgs.imv}/bin/imv";
        profile = "${pkgs.firejail}/etc/firejail/imv.profile";
      };
      zathura = {
        executable = "${lib.getBin pkgs.zathura}/bin/zathura";
        profile = "${pkgs.firejail}/etc/firejail/zathura.profile";
      };
      discord = {
        executable = "${lib.getBin pkgs.discord}/bin/discord";
      };
    };
  };

  # Systemd services setup
  systemd.packages = with pkgs; [
    auto-cpufreq
  ];

  # Enable services
  services.geoclue2 = {
    enable = true;
    appConfig = {
      "gammastep" = {
        isAllowed = true;
        isSystem = false;
        users = [ "1000" ]; # FIXME: set your user id (to get user id use command 'id -u "your_user_name"')
      };
    };
  };
  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;
  # };
  programs.browserpass.enable = true;
  programs.direnv.enable = true;
  services.upower.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = with pkgs; [
  	xfce.xfconf
  	gnome2.GConf
  ];
  programs.light.enable = true;
  services.mpd.enable = true;
  programs.thunar.enable = true;
  services.tumbler.enable = true;
  services.fwupd.enable = true;
  services.auto-cpufreq.enable = true;
  security.pam.services.swaylock = {};
  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # USB Automounting
  services.gvfs.enable = true;
  # services.udisks2.enable = true;
  # services.devmon.enable = true;

  # Wayland compatibility with X
  # xdg.portal = {
  #   enable = true;
  #   wlr.enable = true;
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable container manager
  # Enable Docker
  # virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  # users.extraGroups.docker.members = [ "xnm" ];
  # Enable Podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
    extraGroups = [ "networkmanager" "input" "wheel" "video" "audio" "tss" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      spotify
      youtube-music
      discord
      tdesktop
      vscode
      brave
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Apply the overlay to the package set
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  # Override packages
  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = ["teal"]; };
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ]; # You can specify multiple accents here to output multiple themes
      size = "standard";
      variant = "macchiato";
    };
    discord = pkgs.discord.override {
      withOpenASAR = true;
      withTTS = true;
    };
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    mold
    gcc13
    jdk11
    go
    gopls
    delve
    (python311Full.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip]))
    nodePackages_latest.nodejs
    bun
    lua
    zig
    numbat

    python311Packages.python-lsp-server
    nodePackages_latest.nodemon
    nodePackages_latest.typescript
    nodePackages_latest.typescript-language-server
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.yaml-language-server
    nodePackages_latest.dockerfile-language-server-nodejs
    sumneko-lua-language-server
    marksman
    nil
    zls

    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
    evcxr #rust repl
    taplo #toml formatter & lsp
    cargo-deny
    cargo-audit
    cargo-update
    cargo-edit
    cargo-outdated
    cargo-license
    cargo-tarpaulin
    cargo-cross
    cargo-zigbuild
    cargo-nextest
    cargo-spellcheck
    cargo-modules
    cargo-bloat
    cargo-unused-features
    bacon
    lldb_16
    upx

    wasmedge
    wasmer
    lunatic
    wasmi
    # wasm3

    license-generator
    git-ignore
    just
    xh
    tgpt
    distrobox
    qemu
    wezterm
    cool-retro-term
    # mcfly # terminal history
    starship
    zellij
    helix
    git
    progress
    noti
    topgrade
    ripgrep
    rewrk
    wrk2
    procs
    tealdeer
    # skim #fzf better alternative in rust
    monolith
    aria
    # macchina #neofetch alternative in rust
    sd
    ouch
    duf
    du-dust
    fd
    jq
    gh
    trash-cli
    zoxide
    tokei
    fzf
    bat
    mdcat
    pandoc
    lsd
    gping
    viu
    tre-command
    felix-fm
    chafa

    podman-compose
    podman-tui

    lazydocker
    lazygit
    neofetch
    onefetch
    ipfetch
    cpufetch
    starfetch
    octofetch
    htop
    bottom
    btop
    kmon

    cmatrix
    pipes-rs
    rsclock
    cava
    figlet

    qutebrowser
    zathura
    mpv
    imv

    numix-icon-theme-circle
    colloid-icon-theme
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-cursors.macchiatoTeal

    at-spi2-atk
    pamixer
    pavucontrol
    qt6.qtwayland
    psi-notify
    poweralertd
    # wlsunset
    gammastep
    greetd.tuigreet
    swaylock-effects
    swayidle
    brightnessctl
    playerctl
    psmisc
    grim
    slurp
    imagemagick
    swappy
    ffmpeg_6-full
    # wl-screenrec
    wf-recorder
    wl-clipboard
    cliphist
    clipboard-jh
    xdg-utils
    wtype
    wlrctl
    hyprpicker
    pyprland
    waybar
    rofi-wayland
    dunst
    avizo
    wlogout
    wpaperd
    # swww
    gifsicle

    nuspell
    hyphen
    hunspell
    hunspellDicts.en_US
    hunspellDicts.uk_UA
    hunspellDicts.ru_RU

    vulnix       #scan command: vulnix --system
    clamav       #scan command: sudo freshcalm; clamscan [options] [file/directory/-]
    chkrootkit   #scan command: sudo chkrootkit

    # passphrase2pgp
    pass-wayland
    pass2csv
    passExtensions.pass-tomb
    passExtensions.pass-update
    passExtensions.pass-otp
    passExtensions.pass-import
    passExtensions.pass-audit
    tomb
    docker-credential-helpers
    pass-git-helper

    # vulkan-tools
    # opencl-info
    # clinfo
    # vdpauinfo
    # libva-utils
    # nvtop
    usbutils
    dig
    speedtest-rs

    # gnome.gnome-tweaks
    # gnome.gnome-shell
    # xsettingsd
    # gnome.gnome-shell-extensions
    # themechanger
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?







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
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  }

