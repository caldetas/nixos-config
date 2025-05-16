#
#  Specific system configuration settings for server
#


{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

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
    import ../../modules/theming);

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.useOSProber = true;

  #  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  #  boot.loader = {
  #    grub = {
  #      enable = true;
  #      efiSupport = true;
  #      enableCryptodisk = true;
  #      device = "nodev";
  #      useOSProber = true;
  #      configurationLimit = 20;
  #      default = 0;
  #    };
  #    efi = {
  #      canTouchEfiVariables = true;
  #      efiSysMountPoint = "/boot";
  #    };
  #  };

  #  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.





  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  #  networking.networkmanager.enable = true;
  #  networking.networkmanager.enableStrongSwan = true;

  # Enable the X11 windowing system. (gnome?)
  #  services.xserver.enable = true;




  # Enable Desktop Environment.
  #      bspwm.enable = true;
  #  gnome.enable = true;
  #    kde.enable = true;
  #  hyprland.enable = true;

  #VPN
  #  surfshark.enable = true;

  #  environment.systemPackages = with unstable; [
  #  mesa #elden ring
  #  directx-headers # elden ring
  #  directx-shader-compiler #elden ring
  #  ];

  # You should only edit the lines below if you know what you are doing.

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # This is the server's hostname you chose during the order process. Feel free to change it.

  networking.hostName = "nixos";

  # We use the dhcpcd daemon to automatically configure your network. For IPv6 we need to make sure
  # that no temporary addresses (or privacy extensions) are used. Your server is required to use the
  # network data that is displayed in the Network tab in our client portal, otherwise your server will
  # loose internet access due to network filters that are in place.

  networking.dhcpcd.IPv6rs = true;
  networking.dhcpcd.persistent = true;
  networking.tempAddresses = "disabled";
  networking.interfaces.ens3.tempAddress = "disabled";

  # To allow you to properly use and access your VPS via SSH, we enable the OpenSSH server and
  # grant you root access. This is just our default configuration, you are free to remove root
  # access, create your own users and further secure your server.

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  networking.firewall.allowedTCPPorts = [ 22 80 443 8088 ];

  # Under normal circumstances we would listen to your server's cloud-init callback and mark the server
  # as installed at this point. As we don't deliver cloud-init with NixOS we have to use a workaround
  # to indicate that your server is successfully installed. You can remove the cronjob after the server
  # has been started the first time. It's no longer needed.

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "@reboot root sleep 30 && curl -L -XPOST -q https://portal.servinga.cloud/api/service/v1/cloud-init/callback > /dev/null 2>&1"
  ];

  # Please remove the hardcoded password from the configuration and set
  # the password using the "passwd" command after the first boot.

  users.users.root = {
    isNormalUser = false;
  };

  bitwarden.enable = true;
  mailcow.enable = true;
  server.enable = true;

}

