{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  nixpkgs.config = {
    allowUnfree = true;
  };

  /* services.emacs.package = pkgs.emacsGitNativeComp;
    nixpkgs.overlays = [
    (import (builtins.fetchTarball {
    url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
    ]; */

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    (agda.withPackages (p: with p; [ standard-library cubical agda-categories ]))
    agda-pkg
    alacritty
    bash
    boxes
    cabal-install
    cachix
    cloc
    curl
    direnv
    dotnet-runtime
    ed
    fish
    fsharp
    fzf
    git
    gitAndTools.gh                   # GitHub CLI
    go
    idris2
    kitty
    mypy
    neofetch
    nixpkgs-fmt
    nix-top
    onefetch
    powershell
    racket
    rnix-lsp
    rustup
    smartmontools
    spotify-tui
    spotifyd
    stack
    starship
    texlive.combined.scheme-small    # LaTeX
    tmux
    tree
    vscode
    wget
    yarn
    yt-dlp
  ];

  # Files to import.
  imports =
    [
      ./config/alacritty.nix
      ./config/editors/emacs.nix
      ./config/editors/nvim.nix
      ./config/git.nix
      ./config/kitty.nix
      ./config/langs/python.nix
      ./config/neofetch.nix
      ./config/plan9port/profile-plan9.nix
      ./config/shell/bash.nix
      ./config/shell/fish.nix
      ./config/shell/pwsh.nix
      ./config/shell/starship.nix
      ./config/tmux.nix
    ];
  home.stateVersion = "22.05";
}
