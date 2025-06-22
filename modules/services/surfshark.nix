#
#  Network Shares
#

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
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade"; # Optional: Enables DNSSEC if supported
      domains = [ "~." ]; # Ensures all DNS goes through VPN
    };
    services.openvpn =
      #variables are defined here due to crash upon unssuccessful connection behind firewall
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

              grep -q "^redirect-gateway" "$f" || echo "redirect-gateway def1" >> "$f"
              grep -q "^dhcp-option DNS 162.252.172.57" "$f" || echo "dhcp-option DNS 162.252.172.57" >> "$f"
              grep -q "^dhcp-option DNS 149.154.159.92" "$f" || echo "dhcp-option DNS 149.154.159.92" >> "$f"

              #avoid mtu packet fragmentation
              grep -q "^tun-mtu " "$f" || echo "tun-mtu 1360" >> "$f"
              grep -q "^mssfix " "$f" || echo "mssfix 1320" >> "$f"

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
        getConfig = filePath: /*builtins.trace "Processing file: ${filePath}" */
          {
            name =
              /* builtins.trace "Generating config for: ${builtins.substring 0 (builtins.stringLength filePath - 5) filePath}" */
              "${builtins.substring 0 (builtins.stringLength filePath - 5) filePath}";
            value = {
              config = /*builtins.trace "Setting config for: ${filePath}"*/
                '' config ${configFiles}/${filePath} '';
              autoStart =
                if builtins.match ".*ch-zur.*" filePath != null
                then /* builtins.trace "Auto-start enabled for: ${filePath}" */ true
                else /*builtins.trace "Auto-start disabled for: ${filePath}"*/ false;
              #              extraArgs = config.extraArgs or [ ]; # Ensure this is always a list
            };
          };

        openVPNConfigs = map getConfig (builtins.attrNames (builtins.readDir configFiles));
      in
      {
        servers = builtins.listToAttrs openVPNConfigs;
      };
  };

}
