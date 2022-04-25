{
	programs.tmux = {
		enable = true;
		clock24 = true;

		extraConfig = ''
		# Enable mouse control (clickable windows, panes, resizable panes)
		set-option -g mouse on
		'';
	};
}
