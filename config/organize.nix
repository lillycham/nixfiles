{ config, pkgs, ... }:
{
  home.packages = [ pkgs.organize-tool ];

  xdg.configFile."organize/config.yaml".source = ./organize/config.yaml;

  # Sort the watched folders each time something in them changes, and once a
  # day for the rules that depend on file age.
  launchd.agents.organize = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.organize-tool}/bin/organize" "run" ];
      WatchPaths = [
        "${config.home.homeDirectory}/Downloads"
        "${config.home.homeDirectory}/Pictures/memes"
        "${config.home.homeDirectory}/Pictures/Screenshots"
      ];
      StartInterval = 86400;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
    };
  };
}
