#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./desktops
#       │   └─ default.nix
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./hardware
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       ├─ ./services
#       │   └─ default.nix
#       ├─ ./shell
#       │   └─ default.nix
#       └─ ./theming
#           └─ default.nix
#

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:
#let
#     pkgsM = import (builtins.fetchGit {
#         # Descriptive name to make the store path easier to identify
#         name = "my-old-nodeJs";
#         url = "https://github.com/NixOS/nixpkgs/";
#         ref = "refs/heads/nixpkgs-unstable";
#         rev = "9957cd48326fe8dbd52fdc50dd2502307f188b0d";
#     }) {};
#
#     nodeV16 = pkgsM.nodejs_16;
#in
#let
#strongswan = pkgs.strongswan.overrideAttrs (oldAttrs: {
#    patches = oldAttrs.patches ++ [
#      (pkgs.fetchpatch {
#        name = "fix-strongswan.patch";
#        url = "https://github.com/caldetas/nixpkgs/commit/e2573b8534b39b627d318e685268acf6b20ffce4.patch";
#        hash = "sha256-rClVIqSN8ZXKlakyyRK+p8uwiy3w9EvxDqwQlJyPX0c=";
#     })
#    ];
#  });
#in
{
  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ] ++ (
      import ../modules/desktops ++
      import ../modules/editors ++
      import ../modules/hardware ++
      import ../modules/programs ++
      import ../modules/services ++
      import ../modules/shell ++
      import ../modules/theming
    );



  sops.secrets.home-path = { };
  sops.secrets."surfshark/user" = { };
  sops.secrets."surfshark/password" = { };
  sops.secrets."my-secret" = {
    owner = "${vars.user}";
  };
  users.groups.secrets = { };

  users.users.${vars.user} = {
    # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "secrets" ];
  };

  #  time.timeZone = "America/Mexico_City";        # Time zone and Internationalisation
  time.timeZone = "Europe/Zurich"; # Time zone and Internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_CH.UTF-8/UTF-8"
      "es_MX.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "de_CH.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "sg";
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  fonts.packages = with pkgs; [
    # Fonts
    jetbrains-mono
    font-awesome # Icons
    ubuntu_font_family
  ];
  fonts.fontconfig.enable = lib.mkForce true;

  #  RSPI4 installer
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];


  #  networking.nameservers =  [ "1.1.1.1" "9.9.9.9"]; # privacy respecting nameserver for dns queries (cloudflare & quad9)
  networking.nameservers = [ "162.252.172.57" "149.154.159.92" ]; # Surfshark
  networking.hostName = host.hostName; # Hostname
  environment = {
    variables = {
      # Environment Variables
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };

    systemPackages = with unstable; [
      # System-Wide Packages
      # Terminal
      btop # Resource Manager
      ctop # Container Manager
      coreutils # GNU Utilities
      file # File Type
      git # Version Control
      glxinfo # OpenGL
      hwinfo # Hardware Info
      killall # Process Killer
      lshw # Hardware Info
      nano # Text Editor
      nix-tree # Browse Nix Store
      nixpkgs-fmt # Formatter for nix files
      pciutils # Manage PCI
      powertop # Power Manager
      psmisc # A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
      ranger # File Manager
      screen # Deatach
      tldr # Helper
      usbutils # Manage USB
      wget # Retriever
      xdg-utils # Environment integration

      # Video/Audio
      alsa-utils # Audio Control
      audacity # Audio Editor
      feh # Image Viewer
      glmark2 # OpenGL Benchmark
      mpv # Media Player
      pavucontrol # Audio Control
      pipewire # Audio Server/Control
      pulseaudio # Audio Server/Control
      usbimager # USB Writer
      vlc # Media Player

      # Apps
      appimage-run # Runs AppImages on NixOS
      google-chrome # Browser
      libreoffice # OpenOffice


      # File Management
      file-roller # Archive Manager
      pcmanfm # File Browser
      p7zip # Zip Encryption
      rsync # Syncer - $ rsync -r dir1/ dir2/
      unzip # Zip Files
      unrar # Rar Files
      zip # Zip

      # Security
      sops # Secrets Manager



      #Java
      gradle
      jetbrains.datagrip
      jetbrains.jdk
      jetbrains.pycharm-professional
      jre17_minimal
      python3

      # Apps
      brave
      discord
      firefox
      gedit
      git
      gimp
      gparted
      htop
      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
      neofetch
      netbird
      netbird-ui
      nodejs_20
      openvpn
      pandoc
      pinentry
      pdftk
      qbittorrent
      remmina
      spotify
      stremio
      strongswan
      telegram-desktop
      teams-for-linux
      thefuck
      wpsoffice
      yarn
    ] ++

    (with unstable; [
      #CV creation with Latex
      #      texlive.combined.scheme-full #latex
    ]) ++

    (with pkgs; [
      megasync
      steam
    ]);
  };

  programs = {
    gamemode.enable = true;
    java.enable = true;
    obs-studio.enable = true;
    steam.enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];
  services.pulseaudio.enable = false;
  services = {
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {
      # SSH
      enable = true;
      allowSFTP = true; # SFTP
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };
  };
  # Disable the tty1 getty so that GDM isn’t interfered with at login https://discourse.nixos.org/t/gnome-keyring-slow-start/58364/6
  systemd = {
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };
  };

  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.latest; # Enable Flakes
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config.allowUnfree = true; # Allow Proprietary Software.

  system = {
    # NixOS Settings
    stateVersion = "24.05"; # do not change
  };

  home-manager.users.${vars.user} = {
    # Home-Manager Settings
    home = {
      stateVersion = "24.05"; # do not change
    };
    programs = {
      home-manager.enable = true;
    };
  };
  flatpak.enable = true;
  flatpak = {
    # Flatpak Packages (see module options)
    extraPackages = [
      "com.github.tchx84.Flatseal"
      "io.github.mimbrero.WhatsAppDesktop"
      "org.signal.Signal"
    ];
  };

  services.strongswan.enable = true;
  services.netbird.enable = true;
  #services.tlp = {
  #    enable = true;
  #    settings = {
  #      TLP_DEFAULT_MODE = "BAT";
  #      TLP_PERSISTENT_DEFAULT = 1;
  #    };
  # };
  # services.power-profiles-daemon.enable = false; # Gnome Power Profiles conflict with TLP


  #Default Applications
  xdg.mime.defaultApplications = {
    "image/jpeg" = [ "image-roll.desktop" "feh.desktop" ];
    "image/png" = [ "image-roll.desktop" "feh.desktop" ];
    "text/plain" = "org.gnome.gedit.desktop";
    "text/html" = "brave-browser.desktop";
    "text/csv" = "org.gnome.gedit.desktop";
    "application/pdf" = "brave-browser.desktop";
    "application/zip" = "org.gnome.FileRoller.desktop";
    "application/x-tar" = "org.gnome.FileRoller.desktop";
    "application/x-bzip2" = "org.gnome.FileRoller.desktop";
    "application/x-gzip" = "org.gnome.FileRoller.desktop";
    "x-scheme-handler/http" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/https" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/about" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/mailto" = [ "brave-browser.desktop" ];
    "audio/mp3" = "vlc.desktop";
    "audio/x-matroska" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/mp4" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
  };

  environment.interactiveShellInit = ''
    alias buildVm='echo cd ${vars.location} \&\& git pull \&\& sudo nixos-rebuild build-vm --flake ${vars.location}#vm --show-trace && cd ${vars.location} && git pull && sudo nixos-rebuild build-vm --flake ${vars.location}#vm --show-trace'
    alias update='
      echo "Updating system..."
      echo "Commands:"
      echo "  git -C ${vars.location} pull"
      echo "  sudo nix flake update --flake ${vars.location}"
      echo "  sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace"

      git -C ${vars.location} pull
      sudo nix flake update --flake ${vars.location}
      sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace
    '

    alias rebuild='
      echo "Rebuilding system..."
      echo "Commands:"
      echo "  git -C ${vars.location} pull"
      echo "  sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace"

      git -C ${vars.location} pull
      sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace
    '
  '';

  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${vars.user}/MEGAsync/encrypt/nixos/keys.txt";
  system.activationScripts = {
    text =
      ''

# Set up sops secret keys
if [ -f /home/${vars.user}/MEGAsync/encrypt/nixos/keys.txt ] && [ ! -f /home/${vars.user}/.config/sops/age/keys.txt ]; then
    echo 'Copying sops keys to user folder';
    mkdir -p /home/${vars.user}/.config/sops/age || true
    cp /home/${vars.user}/MEGAsync/encrypt/nixos/keys.txt /home/${vars.user}/.config/sops/age/keys.txt || true

    # Check if sops encryption is working
    echo '
    Hey man! I am proof the encryption is working!

    My secret is here:
    ${config.sops.secrets.my-secret.path}

    My secret value is not readable, only in a shell environment:'  > /home/${vars.user}/secretProof.txt
    echo $(cat ${config.sops.secrets.my-secret.path}) >> /home/${vars.user}/secretProof.txt

    echo '
    My home-path on this computer:' >> /home/${vars.user}/secretProof.txt
    echo $(cat ${config.sops.secrets.home-path.path}) >> /home/${vars.user}/secretProof.txt

    #make openVpn surfshark login credential file
    if [ ! -d /home/${vars.user}/.secrets ]; then
    mkdir /home/${vars.user}/.secrets || true
    fi

    echo $(cat ${config.sops.secrets."surfshark/user".path}) > /home/${vars.user}/.secrets/openVpnPass.txt
    echo $(cat ${config.sops.secrets."surfshark/password".path}) >> /home/${vars.user}/.secrets/openVpnPass.txt

else
    echo 'not copying sops keys to user folder, already present';
fi;

# Set up automated scripts if not already set up. Abort if no script folder present.
if ! grep -q 'MEGAsync/work/programs'  /home/${vars.user}/.zshrc && [[ -d "/home/${vars.user}/MEGAsync/work/programs" ]] ;
then
   echo 'chmod +x ~/MEGAsync/work/programs/*' >> /home/caldetas/.zshrc
   echo 'export PATH=$PATH:/home/caldetas/MEGAsync/work/programs' >> /home/caldetas/.zshrc
   echo "set up scripts in zshrc";
else
   echo "not settings up scripts in zshrc, already present";
fi
                           '';

  };
  boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
    pname = "distro-grub-themes";
    version = "3.1";
    src = pkgs.fetchFromGitHub {
      owner = "AdisonCavani";
      repo = "distro-grub-themes";
      rev = "v3.1";
      hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
    };
    installPhase = "cp -r customize/nixos $out";
  };
}
