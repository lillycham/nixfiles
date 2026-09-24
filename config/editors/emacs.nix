{ config, pkgs, ... }:
let
  epkgs = import ./epkgs.nix;

  # project is built into emacs, at the same version as on GNU ELPA.
  # Mark it as built in, so packages that need it (rustic) don't fetch it.
  emacsPackages = (pkgs.emacsPackagesFor pkgs.emacs).overrideScope (self: super: {
    project = null;
  });
in
{
  programs.emacs = {
    enable = true;
    package = emacsPackages.emacsWithPackages epkgs;
  };
}
