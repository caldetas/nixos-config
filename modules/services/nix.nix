#
#  System Notifications
#

{ config, lib, pkgs, vars, inputs, ... }:
with lib;
{
  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-generation +10"; #"--delete-older-than 7d";
    };
    package = pkgs.nixVersions.latest; # Enable Flakes
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config.allowUnfree = true; # Allow Proprietary Software.
}

