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

    # Load the list of hosts from the secret (space or newline separated)
    HOSTS=$(cat ${config.sops.secrets."server/ips".path})
    echo "vpn-bypass: Loaded hosts from secret: $HOSTS"

    # Initialize an empty array to store resolved IPs
    IPS=()

    for HOST in $HOSTS; do
     if [[ "$HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
       IP="$HOST"
       echo "vpn-bypass: HOST is already an IP: $IP"
     else
       for i in {1..10}; do
         IP=$(dig +short "$HOST" | head -n1 || true)
         if [ -n "$IP" ]; then
           echo "vpn-bypass: Resolved $HOST to IP: $IP"
           break
         fi
         echo "vpn-bypass: Waiting for DNS resolution for $HOST..."
         sleep 1
       done
     fi
     if [ -n "$IP" ]; then
       IPS+=("$IP")
     fi
    done

    if [ "''${#IPS[@]}" -eq 0 ]; then
     echo "vpn-bypass: ERROR — no valid IPs found" >&2
     exit 1
    fi

    DEFAULT_ROUTE=$(ip route show default | head -n1)
    GATEWAY=$(echo "$DEFAULT_ROUTE" | awk '{print $3}')
    IFACE=$(echo "$DEFAULT_ROUTE" | awk '{print $5}')
    echo "vpn-bypass: Gateway: $GATEWAY"
    echo "vpn-bypass: Interface: $IFACE"

    if [ -z "$GATEWAY" ] || [ -z "$IFACE" ]; then
     echo "vpn-bypass: ERROR — missing gateway or interface" >&2
     exit 1
    fi

    for IP in "''${IPS[@]}"; do
     echo "vpn-bypass: Ensuring route to $IP via $GATEWAY on $IFACE"
     ip route replace "$IP" via "$GATEWAY" dev "$IFACE"
    done
  '';

in
{

  config = mkIf (config.surfshark.enable) {
    #  config = mkIf (false) {
    #not necessary with correct VPN setup

    systemd.services.vpn-bypass-route = {
      description = "Add VPN bypass route using hostname from SOPS secret";
      wantedBy = [ "openvpn-ch-zur.service" ];
      after = [ "network-online.target" "openvpn-ch-zur.service" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${vpnBypassScript}/bin/vpn-bypass-route";
        RequiresMountsFor = [ "/run/secrets" ]; #missing credentials throw errors
        RemainAfterExit = true;
      };
    };
    # Run at every nixos-rebuild
    system.activationScripts.vpnBypassRoute = {
      text = "${vpnBypassScript}/bin/vpn-bypass-route";
    };
  };
}
