{ config, pkgs, ... }:

{
	# Home Manager needs a bit of information about you and the
	# paths it should manage.
	home.username = "lillycham";
	home.homeDirectory = "/Users/lillycham";

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
	home.packages = [
		pkgs.tmux
		pkgs.fish
		pkgs.plan9port
		pkgs.iterm2
		pkgs.fzf
		pkgs.neofetch
		pkgs.onefetch
		pkgs.python3
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
				excludesfile = "/Users/lillycham/.gitignore_global";
			};
			init = {
				defaultBranch = "main";
			};
		};
	};
}
