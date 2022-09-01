{
	home.file.".xinitrc".text = ''
    setxkbmap -option caps:ctrl_modifier,altwin:menu_win
    feh --bg-fill ~/Pictures/macOS-Monterey-Dark.jpg
    xrandr --output DP-4 --primary --mode 1920x1080 --rate 144.00
    picom &
    xmonad
  '';
}
