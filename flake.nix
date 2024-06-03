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
      nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05"; # Stable Nix Packages
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages (Default)
      sops-nix.url = "github:Mic92/sops-nix"; # Sops Nix Secure Secretes Manager
      sops-nix.inputs.nixpkgs.follows = "nixpkgs";
      #      rust-overlay.url = "github:oxalica/rust-overlay";

      home-manager = {
        # User Environment Manager
        url = "github:nix-community/home-manager/release-24.05";
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
        url = "github:hyprwm/Hyprland"; # Requires "hyprland.nixosModules.default" to be added the host modules
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };

      plasma-manager = {
        # KDE Plasma User Settings Generator
        url = "github:pjones/plasma-manager";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, nur, nixgl, hyprland, plasma-manager, sops-nix, ... }: # Function telling flake which inputs to use
    let
      vars = {
        # Variables Used In Flake
        user = "caldetas";
        location = "/home/caldetas/Desktop/nixos-config";
        terminal = "kitty";
        editor = "nano";
      };
    in
    {
      nixosConfigurations = (
        # NixOS Configurations
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable home-manager nur hyprland plasma-manager vars sops-nix; # Inherit inputs
        }
      );

      homeConfigurations = (
        # Nix Configurations
        import ./nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable home-manager nixgl vars sops-nix;
        }
      );
    };
}
