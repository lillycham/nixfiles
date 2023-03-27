{pkgs, config, ...}:
{
  homebrew = {
    enable = true;
    # List of packages to install via homebrew casks (i.e. mac apps)
    casks = [
      "arc"
      "copilot-for-xcode"
      "discord"
      "google-chrome"
      "hex-fiend"
      "keka"
      "prismlauncher"
      "protonvpn"
      "spotify"
      "skim"
      "telegram"
      "microsoft-teams"
      "microsoft-onenote"
    ];
    
    masApps = {
      "Step Two" = 1448916662;
      "Hand Mirror" = 1502839586;
    };
  };
}
