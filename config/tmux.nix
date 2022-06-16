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
      set -g window-status-current-format "#[fg=#ffb6c1]\ue0b6#[bg=#ffb6c1] #[fg=magenta]#I #[fg=black] λ #W #[fg=magenta] #H #[fg=black] %a %d %b #[fg=magenta]%R #[bg=default]#[fg=#ffb6c1]\ue0b4 "
      set -g window-status-format "#[fg=#ffb6c1]\ue0b6#[fg=magenta] #[fg=black]#[bg=#ffb6c1]#I #[bg=#ffb6c1]#[fg=black] #W#[fg=black]#[bg=default]  #[bg=default]#[fg=#ffb6c1]\ue0b4 "
      set -g status-style bg='#ffb6c1',fg="#000000"
      set -g status-interval 1
      set -g status-style fg=black,bg=default
      set -g status-left ""
      set -g status-right ""
      set -g status-justify centre
      set -g status-position bottom
      
      # Message Style
      set -g message-style bg='#ffb6c1',fg="#000000"
      
      set-option -sa terminal-overrides ',screen-256color:RGB'

      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-resurrect'

      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      run '~/.tmux/plugins/tpm/tpm'

      # so that escapes register immidiately in vim
      set -sg escape-time 1
      set -g focus-events on
    '';
  };
}
