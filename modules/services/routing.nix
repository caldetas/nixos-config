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
    echo "vpn-bypass: Loaded host from secret: $HOST"

    if [[ "$HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      IP="$HOST"
      echo "vpn-bypass: HOST is already an IP: $IP"
    else
      for i in {1..10}; do
        IP=$(dig +short "$HOST" | head -n1)
        if [ -n "$IP" ]; then
          echo "vpn-bypass: Resolved IP: $IP"
          breakOffenes und kooperatives Team

        fi
        echo "vpn-bypass: Waiting for DNS resolution..."
        sleep 1
      done
    fi

    DEFAULT_ROUTE=$(ip route show default | head -n1)
    GATEWAY=$(echo "$DEFAULT_ROUTE" | awk '{print $3}')
    IFACE=$(echo "$DEFAULT_ROUTE" | awk '{print $5}')
    echo "vpn-bypass: Gateway: $GATEWAY"
    echo "vpn-bypass: Interface: $IFACE"

    if [ -z "$IP" ] || [ -z "$GATEWAY" ] || [ -z "$IFACE" ]; then
      echo "vpn-bypass: ERROR — missing IP, gateway, or interface" >&2
      exit 1
    fi

    echo "vpn-bypass: Adding route to $IP via $GATEWAY on $IFACE"
    ip route replace "$IP" via "$GATEWAY" dev "$IFACE"
  '';

in
{

  #  config = mkIf (config.surfshark.enable) {
  config = mkIf (false) {
    #not necessary with correct VPN setup

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
