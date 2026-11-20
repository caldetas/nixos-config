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
    ]
    #    ++
    #    ()
  ;


  #NAS storage mount
  environment.systemPackages = with pkgs; [ nfs-utils ];

  # To allow you to properly use and access your VPS via SSH, we enable the OpenSSH server and
  # grant you root access. This is just our default configuration, you are free to remove root
  # access, create your own users and further secure your server.

  services.openssh = {
    settings.PermitRootLogin = "prohibit-password";
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

  server.enable = true;
  #  gradient-ci.enable = true;

  networking.wireless.enable = lib.mkForce false; #todo delete, wpa was blocking rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  #mount hetzner drive
  boot.supportedFilesystems = [ "sshfs" ];

}






