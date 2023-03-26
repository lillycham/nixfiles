{ config, pkgs, nixpkgs, lib, ... }:

{
  # Files to import.
  imports =
    [
      ../config/alacritty.nix
      ../config/editors/emacs.nix
      ../config/editors/nvim.nix
      ../config/git.nix
      ../config/kitty.nix
      ../config/langs/python.nix
      ../config/neofetch.nix
      ../config/plan9port/profile-plan9.nix
      ../config/shell/bash.nix
      ../config/shell/fish.nix
      ../config/shell/pwsh.nix
      ../config/shell/starship.nix
      ../config/tmux.nix
      ../config/langs/latex.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home = {
    packages = with pkgs; [
      alacritty
      bash
      boxes
      biber
      cabal-install
      cabextract
      cachix
      cmake
      cloc
      curl
      direnv
      ed
      fish
      fzf
      git
      gitAndTools.gh                   # GitHub CLI
      go
      idris2
      kitty
      mypy
      neofetch
      nix-top
      onefetch
      powershell
      racket
      rnix-lsp
      smartmontools
      spotify-tui
      spotifyd
      stack
      starship
      tmux
      tree
      wget
      yarn
      yt-dlp
      ispell
    ];

    stateVersion = "22.05";
  };
}
