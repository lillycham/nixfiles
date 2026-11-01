{ lib, pkgs, ... }:

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
}
