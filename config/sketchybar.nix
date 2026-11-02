{ lib, pkgs, ... }:
let
  # The acme palette that omoide's niri theme uses, as sketchybar's
  # 0xAARRGGBB.
  c = lib.mapAttrs (_: hex: "0xff${lib.removePrefix "#" hex}")
    (import ./acme-colours.nix);

  font = "Go Mono";

  # The switch event names the app; at startup, ask macOS which app is in
  # front. A file, because sketchybar mangles quotes in an inline script.
  frontApp = pkgs.writeShellScript "sketchybar-front-app" ''
    app="$INFO"
    if [ -z "$app" ]; then
      app=$(lsappinfo info -only name "$(lsappinfo front)" | cut -d '"' -f 4)
    fi
    sketchybar --set "$NAME" label="$app"
  '';
in
{
  # A status bar that replaces the macOS menu bar, dressed as an acme tag
  # line: plain words on pale cyan, like omoide's waybar. Home Manager writes
  # ~/.config/sketchybar/sketchybarrc and runs sketchybar under launchd.
  # Logs go to ~/Library/Logs/sketchybar. Reload by hand with:
  #   sketchybar --reload
  programs.sketchybar = {
    enable = true;
    extraPackages = [ pkgs.jq ];

    config = ''
      # 44 px clears the notch, which is about 37 pt tall on the 13" Air.
      sketchybar --bar height=44 \
                       position=top \
                       color=${c.tag} \
                       border_width=2 \
                       border_color=${c.border} \
                       padding_left=8 \
                       padding_right=8

      # Plain words, no pills or icons. A highlight is a box with square
      # corners, like a selection in acme.
      sketchybar --default \
                 updates=when_shown \
                 icon.drawing=off \
                 background.drawing=off \
                 background.corner_radius=0 \
                 background.height=24 \
                 label.font="${font}:Regular:13.0" \
                 label.color=${c.ink} \
                 label.padding_left=8 \
                 label.padding_right=8 \
                 padding_left=0 \
                 padding_right=0

      # Left: the focused app, as the selected word of the tag.
      sketchybar --add item front_app left \
                 --set front_app background.drawing=on \
                       background.color=${c.tagsel} \
                       script=${frontApp} \
                 --subscribe front_app front_app_switched

      # Right, from the edge inwards: clock, battery, volume.
      sketchybar --add item clock right \
                 --set clock update_freq=10 \
                       script='sketchybar --set "$NAME" label="$(date "+%a %d %b %H:%M")"'

      # A low battery gets the yellow of a selection in an acme body.
      sketchybar --add item battery right \
                 --set battery update_freq=120 \
                       script='
                         pct=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d %)
                         [ -z "$pct" ] && exit 0
                         if pmset -g batt | grep -q "AC Power"; then
                           sketchybar --set "$NAME" label="bat $pct%+" background.drawing=off
                         elif [ "$pct" -le 20 ]; then
                           sketchybar --set "$NAME" label="bat $pct%" background.drawing=on \
                             background.color=${c.bodysel}
                         else
                           sketchybar --set "$NAME" label="bat $pct%" background.drawing=off
                         fi' \
                 --subscribe battery system_woke power_source_change

      sketchybar --add item volume right \
                 --set volume script='[ "$SENDER" = volume_change ] && sketchybar --set "$NAME" label="vol $INFO%"' \
                 --subscribe volume volume_change

      sketchybar --update
    '';
  };
}
