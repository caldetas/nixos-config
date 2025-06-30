{ pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    ubuntu_font_family
  ];

  fonts.fontconfig.enable = lib.mkForce true;
}
