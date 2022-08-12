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
    # plan9port
    alacritty
    bash
    boxes
    cabal-install
    cloc
    curl
    ed
    ((emacsPackagesFor emacs28NativeComp).emacsWithPackages
      (epkgs: with epkgs; [
        all-the-icons
        atom-one-dark-theme
        ayu-theme
        company
        dashboard
        doom-modeline
        elcord
        fzf
        flycheck
        flycheck-swift
        go-mode
        haskell-mode
        lsp-haskell
        lsp-mode
        magit
        nix-mode
        rainbow-delimiters
        ob-swiftui
        org
        page-break-lines
        projectile
        python-mode
        racket-mode
        rust-mode
        slime
        swift-mode
        smooth-scroll
        typescript-mode
        js2-mode
        use-package
        vterm
        web-mode
        zig-mode
      ]))
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
  imports =
    [
      ./config/git.nix
      ./config/kitty.nix
      ./config/neofetch.nix
      ./config/editors/nvim.nix
      ./config/plan9port/profile-plan9.nix
      ./config/shell/bash.nix
      ./config/shell/fish.nix
      ./config/shell/pwsh.nix
      ./config/shell/starship.nix
      ./config/tmux.nix
      ./config/alacritty.nix
      # ./config/editors/emacs/emacs.nix
    ];
}
