#
#  System Notifications
#

{ config, lib, pkgs, vars, sops-nix, ... }:
with lib;
{
  #  config = mkIf (!config.server.enable) {

  sops.secrets.home-path = { };
  sops.secrets."surfshark/user" = { };
  sops.secrets."surfshark/password" = { };
  sops.secrets."surfshark/openvpn" = { };
  sops.secrets."server/ips" = { };
  sops.secrets."server/db-password" = { };
  sops.secrets."vaultwarden/env" = { };
  sops.secrets."borg/password" = { };
  sops.secrets."borg/repo" = { };
  sops.secrets."borg/rsh" = { };
  sops.secrets."vpsfreectl/haveapi-client" = {
    owner = "${vars.user}";
  };
  sops.secrets."my-secret" = {
    owner = "${vars.user}";
  };
  users.groups.secrets = { };
  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${vars.user}/.config/sops/age/keys.txt";
  system.activationScripts = {
    text =
      ''

         # Set up sops secret keys
         if [ -f /home/${vars.user}/seafile/encrypt/nixos/keys.txt ] && [ ! -f /home/${vars.user}/.config/sops/age/keys.txt ]; then
             echo 'Copying sops keys to user folder';
             mkdir -p /home/${vars.user}/.config/sops/age || true
             cp /home/${vars.user}/seafile/encrypt/nixos/keys.txt /home/${vars.user}/.config/sops/age/keys.txt || true

             # Check if sops encryption is working
             echo '
             Hey man! I am proof the encryption is working!

             My secret is here:
             ${config.sops.secrets.my-secret.path}

             My secret value is not readable, only in a shell environment:'  > /home/${vars.user}/secretProof.txt
             echo $(cat ${config.sops.secrets.my-secret.path}) >> /home/${vars.user}/secretProof.txt

             echo '
             My home-path on this computer:' >> /home/${vars.user}/secretProof.txt
             echo $(cat ${config.sops.secrets.home-path.path}) >> /home/${vars.user}/secretProof.txt

             #make openVpn surfshark login credential file
             if [ ! -d /home/${vars.user}/.secrets ]; then
             mkdir /home/${vars.user}/.secrets || true
             fi

             echo $(cat ${config.sops.secrets."surfshark/user".path}) > /home/${vars.user}/.secrets/openVpnPass.txt
             echo $(cat ${config.sops.secrets."surfshark/password".path}) >> /home/${vars.user}/.secrets/openVpnPass.txt

         else
             echo 'not copying sops keys to user folder, already present';
         fi;

         # Set up automated scripts if not already set up. Abort if no script folder present.
         if ! grep -q 'seafile/work/programs'  /home/${vars.user}/.zshrc && [[ -d "/home/${vars.user}/seafile/work/programs" ]] ;
         then
            echo 'chmod +x ~/seafile/work/programs/*' >> /home/caldetas/.zshrc
            echo 'export PATH=$PATH:/home/caldetas/seafile/work/programs' >> /home/caldetas/.zshrc
            echo "set up scripts in zshrc";
         else
            echo "not settings up scripts in zshrc, already present";
         fi
                                    '';

  };
  #  };
}

