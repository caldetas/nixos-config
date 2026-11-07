{ config, pkgs, vars, lib, gradient, networking, host, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.client # for pull-deploy
  ];


  #gradient deploy runs on all systems
  options = {
    gradient-deploy-on-boot = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

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
    systemd.services.gradient-deploy-on-boot = mkIf (config.gradient-deploy-on-boot.enable) {
      description = "Pull latest Gradient deployment after boot";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        #        ExecStartPre = "${pkgs.coreutils}/bin/sleep 60";
        ExecStart = "${pkgs.systemd}/bin/systemctl start gradient-deploy.service";
      };
    };
  };
}
