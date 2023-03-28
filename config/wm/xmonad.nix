{ config, lib, pkgs, stdenv, ... }:

{
  xsession = {
    enable = true;
    
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: with hp; [
        dbus
        monad-logger
        xmonad-contrib
      ];
      config = ./config.hs;
    };
  };
}
