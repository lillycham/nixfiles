{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    alacritty
    bash
    boxes
    cabal-install
    cloc
    curl
    ed
    emacs
    fish
    fzf
    git
    gitAndTools.gh
    go
    kitty
    neofetch
    nixpkgs-fmt
    onefetch
    # plan9port
    powershell
    rustup
    smartmontools
    spotify-tui
    spotifyd
    stack
    starship
    tmux
    tree
    vscode
    wget
    yarn
    yt-dlp
  ];

  # Files to import.
  imports = [
    ./config/git.nix
    ./config/kitty.nix
    ./config/neofetch.nix
    ./config/nvim.nix
    ./config/plan9port/profile-plan9.nix
    ./config/shell/bash.nix
    ./config/shell/fish.nix
    ./config/shell/pwsh.nix
    ./config/shell/starship.nix
    ./config/tmux.nix
  ];
}
