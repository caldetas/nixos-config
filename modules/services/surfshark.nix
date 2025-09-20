{ config, pkgs, lib, host, ... }:
with lib;
with host;

let
  bundle = pkgs.fetchzip {
    url = "https://github.com/caldetas/surfshark/archive/refs/heads/main.zip";
    sha256 = "sha256-MCtHbCRA17tvKv7qMf3zNcoQih6Oxxih21QZUNQ/Z4Q=";
    stripRoot = true; # GitHub archives have a single top dir
  };
  configFiles = pkgs.stdenv.mkDerivation {
    name = "surfshark-config";
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.unzip pkgs.rename ];
    installPhase = ''
      set -euo pipefail
         cfgdir=${bundle}/configurations
         mkdir -p "$out"

         # Copy ONLY UDP profiles and flatten+shorten the filename on copy
         while IFS= read -r -d $'\0' f; do
           base="$(basename "$f")"
           short="$(printf '%s' "$base" | sed 's/\.prod\.surfshark\.com_udp\.ovpn$/.ovpn/')"
           install -Dm0644 "$f" "$out/$short"
         done < <(find "$cfgdir" -type f -name '*_udp.ovpn' -print0)

         # Patch each copied file
         while IFS= read -r -d $'\0' f; do
           sed -i 's|^auth-user-pass$|auth-user-pass "'"${config.sops.secrets."surfshark/openvpn".path}"'"|' "$f"
           sed -i 's/^cipher/data-ciphers-fallback/' "$f"
         done < <(find "$out" -type f -name '*.ovpn' -print0)
    '';
  };

  # MINIMAL change: avoid readDir-on-derivation during eval; list profiles you need
  profiles = [ "ch-zur" ];

  getConfig = name: {
    inherit name;
    value = {
      # pass a path string; do NOT read the file at eval time
      config = "config ${configFiles}/${name}.ovpn";
      autoStart = false;
    };
  };

  serversAttr = builtins.listToAttrs (map getConfig profiles);
in
{
  options.surfshark.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.surfshark.enable {
    networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
    services.openvpn.servers = serversAttr;
  };
}
