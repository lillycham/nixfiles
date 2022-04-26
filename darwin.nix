{ config, pkgs, ... }:
{
	imports = [ ./common.nix ];
	home.username = ("lillycham");
  home.homeDirectory = "/Users/lillycham";
		home.packages = with pkgs; [
		iterm2
	];
}