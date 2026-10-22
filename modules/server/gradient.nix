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

  #      security.acme = {
  #        acceptTerms = true;
  #        defaults.email = "info@${vars.domain}";
  #      };
}
