{ config, pkgs, gradient, vars, lib, ... }:
with lib;
{

  options = {
    gradient-local = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gradient-local.enable) {
    services.gradient = {
      enable = true;
      domain = "gradient.localhost";
      secrets.jwtFile = "/run/secrets/gradient/jwt";
      secrets.cryptFile = "/run/secrets/gradient/crypt";
      postgres.enable = true;
      worker.enable = true;
      nginx.exposeProto = true;
      #      s3 = {
      #        bucket = "nix-fleet";
      #        enable = true;
      #        region = "hel1";
      #        endpoint = "https://hel1.your-objectstorage.com";
      #        accessKeyId = "KF83P28EQEKPV8JOK6MQ"; #"/run/secrets/gradient/s3-key"; seems not to work
      #        secretAccessKeyFile = "/run/secrets/gradient/s3-secret";
      #      };
      state = {
        users.admin = {
          email = "info@${vars.domain}";
          password_file = "/run/secrets/gradient/admin-password";
          superuser = true;
        };
        projects.nix-fleet = { created_by = "admin"; private_key_file = "/run/secrets/gradient/project-ssh-key"; };
        caches.fleet-cache = { created_by = "admin"; signing_key_file = "/run/secrets/gradient/cache-signing-file"; projects = [ "nix-fleet" ]; };
        tasks."build" = { project = "nix-fleet"; created_by = "admin"; repository = "https://github.com/${vars.user}/nixos-config"; wildcard = "packages.x86_64-linux.**,nixosConfigurations.libelula.config.system.build.toplevel"; };
        workers.vps = {
          worker_id = "a0a70927-208f-4f58-b3d9-be931ac791de";
          projects = [ "nix-fleet" ];
          token_file = "/run/secrets/gradient/workers-token";
        };
      };
      #    baseDir = "/mnt/nas/gradient";
      secrets.githubAppPrivateKeyFile = "/run/secrets/gradient/github-app.pem";
      secrets.githubAppWebhookSecretFile = "/run/secrets/gradient/github-app-webhook";
    };
    services.postgresql.package = pkgs.postgresql_18;
    security.acme = {
      acceptTerms = true;
      defaults.email = "info@${vars.domain}";
    };
  };
}
