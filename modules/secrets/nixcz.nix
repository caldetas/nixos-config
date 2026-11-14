#
#  Secrets for nixcz
#
{ sops-nix, host, lib, ... }:
{

  config = lib.mkIf (host.hostName == "nixcz") {
    #desktops
    sops.secrets."vpsfreectl/haveapi-client" = { sopsFile = ./../../secrets/desktops.yaml; };
    sops.secrets."ic/user" = { sopsFile = ./../../secrets/desktops.yaml; };
    sops.secrets."ic/password" = { sopsFile = ./../../secrets/desktops.yaml; };
    sops.secrets."ic/domain" = { sopsFile = ./../../secrets/desktops.yaml; };
    sops.secrets."ic/dns" = { sopsFile = ./../../secrets/desktops.yaml; };
    sops.secrets."ic/shared" = { sopsFile = ./../../secrets/desktops.yaml; };
  };
}
