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
      worker.peersFile = "/run/secrets/gradient/gradient-worker-peers";
      worker.enable = true;
      worker.id = "a0a70927-208f-4f58-b3d9-be931ac791de";
      #      worker.serverUrl = "gradient.${vars.domain}";
      worker.serverUrl = "wss://gradient.${vars.domain}/proto";
      s3 = {
        bucket = "nix-fleet";
        enable = true;
        region = "hel1";
        endpoint = "https://hel1.your-objectstorage.com";
        accessKeyId = "KF83P28EQEKPV8JOK6MQ"; #"/run/secrets/gradient/s3-key"; seems not to work
        secretAccessKeyFile = "/run/secrets/gradient/s3-secret";
      };
    };
  };
}
