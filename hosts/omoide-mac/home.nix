{ lib, ... }:
{
  imports = [ ../common.nix ];

  bell-system.enable = true;

  # macOS here has no GPG key yet: omoide's key lives on the NixOS side.
  # Turn signing back on once that key is imported here.
  programs.git.signing.signByDefault = lib.mkForce false;

  # Copy apps instead of symlinking them, so Spotlight indexes them.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
