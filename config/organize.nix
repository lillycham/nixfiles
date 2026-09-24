{ config, pkgs, ... }:
{
  home.packages = [ pkgs.organize-tool ];

  xdg.configFile."organize/config.yaml".source = ./organize/config.yaml;

  # Sort ~/Downloads and ~/Pictures/memes each time something in them changes.
  launchd.agents.organize = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.organize-tool}/bin/organize" "run" ];
      WatchPaths = [
        "${config.home.homeDirectory}/Downloads"
        "${config.home.homeDirectory}/Pictures/memes"
      ];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
    };
  };
}
