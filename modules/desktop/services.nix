{ config, pkgs, ... }:

{
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
      openFirewall = false;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {
      enable = true;
      allowSFTP = true;
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };
  };

  systemd.services.NetworkManager-wait-online.enable = true;
}
