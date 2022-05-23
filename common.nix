{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  
  nixpkgs.config = {
    allowUnfree = true;
  };
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    alacritty
    bash
    boxes
    cabal-install
    cbonsai
    cloc
    clojure
    curl
    ed
    emacs
    fish
    fontforge
    fzf
    ghc
    git
    gitAndTools.gh
    go
    googler
    jq
    kitty
    leiningen
    llvmPackages_latest.clang
    llvmPackages_latest.libllvm
    llvmPackages_latest.llvm
    llvmPackages_latest.llvm-manpages
    mercurial
    neofetch
    nixfmt
    nodejs
    onefetch
    openssl
    plan9port
    powershell
    python3
    pywal
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
