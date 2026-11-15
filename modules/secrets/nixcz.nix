#
#  Secrets for nixcz
#
{ sops-nix, host, lib, ... }:
{

  config = lib.mkIf (host.hostName == "nixcz") {
    #nixcz
    sops.secrets."borg/password" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
    sops.secrets."borg/repo" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
    sops.secrets."borg/rsh" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
    sops.secrets."server/db-password" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
    sops.secrets."vaultwarden/env" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
  };
}
