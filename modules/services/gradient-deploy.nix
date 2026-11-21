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


  system.gradient-deploy = {
    enable = true;
    deployFor = host.hostName;
    server = "https://gradient.${vars.domain}";
    task = "nix-fleet/deploy";
    apiKeyFile = "/run/secrets/gradient/deploy-key";
    dates = "00:00";
  };
  config =
    mkIf (!config.server.enable) {
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
