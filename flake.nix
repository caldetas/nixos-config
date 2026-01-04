#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
  description = "Nix & NixOS System Flake Configuration";

  inputs = # References Used by Flake
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Stable Nix Packages
      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11"; # Unstable Nix Packages (Default)
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages (Default)
      sops-nix.url = "github:Mic92/sops-nix"; # Sops Nix Secure Secretes Manager

      home-manager = {
        # User Environment Manager
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nur = {
        # NUR Community Packages
        url = "github:nix-community/NUR"; # Requires "nur.nixosModules.nur" to be added to the host modules
      };

      nixgl = {
        # Fixes OpenGL With Other Distros.
        url = "github:guibou/nixGL";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      hyprland = {
        # Official Hyprland Flake
        url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      };

      plasma-manager = {
        # KDE Plasma User Settings Generator
        url = "github:pjones/plasma-manager";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, nur, nixgl, hyprland, plasma-manager, sops-nix, ... }: # Function telling flake which inputs to use
    let
      vars = {
        # Variables Used In Flake
        user = "caldetas";
        location = "/home/caldetas/Desktop/nixos-config";
        terminal = "kitty";
        term = "xterm-kitty";
        editor = "nano";
        domain = "caldetas.com";
      };
    in
    {
      nixosConfigurations = (
        # NixOS Configurations
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable nixpkgs-stable home-manager nur hyprland plasma-manager vars sops-nix; # Inherit inputs
        }
      );

      homeConfigurations = (
        # Nix Configurations
        import ./nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable nixpkgs-stable home-manager nixgl vars sops-nix;
        }
      );
    };
}
