{ config, pkgs, ... }:
let gitignore = ''
	# General
	.DS_Store
	.AppleDouble
	.LSOverride

	# Icon must end with two \r
	Icon


	# Thumbnails
	._*

	# Files that might appear in the root of a volume
	.DocumentRevisions-V100
	.fseventsd
	.Spotlight-V100
	.TemporaryItems
	.Trashes
	.VolumeIcon.icns
	.com.apple.timemachine.donotpresent

	# Directories potentially created on remote AFP share
	.AppleDB
	.AppleDesktop
	Network Trash Folder
	Temporary Items
	.apdisk

	acme.dump
	acme.guide
'';
in {
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
        excludesfile = "~/.config/git/.gitignore_global";
      };
      init = { defaultBranch = "main"; };
    };
  };

	home.file.gitignore_global = {
		target = ".config/git/.gitignore_global";
		text = gitignore;
	};
}