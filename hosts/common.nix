{ config, pkgs, lib, ... }:

{
  # Files to import.
  imports = [
    #../config/alacritty.nix
    ../config/editors/emacs.nix
    #../config/editors/nvim.nix
    ../config/editors/hx.nix
    ../config/git.nix
    ../config/kitty.nix
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
      cachix
      cloc
      curl
      # direnv
      # dune_3
      fish
      fzf
      ffmpeg
      gallery-dl
      ### git tools
      git
      git-lfs
      gh # Github CLI
      git-xet
      
      helix
      ispell
      kitty
      # mercurial
      # mypy
      fastfetch
      nix-top
      powershell
      smartmontools
      starship
      tmux
      tree
      wget
      yt-dlp
      nh
      # cargo
      # rustc
      # rust-analyzer
      # hydrus
      racket
    ];

    
    # programs.pi-coding-agent = {
    #   enable = true;
    #   extraPackages = [ pkgs.nodejs pkgs.bun ];
    # };

    stateVersion = "22.05";
  };
}
