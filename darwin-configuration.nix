{ pkgs, ... }:
{
  environment.systemPackages = pkgs: with pkgs;
    [ neovim
      iterm2
      lima
      utm
      iina
    ];

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
