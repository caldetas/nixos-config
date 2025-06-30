{ config, lib, ... }:

{
  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  home-manager.users.${config.vars.user} = {
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };

  system.stateVersion = "24.05";

  environment.interactiveShellInit = ''
    alias buildVm='echo cd ${config.vars.location} && git pull && sudo nixos-rebuild build-vm --flake ${config.vars.location}#vm --show-trace'
    alias update='echo Updating system... && git -C ${config.vars.location} pull && sudo nix flake update --flake ${config.vars.location} && sudo nixos-rebuild switch --flake ${config.vars.location}#${config.networking.hostName} --show-trace'
    alias rebuild='echo Rebuilding system... && git -C ${config.vars.location} pull && sudo nixos-rebuild switch --flake ${config.vars.location}#${config.networking.hostName} --show-trace'
  '';
}
