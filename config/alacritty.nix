{ config, lib, pkgs, specialArgs, ... }:
{
	programs.alacritty = {
	  enable = true;
	  settings = {
	    keybindings = [
	      { key = "Equals";     mods = "Control";     action = "IncreaseFontSize"; }
	      { key = "Add";        mods = "Control";     action = "IncreaseFontSize"; }
	      { key = "Subtract";   mods = "Control";     action = "DecreaseFontSize"; }
	      { key = "Minus";      mods = "Control";     action = "DecreaseFontSize"; }
	    ];

			font = let fontname = "Liga SFMono Nerd Font"; in {
        normal = { family = fontname; style = "Medium"; };
        bold = { family = fontname; style = "Bold"; };
        italic = { family = fontname; style = "Light"; };
        size = 13;
      };
			cursor.style = "Block";

	    colors = {
	      primary = {
	        background =  "0x202734";
	        foreground =  "0xCBCCC6";
	      };

	      normal = {
	        black =    "0x191e2a";
	        red =      "0xff3333";
	        green =    "0xbae67e";
	        yellow =   "0xffa759";
	        blue =     "0x73d0ff";
	        magenta =  "0xffd580";
	        cyan =     "0x95e6cb";
	        white =    "0xc7c7c7";
	      };

	      bright = {
	        black =    "0x686868";
	        red =      "0xf27983";
	        green =    "0xa6cc70";
	        yellow =   "0xffcc66";
	        blue =     "0x5ccfe6";
	        magenta =  "0xffee99";
	        cyan =     "0x95e6cb";
	        white =    "0xffffff";
	      };
	    };
	  };
	};
}