{ config, pkgs, ... }:

{
	# Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
	imports = [ 
		./common.nix
		./config/xinit.nix
	];
	home.username = ("lillycham");
  	home.homeDirectory = "/home/lillycham";
	home.packages = with pkgs; [
		parted
		tdesktop
		wineWowPackages.staging
		winetricks
		code-server
		konsole
		wayfire
		libsForQt5.qt5.qtwayland
		gnome.dconf-editor
		discord-canary
		google-chrome
		chrome-gnome-shell
		doas
		gnome3.gnome-tweaks
		fbterm
		fontconfig
		yaft
		freetype
	];
}
