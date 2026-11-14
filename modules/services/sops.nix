#
#  System Notifications
#

{ config, lib, pkgs, vars, sops-nix, ... }:
with lib;
{


  #common
  sops.secrets."curl/netrc" = { };
  sops.secrets."hetzner-id/storage" = { };
  sops.secrets."hetzner-id/backup" = { };

  #destops
  sops.secrets."vpsfreectl/haveapi-client" = { sopsFile = ./../../secrets/desktops.yaml; };
  sops.secrets."ic/user" = { sopsFile = ./../../secrets/desktops.yaml; };
  sops.secrets."ic/password" = { sopsFile = ./../../secrets/desktops.yaml; };
  sops.secrets."ic/domain" = { sopsFile = ./../../secrets/desktops.yaml; };
  sops.secrets."ic/dns" = { sopsFile = ./../../secrets/desktops.yaml; };
  sops.secrets."ic/shared" = { sopsFile = ./../../secrets/desktops.yaml; };
  #
  #  #nixcz
  #  sops.secrets."borg/password" = { };
  #  sops.secrets."borg/repo" = { };
  #  sops.secrets."borg/rsh" = { };
  #  sops.secrets."server/db-password" = { };
  #  sops.secrets."vaultwarden/env" = { };
  #  sops.secrets."gradient/crypt" = { };
  #  sops.secrets."gradient/jwt" = { };
  #  sops.secrets."gradient/s3-key" = { };
  #  sops.secrets."gradient/s3-secret" = { };
  #  sops.secrets."gradient/gradient-worker-peers" = { };
  #  sops.secrets."gradient/cache-signing-file" = { };
  #  sops.secrets."gradient/integrations-key-file" = { };
  #  sops.secrets."gradient/integrations-git-token_file" = { };
  #  sops.secrets."gradient/workers-token" = { };
  #  sops.secrets."gradient/project-ssh-key" = { };
  #  sops.secrets."gradient/actions-config-token" = { };
  #  sops.secrets."gradient/github-app-webhook" = { };
  #  sops.secrets."gradient/github-app.pem" = { };
  #  sops.secrets."gradient/admin-password" = { };
  #  sops.secrets."gradient/deploy-key" = { };


  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../../secrets/common.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
}

