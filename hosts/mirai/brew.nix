{ pkgs, config, ... }:

{
  homebrew = {
    enable = true;
    # List of packages to install via homebrew casks (i.e. mac apps)
    casks = [
    ];

    masApps = {
      "Step Two" = 1448916662;
      "Hand Mirror" = 1502839586;
    };
  };
}
