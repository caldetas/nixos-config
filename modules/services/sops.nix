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

  #nixcz
  sops.secrets."borg/password" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
  sops.secrets."borg/repo" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
  sops.secrets."borg/rsh" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
  sops.secrets."server/db-password" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };
  sops.secrets."vaultwarden/env" = { sopsFile = ./../../secrets/hosts/nixcz.yaml; };

  #gradient
  sops.secrets."gradient/crypt" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/jwt" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/s3-key" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/s3-secret" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/gradient-worker-peers" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/cache-signing-file" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/integrations-key-file" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/integrations-git-token_file" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/workers-token" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/project-ssh-key" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/actions-config-token" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/github-app-webhook" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/github-app.pem" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/admin-password" = { sopsFile = ./../../secrets/services/gradient.yaml; };
  sops.secrets."gradient/deploy-key" = { sopsFile = ./../../secrets/services/gradient.yaml; };


  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../../secrets/common.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
}

