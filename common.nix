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
    ((emacsPackagesFor emacsNativeComp).emacsWithPackages
      (epkgs: with epkgs; [
        ayu-theme
        go-mode
        haskell-mode
        lsp-haskell
        lsp-mode
        magit
        nix-mode
        racket-mode
        slime
        typescript-mode
        use-package
        vterm
        rust-mode
        smooth-scroll
        company-tabnine
        python-mode
        web-mode
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
