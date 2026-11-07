#
#  all work related settings, mainly vpn remote tunnel
#

{ config, lib, pkgs, unstable, stable, sops-nix, vars, ... }:

let
in
{
  environment.systemPackages = with pkgs; [
    ppp
    openfortivpn
  ];

  sops.secrets."ic/user" = { };
  sops.secrets."ic/password" = { };
  sops.secrets."ic/domain" = { };

  systemd.services.ic-vpn = {
    description = "OpenFortiVPN with DNS routing";
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
      RuntimeDirectory = "ic-vpn";
      RuntimeDirectoryMode = "0700";
      LoadCredential = [
        "username:${config.sops.secrets."ic/user".path}"
        "password:${config.sops.secrets."ic/password".path}"
        "domain:${config.sops.secrets."ic/domain".path}"
      ];

      ExecStart = pkgs.writeShellScript "ic-vpn-start" ''
              set -eu
              cfg="$RUNTIME_DIRECTORY/openfortivpn.conf"
              {
                printf 'host = %s\n' "$(cat "$CREDENTIALS_DIRECTORY/domain")"
                printf '%s\n' 'port = 443'
                printf 'username = %s\n' "$(cat "$CREDENTIALS_DIRECTORY/username")"
                printf 'password = %s\n' "$(cat "$CREDENTIALS_DIRECTORY/password")"
              } > "$cfg"
              chmod 600 "$cfg"
        exec ${pkgs.openfortivpn}/bin/openfortivpn --config "$cfg"
      '';

      ExecStartPost = pkgs.writeShellScript "ic-vpn-dns" ''
        for i in $(seq 1 60); do
          if ${pkgs.iproute2}/bin/ip link show ppp0 >/dev/null 2>&1; then
            ${pkgs.systemd}/bin/resolvectl dns ppp0 10.0.16.11 10.0.16.12
            ${pkgs.systemd}/bin/resolvectl domain ppp0 '~icag.local'
            echo "dns rerouting succeeded"
            exit 0
          fi
          sleep 1
        done
        echo "ppp0 did not appear" >&2
        exit 1
      '';
    };
  };
}
