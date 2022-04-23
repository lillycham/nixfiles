{
	home.file.".config/starship.toml".text = ''
		[aws]
		symbol = "  "

		[conda]
		symbol = " "

		[dart]
		symbol = " "

		[directory]
		read_only = " "

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
	'';
}
