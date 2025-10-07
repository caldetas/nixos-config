#
#  Specific system configuration settings for server
#


{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./borg.nix
      ./nginx.nix
      ../../modules/desktops/virtualisation/docker.nix
      ../configuration-server.nix
    ] ++
    (import ../../modules/desktops ++
    import ../../modules/editors ++
    import ../../modules/hardware ++
    import ../../modules/programs ++
    import ../../modules/services ++
    import ../../modules/shell ++
    import ../../modules/theming);


  #NAS storage mount
  environment.systemPackages = with pkgs; [ nfs-utils ];

  # To allow you to properly use and access your VPS via SSH, we enable the OpenSSH server and
  # grant you root access. This is just our default configuration, you are free to remove root
  # access, create your own users and further secure your server.

  services.openssh = {
    # Allow root login with password, needed for passwords set through vpsAdmin
    settings.PermitRootLogin = "yes";

    # Needed for public keys deployed through vpsAdmin, can be disabled if you
    # authorize your keys in configuration
    authorizedKeysInHomedir = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  # Under normal circumstances we would listen to your server's cloud-init callback and mark the server
  # as installed at this point. As we don't deliver cloud-init with NixOS we have to use a workaround
  # to indicate that your server is successfully installed. You can remove the cronjob after the server
  # has been started the first time. It's no longer needed.

  services.cron.enable = true;

  # Please remove the hardcoded password from the configuration and set
  # the password using the " passwd " command after the first boot.

  backup.enable = true;
  bitwarden.enable = true;
  mailcow.enable = true;
  seafile.enable = true;
  server.enable = true;
  immich.enable = true;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  #mount hetzner drive
  boot.supportedFilesystems = [ "sshfs" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="fuse", MODE="0666"
  '';

  systemd.mounts = [
    {
      what = "sshfs#u466367@u466367.your-storagebox.de:/";
      where = "/mnt/hetzner-box";
      type = "fuse.sshfs";
      options = "_netdev,allow_other,IdentityFile=/root/.ssh/hetzner_box_ed25519,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,StrictHostKeyChecking=accept-new,ssh_command=ssh -oBatchMode=yes -s sftp";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    }
    {
      what = "sshfs#u497568@u497568.your-storagebox.de:/";
      where = "/mnt/backup";
      type = "fuse.sshfs";
      options = "_netdev,allow_other,IdentityFile=/root/.ssh/hetzner_box_ed25519,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,StrictHostKeyChecking=accept-new,ssh_command=ssh -p23 -oBatchMode=yes -s sftp";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    }
  ];
}

  #  systemd.automounts = [
  #    {
  #      where = "/mnt/hetzner-box";
  #      wantedBy = [ "multi-user.target" ];
  #    }
  #    {
  #      where = "/mnt/backup";
  #      wantedBy = [ "multi-user.target" ];
  #    }
  #  ];

  systemd.tmpfiles.rules = [
"d /mnt/hetzner-box 0755 root root"
"d /mnt/backup 0755 root root"
];
}






