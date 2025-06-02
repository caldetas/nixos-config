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
        plugins = [ "git" ];
      };

      shellInit = ''
        # Spaceship
        source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
        autoload -U promptinit; promptinit
        # Hook direnv
        #emulate zsh -c "$(direnv hook zsh)"
        #eval "$(direnv hook zsh)"
        # Only run neofetch in truly interactive, login-ish shells
        if [[ $- == *i* ]] && [[ -z "$SSH_ORIGINAL_COMMAND" ]] && [[ -z "$RSYNC_CALL" ]]; then
          neofetch
        fi
      '';
    };
    #command line tool, thefuck replacement
    pay-respects.enable = true;
  };
}
