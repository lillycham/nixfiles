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
    # plan9port
    alacritty
    auctex
    bash
    boxes
    cabal-install
    cloc
    curl
    dotnet-runtime
    ed
    # Optionally provide extra packages not in the configuration file.
    ((emacsPackagesFor emacsNativeComp).emacsWithPackages (epkgs: with epkgs; [
      all-the-icons
      atom-one-dark-theme
      ayu-theme
      auctex
      company
      csharp-mode
      dashboard
      doom-modeline
      elcord
      fsharp-mode
      flycheck
      flycheck-swift
      fzf
      go-mode
      haskell-mode
      js2-mode
      lsp-haskell
      lsp-mode
      magit
      nix-mode
      ob-swiftui
      org
      org-bullets
      org-roam
      org-preview-html
      org-variable-pitch
      evil
      page-break-lines
      projectile
      python-mode
      racket-mode
      rainbow-delimiters
      latex-preview-pane
      rust-mode
      slime
      smooth-scroll
      swift-mode
      typescript-mode
      use-package
      vterm
      web-mode
      zig-mode
      company-ipa
      company-flx
      dired-sidebar
      treemacs
      lsp-treemacs
      lsp-ui
      which-key
      treemacs-magit
      treemacs-all-the-icons
    ]))
    fsharp
    texlive.combined.scheme-small
    fish
    fzf
    git
    gitAndTools.gh
    go
    kitty
    neofetch
    nixpkgs-fmt
    onefetch
    powershell
    rakudo
    rustup
    rnix-lsp
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
  imports =
    [
      ./config/alacritty.nix
      ./config/editors/nvim.nix
      ./config/git.nix
      ./config/kitty.nix
      ./config/neofetch.nix
      ./config/plan9port/profile-plan9.nix
      ./config/shell/bash.nix
      ./config/shell/fish.nix
      ./config/shell/pwsh.nix
      ./config/shell/starship.nix
      ./config/tmux.nix
      # ./config/editors/emacs/emacs.nix
    ];
  home.stateVersion = "22.05";
}
