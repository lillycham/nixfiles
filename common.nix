{ config, lib, pkgs, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-basic
      dvisvgm dvipng # for preview and export as html
      wrapfig amsmath ulem hyperref capt-of
      pgf tikz-cd listings mathtools forloop
      alphalph soul mathdesign xkeyval ly1
      ebgaramond ebgaramond-maths newtx
      etoolbox fontspec txfonts metafont
      charter biblatex booktabs makecell
      biblatex-mla stmaryrd polytable lazylist;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
  });
in
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
    (agda.withPackages (p: with p; [ standard-library cubical agda-categories ]))
    agda-pkg
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
    tex
    tmux
    tree
    wget
    yarn
    yt-dlp
    lhs2tex
    ispell
    ltex-ls
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
