{pkgs, ...}:
{
  imports = [../common.nix];
  home = {
    username = "opc";
    directory = /home/opc;
  };
}
