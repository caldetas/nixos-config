#
#  Main system configuration.
#

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, host, ... }:


with lib;

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

  config = mkMerge [
    # Always-active base configuration
    {

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


      networking = {
        networkmanager = {
          enable = true;
          dns = lib.mkForce "none"; # Prevent NetworkManager from using DNS from the router (e.g., Fritzbox)
        };
        nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Fallback to Surfshark DNS if VPN fails
      };

      services.resolved = {
        enable = true;
        dnssec = "allow-downgrade"; # Optional: Enable DNSSEC if available
        domains = [ "~." ]; # Route all DNS queries through systemd-resolved (and via VPN)
        fallbackDns = [ "1.0.0.1" "1.1.1.1" ];
      };

      environment.variables = {
        TERMINAL = vars.terminal;
        EDITOR = vars.editor;
        VISUAL = vars.editor;
      };

      environment.systemPackages = with unstable; [
        # System-Wide Packages
        # Terminal
        btop # Resource Manager
        ctop # Container Manager
        coreutils # GNU Utilities
        dig # domain lookup
        file # File Type
        git # Version Control
        glxinfo # OpenGL
        htop
        hwinfo # Hardware Info
        killall # Process Killer
        lshw # Hardware Info
        nano # Text Editor
        neofetch
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
        usbimager # USB Writer
        vlc # Media Player

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

        # Misc
        python3
        thefuck
      ];

      home-manager.users.${vars.user} = {
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
      };

      system.stateVersion = "24.05";

      environment.interactiveShellInit = ''
        alias buildVm='echo cd ${vars.location} && git pull && sudo nixos-rebuild build-vm --flake ${vars.location}#vm --show-trace'
        alias update='echo Updating system... && git -C ${vars.location} pull && sudo nix flake update --flake ${vars.location} && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace'
        alias rebuild='echo Rebuilding system... && git -C ${vars.location} pull && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace'
      '';
    }

    # Conditional configuration for Desktop- User
    (mkIf (!config.server.enable) {
      environment.systemPackages = with unstable; [

        # Apps
        appimage-run # Runs AppImages on NixOS
        google-chrome # Browser
        libreoffice # OpenOffice



        #Java
        #      gradle
        #      jetbrains.datagrip
        jetbrains.idea-ultimate #      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
        #      jetbrains.jdk
        #      jetbrains.pycharm-professional
        #      jre17_minimal

        # Apps
        brave
        calibre
        discord
        firefox
        gedit
        ghostscript #pdf compression
        git
        gimp
        gparted
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
        texlive.combined.scheme-full #latex
      ]) ++

      (with pkgs; [
        megasync
        steam
      ]);

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

      flatpak = {
        enable = true;
        extraPackages = [
          "com.github.tchx84.Flatseal"
          "io.github.mimbrero.WhatsAppDesktop"
          "org.signal.Signal"
          "ro.go.hmlendea.DL-Desktop"
          "com.seafile.Client"
        ];
      };

      #    Default Applications
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

      programs = {
        gamemode.enable = true;
        java.enable = true;
        obs-studio.enable = true;
        steam.enable = true;
      };

      services = {
        printing.enable = true;
        pulseaudio.enable = false;
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        pipewire = {
          # Sound
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };
        openssh = {
          # SSH
          enable = true;
          allowSFTP = true;
          extraConfig = ''
            HostKeyAlgorithms +ssh-rsa
          '';
        };
      };
      # Disable the tty1 getty so that GDM isn’t interfered with at login https://discourse.nixos.org/t/gnome-keyring-slow-start/58364/6
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      #      systemd.services.NetworkManager-wait-online.enable = true;

    })
  ];
}
