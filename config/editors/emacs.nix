{ config, pkgs, ... }:
let epkgs = import ./epkgs.nix; in
{
  programs.emacs = {
    enable = true;
    package = ((pkgs.emacsPackagesFor pkgs.emacsNativeComp).emacsWithPackages epkgs);
  };
}
