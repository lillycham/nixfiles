{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      if [ -z "$PS1" ]; then
        return
      fi
      eval "$(starship init bash)"
    '';
  };
}
