{ pkgs, ... }:
let
  # Ayu Mirage, as 0xAARRGGBB.
  c = {
    bg = "0xff1f2430";
    panel = "0xff272d3b";
    line = "0xff323a4c";
    fg = "0xffcccac2";
    comment = "0xff707a8c";
    accent = "0xffffcc66";
    blue = "0xff73d0ff";
    green = "0xffd5ff80";
    orange = "0xffffa759";
    red = "0xfff28779";
    purple = "0xffdfbfff";
    cyan = "0xff95e6cb";
  };

  # The editor font, installed system-wide. Style names are those macOS lists.
  font = "Twilio Sans Mono";
in
{
  # A status bar that replaces the macOS menu bar. Home Manager writes
  # ~/.config/sketchybar/sketchybarrc and runs sketchybar under launchd.
  # Logs go to ~/Library/Logs/sketchybar. Reload by hand with:
  #   sketchybar --reload
  programs.sketchybar = {
    enable = true;
    extraPackages = [ pkgs.jq ];

    config = ''
      sketchybar --bar height=34 \
                       position=top \
                       color=${c.bg} \
                       border_width=1 \
                       border_color=${c.line} \
                       padding_left=8 \
                       padding_right=8

      # Every item is a small rounded pill.
      sketchybar --default \
                 updates=when_shown \
                 background.color=${c.panel} \
                 background.corner_radius=8 \
                 background.height=24 \
                 icon.font="Symbols Nerd Font:Regular:15.0" \
                 icon.color=${c.accent} \
                 icon.padding_left=10 \
                 icon.padding_right=4 \
                 label.font="${font}:Semibold:13.0" \
                 label.color=${c.fg} \
                 label.padding_left=0 \
                 label.padding_right=10 \
                 padding_left=4 \
                 padding_right=4

      # Left: the focused app.
      sketchybar --add item front_app left \
                 --set front_app icon="󰀻" \
                       icon.color=${c.blue} \
                       script='sketchybar --set "$NAME" label="$INFO"' \
                 --subscribe front_app front_app_switched

      # Right, from the edge inwards: clock, battery, volume.
      sketchybar --add item clock right \
                 --set clock icon="󰥔" \
                       icon.color=${c.orange} \
                       update_freq=10 \
                       script='sketchybar --set "$NAME" label="$(date "+%a %d %b %H:%M")"'

      sketchybar --add item battery right \
                 --set battery update_freq=120 \
                       script='
                         pct=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d %)
                         [ -z "$pct" ] && exit 0
                         if pmset -g batt | grep -q "AC Power"; then
                           icon="󰂄"; color=${c.green}
                         elif [ "$pct" -gt 80 ]; then icon="󰁹"; color=${c.green}
                         elif [ "$pct" -gt 50 ]; then icon="󰂀"; color=${c.accent}
                         elif [ "$pct" -gt 20 ]; then icon="󰁼"; color=${c.orange}
                         else icon="󰁺"; color=${c.red}; fi
                         sketchybar --set "$NAME" icon="$icon" icon.color="$color" label="$pct%"' \
                 --subscribe battery system_woke power_source_change

      sketchybar --add item volume right \
                 --set volume icon="󰕾" \
                       icon.color=${c.purple} \
                       script='[ "$SENDER" = volume_change ] && sketchybar --set "$NAME" label="$INFO%"' \
                 --subscribe volume volume_change

      sketchybar --update
    '';
  };
}
