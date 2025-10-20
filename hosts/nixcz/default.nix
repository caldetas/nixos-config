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

  systemd.services.mount-hetzner-box = {
    description = "Mount Hetzner Storage Box via SSHFS";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.mkForce (pkgs.writeShellScript "mount-hetzner-box" ''
        ${pkgs.coreutils}/bin/mkdir -p /mnt/hetzner-box
        ${pkgs.sshfs}/bin/sshfs \
          -o IdentityFile=/root/.ssh/hetzner_box_ed25519 \
          -o reconnect \
          -o allow_other \
          -o StrictHostKeyChecking=no \
          u466367@u466367.your-storagebox.de:/ /mnt/hetzner-box
      '');
    };
  };
  /*
     # only mount backup when necessary, to prevent deletion errors
    systemd.services.mount-backup = {
    description = "Mount Hetzner Storage Box via SSHFS";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.mkForce (pkgs.writeShellScript "mount-backup" ''
        ${pkgs.coreutils}/bin/mkdir -p /mnt/backup
        ${pkgs.sshfs}/bin/sshfs \
          -o IdentityFile=/root/.ssh/hetzner_box_ed25519 \
          -o reconnect \
          -o allow_other \
          -o StrictHostKeyChecking=no \
          u497568@u497568.your-storagebox.de:/ /mnt/backup
      '');
    };
    };
  */
}






