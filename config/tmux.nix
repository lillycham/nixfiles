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
      set-window-option -g status-right "%a %d %B %H:%M"
      set-window-option -g status-left " #S "
      set-window-option -g window-status-format " #I: #W "
      set-window-option -g window-status-current-format " #I: #W "
      set -g status-style bg='#ffb6c1',fg="#000000"
      set -g status-interval 1
      
      # Message Style
      set -g message-style bg='#ffb6c1',fg="#000000"

      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-resurrect'

	    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
	    run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
