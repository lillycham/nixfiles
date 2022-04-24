{
	home.file.".config/starship.toml".text = ''
		format = "$shell$all"

		[aws]
		symbol = "  "

		[conda]
		symbol = " "

		[dart]
		symbol = " "

		[directory]
		read_only = " "
		format = "in [$path]($style)[$read_only]($read_only_style) "

		[docker_context]
		symbol = " "

		[elixir]
		symbol = " "

		[elm]
		symbol = " "

		[git_branch]
		symbol = " "

		[golang]
		symbol = " "

		[hg_branch]
		symbol = " "

		[java]
		symbol = " "

		[julia]
		symbol = " "

		[memory_usage]
		symbol = " "

		[nim]
		symbol = " "

		[nix_shell]
		symbol = " "

		[package]
		symbol = " "

		[perl]
		symbol = " "

		[php]
		symbol = " "

		[python]
		symbol = " "
		python_binary = ["py","python3.9","python2.7"]

		[ruby]
		symbol = " "

		[rust]
		symbol = " "

		[scala]
		symbol = " "

		[swift]
		symbol = "ﯣ "

		[time]
		disabled = true
		format = '🕙[\[ $time \]]($style) '
		time_format = "%T"
		utc_time_offset = "-5"
		time_range = "10:00:00-14:00:00"
		command_timeout = 1000

		[character]
		success_symbol = "[λ](bold green)"
		error_symbol = "[λ](bold red)"
		vicmd_symbol = "[γ](bold green)"
		
		[hostname]
		ssh_only = false
		format = "on [$hostname](bold red) "
		disabled = false
		
		[shell]
		fish_indicator = "Fish"
		bash_indicator = "Bash"
		zsh_indicator = "Zsh"
		ion_indicator = "Ion"
		elvish_indicator = "Elvish"
		tcsh_indicator = "Tcsh"
		xonsh_indicator = "Xonsh"
		cmd_indicator = "DOS Prompt!"
		nu_indicator = "Nu Shell"
		powershell_indicator = "PowerShell"
		unknown_indicator = "Unknown shell"
		format = "[✿ $indicator]($style)"
		style = "#9866c7 bold"
		disabled = false
		
		[username]
		style_user = "#ffb6c1 bold"
		style_root = "black bold"
		format = " as [$user]($style) "
		disabled = false	
		show_always = true
		
		[cmd_duration]
		format = "took [$duration](bold #ffb6c1)"
	'';
}
