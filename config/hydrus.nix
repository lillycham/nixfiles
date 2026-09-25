{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
  webPort = "45880";
  memeFolders = map (d: "${home}/Pictures/memes/${d}") [ "Images" "GIFs" "Video" ];
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

  # Serve hydrus-web on http://localhost:45880. It talks to the Client API
  # (port 45869) from the browser. Unknown paths fall back to index.html,
  # because it is a single-page app.
  launchd.agents.hydrus-web = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.static-web-server}/bin/static-web-server"
        "--host" "127.0.0.1"
        "--port" webPort
        "--root" "${pkgs.hydrus-web}"
        "--page-fallback" "${pkgs.hydrus-web}/index.html"
        "--log-level" "error"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "${home}/Library/Logs/hydrus-web.log";
    };
  };

  # Import new memes into hydrus with WD tagger and OCR tags. It runs when a
  # meme folder changes, and every hour in case hydrus was closed before.
  # It needs an API key in ~/.config/hydrus-tagger/api-key and an "ai tags"
  # tag service in hydrus.
  launchd.agents.hydrus-tagger = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.hydrus-tagger}/bin/hydrus-tagger" ] ++ memeFolders;
      WatchPaths = memeFolders;
      StartInterval = 3600;
      RunAtLoad = true;
      ProcessType = "Background";
      LowPriorityIO = true;
      Nice = 10;
      StandardOutPath = "${home}/Library/Logs/hydrus-tagger.log";
      StandardErrorPath = "${home}/Library/Logs/hydrus-tagger.log";
    };
  };
}
