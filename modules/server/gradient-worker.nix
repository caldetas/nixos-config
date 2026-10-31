{ config, pkgs, vars, lib, gradient, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.default
  ];
  disabledModules = [
    "services/continuous-integration/gradient/default.nix"
    "services/continuous-integration/gradient/worker.nix"
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
      worker.peersFile = "/run/secrets/gradient/gradient-worker-peers";
      worker.enable = true;
      worker.id = "a0a70927-208f-4f58-b3d9-be931ac791de";
      worker.serverUrl = "wss://aarch-ci.${vars.domain}/proto"; #worker connects to server
    };
  };
}
