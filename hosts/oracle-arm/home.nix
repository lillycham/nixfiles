{pkgs, ...}:
{
  imports = [../common.nix];
  home = {
    username = "opc";
    homeDirectory = /home/opc;
  };
}
