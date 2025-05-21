#
#  System Notifications
#

{ config, lib, pkgs, vars, ... }:
with lib;
{

  config = mkIf (config.server.enable) {

    services.seafile = {
      enable = true;

      # Set your admin email and initial password
      adminEmail = "admin@${vars.domain}";
      initialAdminPassword = "1234";

      # External domain (important for web URLs)
      ccnetSettings.General.SERVICE_URL = "https://seafile.${vars.domain}";

      # Seafile fileserver config — run behind Nginx using a Unix socket

      seafileSettings = {
        fileserver = {
          host = "unix:/run/seafile/server.sock";
          web_token_expire_time = 36000;
        };
      };
      seahubSettings = {
        "ALLOWED_HOSTS" = "['seafile.${vars.domain}']";
      };
      seahubExtraConf = ''
        CSRF_TRUSTED_ORIGINS = ["https://seafile.${vars.domain}"]
        FILE_SERVER_ROOT =  "https://seafile.${vars.domain}/seafhttp"
      '';

      # Optional data directory override
      dataDir = "/mnt/nas/seafile-test";

      # Garbage collection (e.g. clean up deleted files weekly)
      gc = {
        enable = true;
        dates = [ "Sun 03:00:00" ];
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;

      virtualHosts."seafile.${vars.domain}" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://unix:/run/seahub/gunicorn.sock";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;
            '';
          };

          "/seafhttp" = {
            proxyPass = "http://unix:/run/seafile/server.sock";
            extraConfig = ''
              rewrite ^/seafhttp(.*)$ $1 break;
              client_max_body_size 0;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_connect_timeout 36000s;
              proxy_read_timeout 36000s;
              proxy_send_timeout 36000s;
              send_timeout 36000s;
            '';
          };
        };
      };
    };
  };
}
