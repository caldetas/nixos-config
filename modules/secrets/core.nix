{ sops-nix, ... }:
{

  #common
  sops.secrets."curl/netrc" = { };
  sops.secrets."hetzner-id/storage" = { };
  sops.secrets."hetzner-id/backup" = { };
}
