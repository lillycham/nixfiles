# AT&T Bell Laboratories computing-exchange look for the terminal.
# Midnight navy, Bell blue, cool grey, no neon. It changes the kitty colours,
# the bash and fish banner and the fastfetch report. It does not rename the
# machine.
{ config, lib, pkgs, ... }:
let
  cfg = config.bell-system;

  banner = pkgs.writeText "bell-banner.txt" ''
    AT&T BELL LABORATORIES
    COMPUTING SYSTEMS DIVISION

    INSTALLATION:  ${cfg.installation}
    EQUIPMENT:     PERSONAL UNIX TERMINAL
    SERVICE:       AT&T DATAGRID
    OPERATING SYS: UNIX COMPATIBILITY ENVIRONMENT
    MAINTENANCE:   CUSTOMER RESPONSIBILITY

    ALL SYSTEMS NOMINAL.

    NOTICE:
    THIS TERMINAL IS CONNECTED TO THE
    BELL SYSTEM COMPUTING NETWORK.

    UNAUTHORIZED INFERENCE IS BILLABLE.
  '';

  # A Saul Bass style globe: a disc cut by horizontal stripes. Half blocks
  # give two pixels per cell, so the disc is round and each stripe (4 px, two
  # rows) can be 1, 2 or 3 px thick. Each stripe keeps one thickness along its
  # length, thin at the top and heavy at the bottom, so nothing staircases.
  globe = pkgs.writeText "bell-globe.txt" ''
           ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

     ▄████████████████████████████████▄

    ████████████████████████████████████

    ████████████████████████████████████

     ██████████████████████████████████
      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
      ▀██████████████████████████████▀
        ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
         ▀████████████████████████▀
             ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
               ▀▀▀████████▀▀▀
  '';

  custom = key: text: { type = "custom"; key = key; format = text; };

  # "rrggbb" to the "r;g;b" of a 24-bit colour escape.
  rgb = hex: lib.concatMapStringsSep ";"
    (i: toString (lib.fromHexString (builtins.substring i 2 hex))) [ 0 2 4 ];
in
{
  options.bell-system = {
    enable = lib.mkEnableOption "the AT&T Bell Laboratories terminal identity";
    installation = lib.mkOption {
      type = lib.types.str;
      default = "07-8290";
      description = "Installation number shown in the banner and the report.";
    };
    bannerColour = lib.mkOption {
      type = lib.types.strMatching "[0-9a-fA-F]{6}";
      default = "6fb1ea";
      description = ''
        Colour of the shell banner, as rrggbb. The default Bell blue suits a
        dark background; use a darker blue on a light one.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty.settings = {
      font_family = lib.mkForce "IBM Plex Mono";
      background = lib.mkForce "#0f1923";
      foreground = lib.mkForce "#c8d1da";
      cursor = lib.mkForce "#6fb1ea";
      selection_background = lib.mkForce "#1f3a55";
      selection_foreground = lib.mkForce "#e6edf3";
      url_color = "#6fb1ea";
      # Muted ANSI palette: Bell blue and greys, no neon.
      color0 = lib.mkForce "#0b141c";
      color8 = lib.mkForce "#566574";
      color1 = lib.mkForce "#b5695f";
      color9 = lib.mkForce "#c9857b";
      color2 = lib.mkForce "#6f9c8a";
      color10 = lib.mkForce "#8db5a3";
      color3 = lib.mkForce "#b8a574";
      color11 = lib.mkForce "#cbb98b";
      color4 = lib.mkForce "#4a8fd0";
      color12 = lib.mkForce "#6fb1ea";
      color5 = lib.mkForce "#8f84b8";
      color13 = lib.mkForce "#a79ecb";
      color6 = lib.mkForce "#5fa3b5";
      color14 = lib.mkForce "#85bccb";
      color7 = lib.mkForce "#aab6c2";
      color15 = lib.mkForce "#e6edf3";
    };

    programs.fish = {
      shellAbbrs.banner = "cat ${banner}";
      shellAliases.service = "fastfetch";
      functions.fish_greeting = lib.mkForce {
        description = "Bell System connection banner";
        body = ''
          set_color ${cfg.bannerColour}
          cat ${banner}
          set_color normal
        '';
      };
    };

    # The login shell on mirai is bash. Home Manager puts initExtra after its
    # interactive check, so scripts and agent shells print nothing. 9term and
    # acme's win set TERM=dumb and show escapes as text, so skip colour there.
    programs.bash = {
      shellAliases = {
        banner = "cat ${banner}";
        service = "fastfetch";
      };
      initExtra = ''
        if [[ $TERM == dumb ]]; then
          cat ${banner}
        else
          printf '\e[38;2;${rgb cfg.bannerColour}m'
          cat ${banner}
          printf '\e[0m'
        fi
      '';
    };

    xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
      logo = {
        type = "file";
        source = "${globe}";
        color = { "1" = "blue"; };
        padding = { right = 3; };
      };
      display = {
        separator = "  ";
        color = { keys = "blue"; title = "blue"; };
      };
      modules = [
        (custom "SERVICE" "AT&T DATAGRID")
        (custom "INSTALLATION" cfg.installation)
        { type = "host"; key = "EQUIPMENT"; }
        { type = "os"; key = "OPERATING SYS"; }
        { type = "kernel"; key = "KERNEL"; }
        { type = "uptime"; key = "IN SERVICE"; }
        { type = "shell"; key = "COMMAND INTERP"; }
        { type = "terminal"; key = "TERMINAL"; }
        { type = "memory"; key = "CORE STORE"; }
        { type = "disk"; key = "MASS STORE"; }
        "break"
        (custom "MAINTENANCE" "CUSTOMER RESPONSIBILITY")
        (custom "STATUS" "ALL SYSTEMS NOMINAL")
      ];
    };
  };
}
