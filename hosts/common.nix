{ config, pkgs, nixpkgs, lib, ... }:

{
  # Files to import.
  imports = [
    #../config/alacritty.nix
    #../config/editors/emacs.nix
    #../config/editors/nvim.nix
    ../config/editors/hx.nix
    ../config/git.nix
    ../config/kitty.nix
    #../config/langs/python.nix
    #../config/langs/agda.nix
    #../config/langs/latex.nix
    ../config/neofetch.nix
    ../config/plan9port/profile-plan9.nix
    ../config/shell/bash.nix
    ../config/shell/fish.nix
    ../config/shell/pwsh.nix
    ../config/shell/starship.nix
    ../config/tmux.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home = {
    packages = with pkgs; [
      bash
      cabal-install
      cabextract
      cachix
      cloc
      cmake
      curl
      direnv # Direnv, to use w/nix shells
      # dune_3
      fish
      fzf
      git
      gitAndTools.gh # Github CLI
      helix
      ispell
      kitty
      # mercurial
      # mypy
      neofetch
      nix-top
      onefetch
      powershell
      racket
      smartmontools
      stack
      starship
      tmux
      tree
      wget
      yarn
      yt-dlp
    ];

    stateVersion = "22.05";
  };
}
