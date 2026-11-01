{ lib, pkgs, inputs, ... }:
let
  # The system stays on the nixpkgs of nixos-apple-silicon, which lags behind.
  # The coding agents move fast, so take them from the main nixpkgs.
  pkgsAgents = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  imports = [ ../common.nix ];

  # omoide has its own signing key, so mirai's key never leaves mirai.
  programs.git.signing.key = lib.mkForce "105B0B1AED319B8E";

  # Same passphrase cache as mirai (see hosts/mirai/home.nix).
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
  };

  home.packages = [
    pkgsAgents.claude-code
    pkgsAgents.codex
  ];
}
