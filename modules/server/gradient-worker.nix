{ config, pkgs, gradient, vars, lib, ... }:
with lib;
{

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
      worker.peersFile = "/run/secrets/gradient/gradient-worker-peers";
      worker.enable = true;
      worker.id = "a0a70927-208f-4f58-b3d9-be931ac791de";
      worker.serverUrl = "wss://gradient.${vars.domain}/proto"; #worker connects to server
    };
  };
}
