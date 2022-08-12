{
	home.file.".xinitrc".text = ''
    setxkbmodmap --option caps:ctrl_modifier
    setxkbmodmap --option altwin:menu_win
    feh --bg-fill ~/Pictures/macOS-Monterey-Dark.jpg
    xrandr --output DP-4 --primary --mode 1920x1080 --rate 144.00
    picom &
    xmonad
  '';
}
