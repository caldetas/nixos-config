{ config, lib, pkgs, unstable, stable, gradient, ... }:
let
in
{
  services.gradient = {
    enable = true;
    domain = "gradient.localhost";
    secrets.jwtFile = "/var/lib/gradient-secrets/jwt";
    secrets.cryptFile = "/var/lib/gradient-secrets/crypt";
    postgres.enable = true;
    worker.enable = true;
  };

  services.postgresql.package = pkgs.postgresql_18;
}
