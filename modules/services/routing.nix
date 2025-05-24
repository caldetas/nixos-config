#
#  Bypass VPN for SSH addresses
#

{ config, lib, pkgs, vars, ... }:
with lib;

let
  vpnBypassScript = pkgs.writeShellScriptBin "vpn-bypass-route" ''
    #!/usr/bin/env bash
    set -euo pipefail

    export PATH="${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.gnugrep}/bin:${pkgs.iproute2}/bin:${pkgs.dnsutils}/bin:${pkgs.systemd}/bin"

    echo "vpn-bypass: Starting VPN bypass route setup"

    HOST=$(cat ${config.sops.secrets."server/nixcz".path})
    echo "vpn-bypass: Resolved host secret: $HOST"

    for i in {1..10}; do
      IP=$(dig +short "$HOST" | head -n1)
      if [ -n "$IP" ]; then
        echo "vpn-bypass: Resolved IP: $IP"
        break
      fi
      echo "vpn-bypass: Waiting for DNS resolution..."
      sleep 1
    done

    DEFAULT_ROUTE=$(ip route show default | head -n1)
    echo "vpn-bypass: Default route line: $DEFAULT_ROUTE"

    GATEWAY=$(echo "$DEFAULT_ROUTE" | awk '{print $3}')
    IFACE=$(echo "$DEFAULT_ROUTE" | awk '{print $5}')
    echo "vpn-bypass: Gateway: $GATEWAY"
    echo "vpn-bypass: Interface: $IFACE"

    if [ -z "$IP" ] || [ -z "$GATEWAY" ] || [ -z "$IFACE" ]; then
      echo "vpn-bypass: ERROR — missing IP, gateway, or interface" >&2
      exit 1
    fi

    echo "vpn-bypass: Adding route to $HOST ($IP) via $GATEWAY on $IFACE"
    ip route add "$IP" via "$GATEWAY" dev "$IFACE"
  '';

in
{

  config = mkIf (!config.server.enable) {
    systemd.services.vpn-bypass-route = {
      description = "Add VPN bypass route using hostname from SOPS secret";
      wantedBy = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${vpnBypassScript}/bin/vpn-bypass-route";
        RemainAfterExit = true;
      };
    };
  };
}
