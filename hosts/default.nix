#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       └─ ./<host>.nix
#           └─ default.nix 
#

{ lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, nur, hyprland, plasma-manager, vars, ... }:

let
  system = "x86_64-linux"; # System Architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow Proprietary Software
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  vm = lib.nixosSystem {
    # VM Profile
    inherit system;
    specialArgs = {
      inherit inputs system unstable hyprland vars;
      host = {
        hostName = "vm";
        mainMonitor = "Virtual-1";
        secondMonitor = "";
        thirdMonitor = "";
      };
    };
    modules = [
      ./vm
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  libelula = lib.nixosSystem {
    #
    inherit system;
    specialArgs = {
      inherit inputs system unstable hyprland vars;
      #      inherit inputs system unstable vars;
      host = {
        hostName = "libelula";
        mainMonitor = "eDP-1";
        secondMonitor = "HDMI-A-1"; #"HDMI-1-1";
        thirdMonitor = "";
      };
    };
    modules = [
      nur.modules.nixos.default
      ./libelula
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${vars.user}.imports = [
        ];
      }
    ];
  };
  onsite-gnome = lib.nixosSystem {
    #
    inherit system;
    specialArgs = {
      inherit inputs system unstable hyprland vars;
      host = {
        hostName = "onsite-gnome";
        mainMonitor = "eDP-1";
        secondMonitor = "DP-6";
        thirdMonitor = "DP-8";
      };
    };
    modules = [
      ./onsite-gnome
      ./configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
