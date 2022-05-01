{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  nixpkgs.config.allowUnfree = true;
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
    curl
    fish
    fzf
    rustc
    cargo
    vscode
		wget
    git
    go
    neofetch
    neovim
    onefetch
    openssl
    plan9port
    powershell
    python3
    starship
    spotify-tui
    spotifyd
    tmux
    yarn
    nodejs
    alacritty
    kitty
    ghc
    smartmontools
    ed
    boxes
    tree
    jq
    bash
    nixfmt
    cloc
    emacs
    fontforge
    googler
    gitAndTools.gh
  ];

  # Files to import.
  imports = [
    ./config/git.nix
    ./config/neofetch.nix
    ./config/nvim-init.vim.nix
    ./config/plan9port/profile-plan9.nix
    ./config/shell/bash.nix
    ./config/shell/fish.nix
    ./config/shell/pwsh.nix
    ./config/shell/starship.nix
    ./config/tmux.nix
  ];
}
