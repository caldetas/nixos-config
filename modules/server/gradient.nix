{ config, pkgs, gradient, vars, lib, ... }:
with lib;
{
  imports = [
    gradient.nixosModules.default
  ];

  options = {
    gradient-ci = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gradient-ci.enable) {
    services.gradient = {
      enable = true;
      domain = "gradient.${vars.domain}";
      secrets.jwtFile = "/run/secrets/gradient/jwt";
      secrets.cryptFile = "/run/secrets/gradient/crypt";
      postgres.enable = true;
      worker.enable = true;
      proto.public = true;
      s3 = {
        bucket = "nixos";
        enable = true;
        region = "fsn1";
        endpoint = "https://fsn1.your-objectstorage.com";
        accessKeyId = "KF83P28EQEKPV8JOK6MQ";
        secretAccessKeyFile = "/run/secrets/gradient/s3-secret";
        services.gradient.state.users.admin = {
          email = "info@${vars.domain}";
          password_file = "/run/secrets/gradient/admin-password";
          superuser = true;
        };
      };
      #    baseDir = "/mnt/nas/gradient";
      githubApp = {
        enable = true;
        #        id = 123456;
        #        privateKeyFile = "/run/secrets/gradient-github-app.pem";
        #        webhookSecretFile = "/run/secrets/gradient-github-app-webhook";
      };
    };

    services.postgresql.package = pkgs.postgresql_18;
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://public.gradient.ci/cache/main"
        "https://gradient.caldetas.com/cache/fleet-cache"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
        "gradient.caldetas.com-fleet-cache:udlCy1R2ILsTR8i8l8/gCh3oQUA+wBCUPpudoGOeRcA="
      ];
    };
  };
}
