{pkgs, config, ...}:
{
  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "arc"
      "prismlauncher"
      "protonvpn"
      "telegram"
      "keka"
      "spotify"
      "copilot-for-xcode"
    ];
  };
}
