{ config, lib, pkgs, vars, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    #    virtualHosts = {
    #      # Immich
    #      #      "john.caldetas.com" = {
    #      "${vars.subdomain}.caldetas.com" = {
    #        enableACME = true;
    #        forceSSL = true;
    #        locations."/" = {
    #          proxyPass = "http://localhost:2283";
    #          proxyWebsockets = true;
    #        };
    #
    #
    #        # Webhook handler
    #        locations."/webhook" = {
    #          proxyPass = "http://127.0.0.1:8000/webhook";
    #          proxyWebsockets = true;
    #          extraConfig = ''
    #            proxy_set_header Host $host;
    #            proxy_set_header X-Real-IP $remote_addr;
    #            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #            proxy_set_header X-Forwarded-Proto $scheme;
    #          '';
    #        };
    #      };


    #      # Grafana
    #      "grafana.john.caldetas.com" = {
    #        enableACME = true;
    #        forceSSL = true;
    #        locations."/" = {
    #          proxyPass = "http://localhost:3000";
    #          proxyWebsockets = true;
    #        };
    #      };
    #
    #      # PrometheusF
    #      "prometheus.john.caldetas.com" = {
    #        enableACME = true;
    #        forceSSL = true;
    #        locations."/" = {
    #          proxyPass = "http://localhost:9090";
    #          proxyWebsockets = true;
    #        };
    #      };
  };
}
