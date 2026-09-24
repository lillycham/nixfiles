{ config, pkgs, ... }:
{
  home.packages = [ pkgs.organize-tool ];

  xdg.configFile."organize/config.yaml".source = ./organize/config.yaml;

  # Sort ~/Downloads each time something in it changes.
  launchd.agents.organize = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.organize-tool}/bin/organize" "run" ];
      WatchPaths = [ "${config.home.homeDirectory}/Downloads" ];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/organize.log";
    };
  };
}
