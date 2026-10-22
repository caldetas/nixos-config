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
    baseDir = "/mnt/nas/gradient";
  };

  services.postgresql.package = pkgs.postgresql_18;
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://public.gradient.ci/cache/main"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
    ];
  };


  #      security.acme = {
  #        acceptTerms = true;
  #        defaults.email = "info@${vars.domain}";
  #      };
}
