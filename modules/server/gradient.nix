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
        bucket = "nix-fleet";
        enable = true;
        region = "hel1";
        endpoint = "https://hel1.your-objectstorage.com";
        accessKeyId = "KF83P28EQEKPV8JOK6MQ"; #"/run/secrets/gradient/s3-key"; seems not to work
        secretAccessKeyFile = "/run/secrets/gradient/s3-secret";
      };
      state.users.admin = {
        email = "info@${vars.domain}";
        password_file = "/run/secrets/gradient/admin-password";
        superuser = true;
      };
      #    baseDir = "/mnt/nas/gradient";
      githubApp = {
        enable = true;
        id = 5453140;
        privateKeyFile = "/run/secrets/gradient/github-app.pem";
        webhookSecretFile = "/run/secrets/gradient/github-app-webhook";
      };
    };
    services.postgresql.package = pkgs.postgresql_18;
  };
}
