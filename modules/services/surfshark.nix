{ config, lib, pkgs, vars, host, ... }:
with lib;
with host;

{
  options.surfshark.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable Surfshark OpenVPN profiles (auto-detected).";
  };

  # Usage:
  #   systemctl start openvpn-<profile>.service   # e.g., openvpn-ch-zur.service
  #   systemctl status openvpn-<profile>.service
  #   systemctl stop  openvpn-<profile>.service

  config = mkIf config.surfshark.enable (
    let
      # Fetch the Surfshark bundle (hash you prefetched)
      bundle = pkgs.fetchurl {
        url = "https://github.com/caldetas/surfshark/blob/main/configurations";
        sha256 = "sha256-025qPk2FN9LTYNI42DdRCtzP3wRPL2USjNv0/0s5+kw=";
      };

      # Unzip, filter *_udp.ovpn, patch lines, and normalize filenames → *.ovpn
      patched = pkgs.runCommand "surfshark-config-patched"
        { nativeBuildInputs = [ pkgs.unzip pkgs.findutils pkgs.gnused pkgs.rename ]; }
        ''
          set -euo pipefail
          work="$(mktemp -d)"
          unzip -q ${bundle} -d "$work"

          mkdir -p "$out"
          find "$work" -type f -name '*_udp.ovpn' -print0 | \
            while IFS= read -r -d $'\0' f; do
              cp "$f" "$out/$(basename "$f")"
            done

          cd "$out"
          for f in *.ovpn; do
            sed -i 's|^auth-user-pass$|auth-user-pass "/home/${vars.user}/MEGAsync/encrypt/surfshark/pass.txt"|' "$f"
            sed -i 's/^cipher/data-ciphers-fallback/' "$f"
          done

          # *.prod.surfshark.com_udp.ovpn → *.ovpn
          rename 's/\.prod\.surfshark\.com_udp\.ovpn$/.ovpn/' *.ovpn
        '';

      # Auto-detect all produced profiles by listing patched/*.ovpn
      files = builtins.attrNames (builtins.readDir patched);
      ovpnFiles = lib.filter (n: lib.hasSuffix ".ovpn" n) files;
      profiles = map (f: lib.removeSuffix ".ovpn" f) ovpnFiles;

      # Build servers attrset from detected profiles (no readFile; just point to path)
      mkServer = name: {
        inherit name;
        value = {
          config = "config ${patched}/${name}.ovpn";
          autoStart = lib.hasInfix "ch-zur" name;
        };
      };
      servers = builtins.listToAttrs (map mkServer profiles);

    in
    {
      services.openvpn.servers = servers;

      # Ensure VPN services start after network-online if/when you start them
      systemd.services =
        lib.genAttrs (map (n: "openvpn-${n}") profiles) (_: {
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
        });

      # Route DNS via VPN while active (optional; matches your earlier setup)
      services.resolved = {
        enable = true;
        dnssec = "allow-downgrade";
        domains = [ "~." ];
      };
    }
  );
}
