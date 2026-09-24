{ config, lib, pkgs, inputs, ... }:
let
  epkgs = import ./epkgs.nix;

  # Build emacs from the pinned nixpkgs-emacs input (see flake.nix).
  pkgsEmacs = inputs.nixpkgs-emacs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # project is built into emacs, at the same version as on GNU ELPA.
  # Mark it as built in, so packages that need it (rustic) don't fetch it.
  emacsPackages = (pkgsEmacs.emacsPackagesFor pkgsEmacs.emacs).overrideScope (self: super: {
    project = null;
  });

  emacs = emacsPackages.emacsWithPackages epkgs;
in
{
  # Install emacs directly instead of with programs.emacs. programs.emacs wraps
  # the package again with the main nixpkgs, so its store path (and the daemon
  # agent) would change on every nixpkgs update.
  home.packages = [ emacs ];
  services.emacs.package = lib.mkDefault emacs;
}
