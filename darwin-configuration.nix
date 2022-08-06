{ pkgs, ... }:
{
  environment.systemPackages =
    [ pkgs.neovim
  ];

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
