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
      task = "nix-fleet/deploy";
      apiKeyFile = "/run/secrets/gradient/deploy-key";
      dates = "00:00";
    };
    systemd.services.gradient-deploy-on-boot = mkIf (!server.enable) {
      description = "Pull latest Gradient deployment after boot";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl start gradient-deploy.service";
      };
    };
  };
}
