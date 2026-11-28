{ config, lib, pkgs, vars, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };
}
