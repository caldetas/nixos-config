{ config, pkgs, gradient, vars, ... }:
{
  imports = [
    gradient.nixosModules.default
  ];

  services.gradient = {
    enable = true;
    domain = "gradient.${vars.domain}";
    secrets.jwtFile = "/run/secrets/gradient/jwt";
    secrets.cryptFile = "/run/secrets/cr";
    postgres.enable = true;
    worker.enable = true;
  };

  services.postgresql.package = pkgs.postgresql_18;
  nix.settings = {
    substituters = [
      "https://public.gradient.ci/cache/main"
    ];

    trusted-public-keys = [
      "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
    ];
  };
  #      security.acme = {
  #        acceptTerms = true;
  #        defaults.email = "info@${vars.domain}";
  #      };
}
