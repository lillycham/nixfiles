{ config, pkgs, ... }:
{
  # Import shared nix configs
  imports = [ ../common.nix ];
  home = {
    packages = with pkgs; [ ];
  };
}

