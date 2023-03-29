{pkgs, ...}:
{
  imports =
    [
      ../config/alacritty.nix
      ../config/editors/emacs.nix
      ../config/editors/nvim.nix
      ../config/git.nix
      ../config/kitty.nix
      ../config/langs/python.nix
      ../config/langs/agda.nix
      ../config/langs/latex.nix
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
  
  home = {
    packages = with pkgs; [
      node
    ];
  };
}
