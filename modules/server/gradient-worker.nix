{ config, pkgs, gradient, vars, lib, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.default
  ];

  options = {
    gradient-worker = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gradient-worker.enable) {
    services.gradient = {
      worker.domain = "worker.${vars.domain}";
      #      secrets.jwtFile = "/run/secrets/gradient/jwt";
      #      secrets.cryptFile = "/run/secrets/gradient/crypt";
      worker.enable = true;
      worker.id = "a0a70927-208f-4f58-b3d9-be931ac791de";
      worker.serverUrl = "wss://gradient.${vars.domain}/proto";
    };
  };
}
