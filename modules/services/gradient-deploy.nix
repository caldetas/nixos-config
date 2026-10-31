{ config, pkgs, vars, lib, gradient, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.client # for pull-deploy
  ];


  #gradient deploy runs on all systems
  config.system.gradient-deploy = {
    enable = true;
    server = "https://gradient.${vars.domain}";
    task = "nix-fleet/build";
    apiKeyFile = "/run/secrets/gradient/deploy-key";
    dates = "04:00";
  };
}
