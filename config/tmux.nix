{
  programs.tmux = {
    enable = true;
    clock24 = true;

    extraConfig = ''
      # Enable mouse control (clickable windows, panes, resizable panes)
      set-option -g mouse on
      set -g pane-border-style fg='#ffeef9'
      set -g pane-active-border-style fg='#ffb6c1'

      # Statusbar style
      set -g status-style bg='#ffb6c1',fg=default
      set -g status-interval 1

      # Message Style
      set -g message-style bg='#ffb6c1',fg=default

    '';
  };
}
