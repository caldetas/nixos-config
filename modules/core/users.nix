{ config, lib, vars, ... }:

{
  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "secrets" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDm6jfav0cPBC1nhEkq2lV74xBuwHw70qRFG0uPYZA7O caldetas@libelula"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/fkjSAWbHsV6sos0WfLPgmy9epFhH4asSjQCmEOGIa caldetas@onsite-gnome"
    ];
  };
}
