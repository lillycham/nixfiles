{ config, pkgs, ... }:

{
	# Home Manager needs a bit of information about you and the
	# paths it should manage.
	home.username = ("lillycham");
	home.homeDirectory = if pkgs.stdenv.isLinux then "/home/lillycham" else "/Users/lillycham";
	nixpkgs.config.allowUnfree = true;
	# This value determines the Home Manager release that your
	# configuration is compatible with. This helps avoid breakage
	# when a new Home Manager release introduces backwards
	# incompatible changes.
	#
	# You can update Home Manager without changing this value. See
	# the Home Manager release notes for a list of state version
	# changes in each release.
	home.stateVersion = "22.05";

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	# Packages to install
	home.packages = with pkgs; [
		curl
		fish
		fzf
		git
		go
		neofetch
		neovim
		onefetch
		openssl
		plan9port
		powershell
		python3
		starship
		spotify-tui
		spotifyd
		tmux
		yarn
		nodejs
		clang
		alacritty
		kitty
		ghc
		smartmontools
		ed
		boxes
		tree
	];
	imports = [
		./config/starship.toml.nix
		./config/profile-plan9.nix
		./config/nvim-init.vim.nix
		./config/fish.nix
		./config/pwsh.nix
    	];
	programs.git = {
		enable = true;
		userName = "Lilly";
		userEmail = "54189319+lillycat332@users.noreply.github.com";
		aliases = {
			st = "status";
			co = "checkout";
		};
		extraConfig = {
			core = {
				excludesfile = "/Users/lillycham/.config/git/.gitignore_global";
			};
			init = {
				defaultBranch = "main";
			};
		};
	};
}
