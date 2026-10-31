{ config, ... }:
{
  config.nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://public.gradient.ci/cache/main"
      "https://gradient.caldetas.com/cache/fleet-cache"
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
      "gradient.caldetas.com-fleet-cache:086c1m65/dYEBoZy9gytA2aD5kPq04lH8VFySPDXwG8="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];

    fallback = true;
    connect-timeout = 10;
  };
}
