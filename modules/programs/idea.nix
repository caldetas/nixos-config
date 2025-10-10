#
#  IntelliJ IDEA Ultimate with AI Assistant support on NixOS
#  Uses buildFHSUserEnv to run JetBrains' prebuilt binaries
#  Safer than patching the non-executable package directly
#

{ config, lib, pkgs, unstable, stable, ... }:

let
  ideaFhs = pkgs.buildFHSEnv {
    name = "idea-ai";
    targetPkgs = pkgs: with stable; [
      jetbrains.idea-ultimate
      glib
      libsecret
      gnome-keyring
      nss
      cacert
      curl
      dbus
    ];
    runScript = "idea-ultimate";
  };
in
{
  environment.systemPackages = with pkgs; [
    ideaFhs
  ];

  # Required for GitHub Copilot / JetBrains AI token storage
  services.gnome.gnome-keyring.enable = true;

  # Ensure networking works properly for plugin login/auth
  #  networking.networkmanager.enable = true;



}
