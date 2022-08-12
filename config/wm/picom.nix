{ config, pkgs, services, ... }:
{
  services.picom = {
    enable = true;
    shadow = true;
    shadowOpacity = "0.75";
    backend = "glx";
    experimentalBackends = true;
    activeOpacity = "1.0";
    inactiveOpacity = "0.90";
    extraOptions =''
      corner-radius = 10;
      round-borders = 1;
    '';
  };
}
