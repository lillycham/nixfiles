{ config, pkgs, ... }:
{
  # Import common.nix, with all of our packages and configs, then define any Darwin/macOS "platform specific" configs in here
  imports = [ ./common.nix ];
  home.username = ("lillycham");
  home.homeDirectory = "/Users/lillycham";
  home.packages = with pkgs; [ ];
}
