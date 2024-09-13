#
#  Bluetooth
#

{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true; #shows battery percentage
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;
}
