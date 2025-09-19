{ config, lib, pkgs, vars, host, ... }:
with lib;
with host;
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
    ## Enable DNS resolution through VPN
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      domains = [ "~." ]; # Route all DNS through the VPN
    };

    services.openvpn =
      let
        configFiles = pkgs.stdenv.mkDerivation {
          name = "surfshark-config";
          src = pkgs.fetchurl {
            url = "https://my.surfshark.com/vpn/api/v1/server/configurations";
            sha256 = "sha256-onxJ3w2llkmWy3pS4QMmdITRC8fcvOlbXcwx//1I8Tw=";
          };
          phases = [ "installPhase" ];
          buildInputs = [ pkgs.unzip pkgs.rename ];
          installPhase = ''
            set -x
            unzip $src
            find . -type f ! -name '*_udp.ovpn' -delete

            for f in *.ovpn; do
              [ -e "$f" ] || continue

              substituteInPlace "$f" \
                --replace "auth-user-pass" "auth-user-pass /home/${vars.user}/.secrets/openVpnPass.txt"

              # Ensure essential directives
              grep -q "^redirect-gateway" "$f" || echo "redirect-gateway def1" >> "$f"
              grep -q "^dhcp-option DNS 162.252.172.57" "$f" || echo "dhcp-option DNS 162.252.172.57" >> "$f"
              grep -q "^dhcp-option DNS 149.154.159.92" "$f" || echo "dhcp-option DNS 149.154.159.92" >> "$f"

              # Prevent MTU issues
              grep -q "^tun-mtu " "$f" || echo "tun-mtu 1360" >> "$f"
              grep -q "^mssfix " "$f" || echo "mssfix 1320" >> "$f"

              # Avoid restart loops, allow reconnects
              grep -q "^ping " "$f" || echo "ping 20" >> "$f"
              grep -q "^ping-restart " "$f" || echo "ping-restart 300" >> "$f"
              grep -q "^persist-tun" "$f" || echo "persist-tun" >> "$f"
              grep -q "^persist-key" "$f" || echo "persist-key" >> "$f"
            done

            for f in *.ovpn; do
              [ -e "$f" ] || continue
              newname=$(echo "$f" | sed 's/\.prod\.surfshark\.com_udp\.ovpn$/.ovpn/')
              mv "$f" "$newname"
            done

            mkdir -p $out
            mv *.ovpn $out
          '';
        };

        getConfig = filePath: {
          name = "${builtins.substring 0 (builtins.stringLength filePath - 5) filePath}";
          value = {
            config = '' config ${configFiles}/${filePath} '';
            autoStart =
              if builtins.match ".*ch-zur.*" filePath != null
              then true
              else false;
          };
        };

        openVPNConfigs = map getConfig (builtins.attrNames (builtins.readDir configFiles));
      in
      {
        servers = builtins.listToAttrs openVPNConfigs;
      };
  };
}
