#
#  Secrets for hosts with gui
#
{ sops-nix, host, lib, vars, ... }:
{

  config = lib.mkIf
    (
      !config.server.enable
    )
    {
      #destops
      sops.secrets."vpsfreectl/haveapi-client" = { owner = vars.user; sopsFile = ./../../secrets/desktops.yaml; };
      sops.secrets."ic/user" = { sopsFile = ./../../secrets/desktops.yaml; };
      sops.secrets."ic/password" = { sopsFile = ./../../secrets/desktops.yaml; };
      sops.secrets."ic/domain" = { sopsFile = ./../../secrets/desktops.yaml; };
      sops.secrets."ic/dns" = { sopsFile = ./../../secrets/desktops.yaml; };
      sops.secrets."ic/shared" = { sopsFile = ./../../secrets/desktops.yaml; };
    };
}
