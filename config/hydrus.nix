{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
in
{
  home.packages = [ pkgs.hydrus ];

  # Start the hydrus client at login, so the Client API is always up.
  launchd.agents.hydrus-client = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.hydrus}/bin/hydrus-client"
        "--db_dir"
        "${home}/Library/Hydrus"
      ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
