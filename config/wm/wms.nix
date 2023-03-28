{pkgs, services, ...}:
{
  imports = [
    ./xmonad.nix
  ];

  home.file.".xmobarrc".source = ./xmobarrc;

	home.file.".xinitrc".text = ''
    setxkbmap -option caps:ctrl_modifier,altwin:menu_win
    feh --bg-fill ~/Pictures/macOS-Monterey-Dark.jpg
    xrandr --output DP-4 --primary --mode 1920x1080 --rate 144.00
    picom &
    xmonad
  '';

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./solarized.rafi;
  };

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
