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
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
      wireplumber.enable = true;
      wireplumber.extraConfig."11-bluetooth-policy" = {
        "wireplumber.settings" = {
          # Do NOT automatically jump to headset (HSP/HFP) profile
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
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
