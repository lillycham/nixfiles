# A Plan 9 acme look for the niri desktop: cream window bodies, pale cyan tag
# lines, purple-blue borders on rio's grey. The colours are in
# acme-colours.nix, which the sketchybar theme on mirai shares.
{ config, lib, pkgs, ... }:
let
  cfg = config.nine;

  c = import ./acme-colours.nix;

  font = "Go Mono";

  # niri's own default config is the base, so its binds follow niri updates.
  # Each patch fails the build if its text is gone from the stock file, and
  # does not silently drop the theme.
  patch = old: new: text:
    assert lib.assertMsg (lib.hasInfix old text)
      "nine: niri's default config no longer contains:\n${old}";
    builtins.replaceStrings [ old ] [ new ] text;

  niriConfig = lib.pipe (builtins.readFile "${pkgs.niri.src}/resources/default-config.kdl") [
    (patch "    gaps 16\n"
      "    gaps 8\n    background-color \"${c.desk}\"\n")
    (patch "        // Uncomment this line to disable the focus ring.\n        // off\n"
      "        // Uncomment this line to disable the focus ring.\n        off\n")
    (patch "        off\n\n        width 4\n        active-color \"#ffc87f\"\n        inactive-color \"#505050\"\n"
      "        width 3\n        active-color \"${c.border}\"\n        inactive-color \"${c.dim}\"\n")
    (patch "\n// prefer-no-csd\n" "\nprefer-no-csd\n")
    (patch "    // Uncomment to turn off all animations.\n    // off\n"
      "    // Uncomment to turn off all animations.\n    off\n")
    # Not the theme: the M1 Air has no Print key, so add the macOS keys. Mod
    # is the Command key.
    (patch "    Alt+Print { screenshot-window; }\n" (lib.concatMapStrings (l: "    ${l}\n") [
      "Alt+Print { screenshot-window; }"
      "Mod+Shift+3 { screenshot-screen; }"
      "Mod+Shift+4 { screenshot; }"
      "Mod+Shift+5 { screenshot-window; }"
    ]))
    # The panel counts brightness in nits, and eyes see light on a log scale,
    # so linear steps give one dim level and many bright ones. -e4 spaces the
    # steps as they look, and -n2 keeps the screen from going black. If the
    # screen only has a dark and a bright level after boot, suspend and wake
    # once: https://github.com/AsahiLinux/linux/issues/499
    # The M1 Air has no keyboard backlight keys either, so Command with the
    # screen brightness keys sets the keyboard backlight.
    (patch (lib.concatMapStrings (l: "    ${l}\n") [
      "XF86MonBrightnessUp allow-when-locked=true { spawn \"brightnessctl\" \"--class=backlight\" \"set\" \"+10%\"; }"
      "XF86MonBrightnessDown allow-when-locked=true { spawn \"brightnessctl\" \"--class=backlight\" \"set\" \"10%-\"; }"
    ]) (lib.concatMapStrings (l: "    ${l}\n") [
      "XF86MonBrightnessUp allow-when-locked=true { spawn \"brightnessctl\" \"--class=backlight\" \"-e4\" \"-n2\" \"set\" \"5%+\"; }"
      "XF86MonBrightnessDown allow-when-locked=true { spawn \"brightnessctl\" \"--class=backlight\" \"-e4\" \"-n2\" \"set\" \"5%-\"; }"
      "Mod+XF86MonBrightnessUp allow-when-locked=true { spawn \"brightnessctl\" \"--device=kbd_backlight\" \"set\" \"+10%\"; }"
      "Mod+XF86MonBrightnessDown allow-when-locked=true { spawn \"brightnessctl\" \"--device=kbd_backlight\" \"set\" \"10%-\"; }"
    ]))
  ];

  # fuzzel wants RRGGBBAA without the hash.
  hex = s: "${lib.removePrefix "#" s}ff";
in
{
  options.nine.enable = lib.mkEnableOption "the Plan 9 acme look for niri";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.go-font ];
    fonts.fontconfig.enable = true;

    # The stock config.kdl and alacritty.toml were written by hand before Home
    # Manager took them over, so replace them.
    xdg.configFile."niri/config.kdl" = {
      text = niriConfig;
      force = true;
    };

    # niri's config.kdl starts waybar, so set the files only, not
    # programs.waybar, whose systemd unit would start a second bar.
    xdg.configFile."waybar/config.jsonc".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 22;
      spacing = 0;
      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-right = [ "pulseaudio" "network" "battery" "clock" ];
      "niri/workspaces".format = "{index}";
      "niri/window" = { format = "{title}"; max-length = 80; };
      pulseaudio = { format = "vol {volume}%"; format-muted = "vol mute"; };
      network = {
        format-wifi = "net {essid}";
        format-ethernet = "net wired";
        format-disconnected = "net down";
      };
      battery = { format = "bat {capacity}%"; format-charging = "bat {capacity}%+"; };
      clock.format = "{:%a %d %b %H:%M}";
    };

    xdg.configFile."waybar/style.css".text = ''
      * {
        font-family: "${font}";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      window#waybar {
        background: ${c.tag};
        color: ${c.ink};
        border-bottom: 2px solid ${c.border};
      }
      #workspaces button {
        padding: 0 6px;
        color: ${c.ink};
        background: transparent;
      }
      #workspaces button.focused,
      #workspaces button.active {
        background: ${c.tagsel};
      }
      #workspaces button.urgent {
        background: ${c.dirty};
        color: ${c.tag};
      }
      #window {
        padding: 0 12px;
      }
      #pulseaudio, #network, #battery, #clock {
        padding: 0 8px;
      }
      #battery.warning:not(.charging) {
        background: ${c.bodysel};
      }
    '';

    xdg.configFile."fuzzel/fuzzel.ini".text = lib.generators.toINI { } {
      main = {
        font = "${font}:size=11";
        icons-enabled = "no";
        prompt = "\"% \"";
      };
      colors = {
        background = hex c.body;
        text = hex c.ink;
        prompt = hex c.ink;
        input = hex c.ink;
        match = hex c.dirty;
        selection = hex c.bodysel;
        selection-text = hex c.ink;
        selection-match = hex c.dirty;
        border = hex c.border;
      };
      border = { width = 2; radius = 0; };
    };

    xdg.configFile."mako/config".text = ''
      font=${font} 11
      background-color=${c.tag}
      text-color=${c.ink}
      border-color=${c.border}
      border-size=2
      border-radius=0
    '';

    xdg.configFile."swaylock/config".text = ''
      color=${lib.removePrefix "#" c.desk}
    '';

    xdg.configFile."alacritty/alacritty.toml".force = true;
    programs.alacritty = {
      enable = true;
      settings = {
        font = { normal.family = font; size = 11; };
        window.padding = { x = 6; y = 4; };
        cursor.style = "Block";
        # Shift+Return sends a newline without submitting, for Claude Code.
        # Nix strings have no \u escape, so JSON makes the ESC.
        keyboard.bindings = [
          { key = "Return"; mods = "Shift"; chars = builtins.fromJSON ''"\u001b\r"''; }
        ];
        colors = {
          primary = { background = c.body; foreground = c.ink; };
          cursor = { text = c.body; cursor = c.ink; };
          selection = { text = c.ink; background = c.bodysel; };
          # Dark inks that stay readable on cream. White is a mid grey, since
          # programs print it as text.
          normal = {
            black = "#000000"; red = "#aa0000"; green = "#006600"; yellow = "#7a6a00";
            blue = c.dirty; magenta = "#770077"; cyan = "#006b6b"; white = "#777777";
          };
          bright = {
            black = "#555555"; red = "#cc3333"; green = "#3a7a3a"; yellow = "#99994c";
            blue = "#3333bb"; magenta = "#993399"; cyan = "#338f8f"; white = "#999999";
          };
        };
      };
    };
  };
}
