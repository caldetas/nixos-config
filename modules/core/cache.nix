{ config, ... }:
{
  config.nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://public.gradient.ci/cache/main"
      "https://gradient.caldetas.com/cache/fleet-cache"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
      "gradient.caldetas.com-fleet-cache:z2AUe0iSRM+5ixLvYenC+3F4VLKhJU5Y76kwUiLsn24="
    ];

    fallback = true;
    connect-timeout = 10;
  };
}
