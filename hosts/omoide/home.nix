{ lib, ... }:

{
  imports = [ ../common.nix ];

  # The signing key stays on mirai, and a signature means "approved by Lilly"
  # (see config/git.nix). Without this, every commit here fails.
  programs.git.signing.signByDefault = lib.mkForce false;
}
