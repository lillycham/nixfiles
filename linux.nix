{
	imports = [ ./common.nix ];
	home.username = ("lillycham");
  home.homeDirectory = "/home/lillycham";
	home.packages = with pkgs; [
		chromium
		doas
	]
}