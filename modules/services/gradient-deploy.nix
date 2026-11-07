{ config, pkgs, vars, lib, gradient, networking, host, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.client # for pull-deploy
  ];


  #gradient deploy runs on all systems
  config = {
    system.gradient-deploy = {
      enable = true;
      deployFor = host.hostName;
      server = "https://gradient.${vars.domain}";
      task = "nix-fleet/build";
      apiKeyFile = "/run/secrets/gradient/deploy-key";
      dates = "00:00";
    };
    #on boot wait 60 seconds and pull
    systemd.services.gradient-deploy-on-boot = {
      description = "Pull latest Gradient deployment after boot";

      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 60";
        ExecStart = "/run/current-system/sw/bin/gradient-update";
      };
    };
  };
}
