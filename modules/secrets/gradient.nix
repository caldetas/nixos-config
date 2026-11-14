{ config, lib, ... }:

let
  gradientFile = ../../secrets/services/gradient.yaml;
  gradientSecretNames = [
    "gradient/crypt"
    "gradient/jwt"
    "gradient/s3-key"
    "gradient/s3-secret"
    "gradient/gradient-worker-peers"
    "gradient/cache-signing-file"
    "gradient/integrations-key-file"
    "gradient/integrations-git-token_file"
    "gradient/workers-token"
    "gradient/project-ssh-key"
    "gradient/actions-config-token"
    "gradient/github-app-webhook"
    "gradient/github-app.pem"
    "gradient/admin-password"
    "gradient/deploy-key"
  ];
in
{

  config = lib.mkIf
    (
      # or false omits undefined variables
      config.server.enable or false || config.gradient-worker.enable  or false || config.gradient-ci.enable   or false
    )
    {
      sops.secrets =
        lib.genAttrs gradientSecretNames (_: { sopsFile = gradientFile; });
    };
}
