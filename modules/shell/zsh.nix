#
#  Shell
#

{ pkgs, vars, config, ... }:

{
  users.users.${vars.user} = {
    shell = pkgs.zsh;
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      histSize = 100000;

      ohMyZsh = {
        # Plug-ins
        enable = true;
        plugins = [ "git" "thefuck" "neofetch-autoload" ]; # your custom plugin name
        custom = "$HOME/.config/oh-my-zsh/custom";
      };

      shellInit = ''
        # Spaceship
        source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
        autoload -U promptinit; promptinit
        # Hook direnv
        #emulate zsh -c "$(direnv hook zsh)"

        #eval "$(direnv hook zsh)"
      '';
    };
  };

  home-manager.users.${vars.user} = {
    home.file.".config/oh-my-zsh/custom/plugins/neofetch-autoload/neofetch-autoload.plugin.zsh".text = ''
      if [[ $- == *i* ]]; then
        neofetch
      fi
    '';
  };
}
