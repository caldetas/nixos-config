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
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  makeHost = name: folder: monitors: extraModules:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system unstable hyprland vars;
        host = {
          hostName = name;
          mainMonitor = monitors.main;
          secondMonitor = monitors.second;
          thirdMonitor = monitors.third;
        };
      };
      modules = [
        ./${folder}
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${vars.user}.imports = [ ];
        }
      ] ++ extraModules;
    };

in
{
  vm = makeHost "vm" "vm"
    {
      main = "Virtual-1";
      second = "";
      third = "";
    } [ ];

  libelula = makeHost "libelula" "libelula"
    {
      main = "eDP-1";
      second = "HDMI-A-1";
      third = "";
    } [ nur.modules.nixos.default ];

  onsite-gnome = makeHost "onsite-gnome" "onsite-gnome"
    {
      main = "eDP-1";
      second = "DP-6";
      third = "DP-8";
    } [ ];

  nixos = makeHost "papi" "papi"
    {
      main = "";
      second = "";
      third = "";
    } [ ];

  nixcz = makeHost "nixcz" "nixcz"
    {
      main = "";
      second = "";
      third = "";
    } [ ];
}
