{ pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    ubuntu-classic
  ];

  fonts.fontconfig.enable = lib.mkForce true;
}
