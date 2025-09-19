{ config, lib, pkgs, vars, host, ... }:
with lib;
with host;
let
  bundle = pkgs.fetchurl {
    url = "https://my.surfshark.com/vpn/api/v1/server/configurations";
    sha256 = "sha256-025qPk2FN9LTYNI42DdRCtzP3wRPL2USjNv0/0s5+kw=";
  };

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

      rename 's/\.prod\.surfshark\.com_udp\.ovpn$/.ovpn/' *.ovpn
    '';
  profiles = [ "ch-zur" ];

  mkServer = name: {
    inherit name;
    value = {
      # use a simple double-quoted string (no Nix multi-line quoting)
      config = "config ${patched}/${name}.ovpn";
      autoStart = false;
    };
  };

  servers = builtins.listToAttrs (map mkServer profiles);

in
{
  options = {
    surfshark = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  ## Activate SURFSHARK VPN
  # systemctl start openvpn-ch-zur.service
  # systemctl status openvpn-ch-zur.service
  # systemctl stop openvpn-ch-zur.service

  config = mkIf (config.surfshark.enable) {
    ## Activate SURFSHARK VPN
    # systemctl start openvpn-ch-zur.service
    # systemctl status openvpn-ch-zur.service
    # systemctl stop  openvpn-ch-zur.service

    services.openvpn.servers = servers;


    # Per-unit ordering overrides (inline lambda instead of undefined svcOverride)
    systemd.services =
      lib.genAttrs (map (n: "openvpn-${n}") profiles) (_: {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      });

    # (Optional) DNS via systemd-resolved, as you had before
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      domains = [ "~." ];
    };
  };
}
