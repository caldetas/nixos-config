{ config, pkgs, gradient, vars, lib, ... }:
with lib;
{

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
        caches.fleet-cache = {
          public = true;
          created_by = "admin";
          signing_key_file = "/run/secrets/gradient/cache-signing-file";
          projects = [ "nix-fleet" ];
          upstream_caches = [
            {
              active = true;
              display_name = "cache.nixos.org";
              public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
              type = "external";
              url = "https://cache.nixos.org";
            }
            {
              active = true;
              display_name = "cache.gradient.ci";
              public_key = "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8=";
              type = "external";
              url = "https://public.gradient.ci/cache/main";
            }
          ];
        };
        tasks = {
          build = {
            project = "nix-fleet";
            created_by = "admin";
            repository = "https://github.com/${vars.user}/nixos-config.git";
            wildcard = "packages.x86_64-linux.**,nixosConfigurations.*.config.system.build.toplevel";
            triggers = [
              { type = "reporter_push"; integration = "github-${vars.user}"; }
              { type = "reporter_pull_request"; integration = "github-${vars.user}"; }
            ];
            actions = [
              {
                name = "report-status";
                type = "git_host_status_report";
                config.integration = "github-${vars.user}";
              }
              {
                name = "flake-update";
                type = "open_pr";
                config.integration = "github-${vars.user}";
              }
            ];
            flake_input_overrides = {
              nixpkgs.keep_url = true;
              "home-manager*".keep_url = true;
            };
          };
        };
        workers.vps = {
          worker_id = "a0a70927-208f-4f58-b3d9-be931ac791de";
          projects = [ "nix-fleet" ];
          token_file = "/run/secrets/gradient/workers-token";
        };
        secrets.githubAppPrivateKeyFile = "/run/secrets/gradient/github-app.pem";
      };
      services.gradient.secrets.githubAppWebhookSecretFile = "/run/secrets/gradient/github-app-webhook";
    };
    services.postgresql.package = pkgs.postgresql_18;
  };
}
