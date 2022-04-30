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
		chromium
		enlightenment.terminology
		wayfire
		gnome.dconf-editor
		discord
		google-chrome
		chrome-gnome-shell
		firefox
		doas
		clang
		fbterm
		fontconfig
		yaft
		freetype
	];
}
