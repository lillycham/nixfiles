{ config, pkgs, ... }:
let
  inherit (pkgs) stdenv;
in
{
  programs.kitty = { 
    enable = true;
    settings = {
      font_size = if stdenv.isLinux then "12.0" else "14.0";
      font_family = "Liga SFMono Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      background = "#212733";
      foreground = "#d9d7ce";
      cursor = "#ffcc66";
      selection_background = "#343f4c";
      color0 = "#191e2a";
      color8 = "#686868";
      color1 = "#ed8274";
      color9 = "#f28779";
      color2  = "#a6cc70";
      color10 = "#bae67e";
      color3  = "#fad07b";
      color11 = "#ffd580";
      color4  = "#6dcbfa";
      color12 = "#73d0ff";
      color5  = "#cfbafa";
      color13 = "#d4bfff";
      color6  = "#90e1c6";
      color14 = "#95e6cb";
      color7  = "#c7c7c7";
      color15 = "#ffffff";
      selection_foreground = "#212733";
    };
  };
}
