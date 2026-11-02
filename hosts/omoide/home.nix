{ lib, pkgs, inputs, ... }:
let
  # The system stays on the nixpkgs of nixos-apple-silicon, which lags behind.
  # Take apps that move fast from the main nixpkgs. Signal Desktop refuses to
  # run once its build is about 90 days old.
  pkgsLatest = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ../common.nix
    ../../config/nine.nix
  ];

  nine.enable = true;

  # Acme's dark blue, since Bell blue is faint on the cream windows.
  bell-system = {
    enable = true;
    bannerColour = "000099";
  };

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
    pkgsLatest.claude-code
    pkgsLatest.codex
    pkgsLatest.signal-desktop
    pkgsLatest.telegram-desktop
  ];
}
