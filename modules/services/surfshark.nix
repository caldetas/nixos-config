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
            unzip $src
            find . -type f ! -name '*_udp.ovpn' -delete
            find . -type f -exec sed -i "s+auth-user-pass+auth-user-pass /home/${vars.user}/.secrets/openVpnPass.txt+" {} + #file has only root rights
            find . -type f -exec sed -i "s+cipher+data-ciphers-fallback+" {} +
            rename 's/prod.surfshark.com_udp.//' *
            mkdir -p $out
            mv * $out
          '';
        };
        getConfig = filePath: {
          name = "${builtins.substring 0 (builtins.stringLength filePath - 5) filePath}";
          value = {
            config = '' config ${configFiles}/${filePath} '';
            autoStart = if builtins.match ".*ch-zur.*" filePath != null then true else false;
          };
        };

        openVPNConfigs = map getConfig (builtins.attrNames (builtins.readDir configFiles));
      in

      {
        servers = builtins.listToAttrs openVPNConfigs;
      };
  };
}
