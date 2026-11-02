# A text login on an acme-cream console, in place of LightDM: greetd runs
# tuigreet with the Bell System banner, then starts niri.
{ config, lib, pkgs, ... }:
let
  bannerLines = [
    "AT&T BELL LABORATORIES"
    "COMPUTING SYSTEMS DIVISION"
    ""
    "INSTALLATION:  07-8290"
    "EQUIPMENT:     PERSONAL UNIX TERMINAL"
    ""
    "UNAUTHORIZED INFERENCE IS BILLABLE."
  ];
  # tuigreet centres each line on its own, so pad them all to one width: the
  # block is centred and the columns stay aligned.
  width = lib.foldl' lib.max 0 (map lib.stringLength bannerLines);
  pad = s: s + lib.concatStrings (lib.replicate (width - lib.stringLength s) " ");
  greeting = lib.concatMapStringsSep "\n" pad bannerLines;

  gallant = pkgs.callPackage ../../pkgs/gallant-psf.nix { };

  # tuigreet names ANSI colours, and the palette below swaps black and white:
  # "black" is the cream background and "white" is the black ink.
  theme = lib.concatStringsSep ";" [
    "container=black"
    "border=blue"
    "greet=blue"
    "time=blue"
    "title=blue"
    "text=white"
    "prompt=blue"
    "input=white"
    "action=blue"
    "button=white"
  ];

  # greetd's own config parser can't read a multi-line string, and Nix
  # writes the banner's newlines as one. So greetd gets only this script.
  greeter = pkgs.writeShellScript "bell-greeter" ''
    exec ${lib.escapeShellArgs [
      (lib.getExe pkgs.tuigreet)
      "--time"
      "--remember"
      "--asterisks"
      "--greeting" greeting
      "--theme" theme
      # By name, so the bottom bar shows no store path. programs.niri puts
      # it in the system path.
      "--cmd" "niri-session"
    ]}
  '';
in
{
  # The console palette, in ANSI order. Colour 0 is the background and 7 the
  # text, so they become acme's body and ink; the rest are the alacritty inks.
  console = {
    colors = [
      "ffffea" "aa0000" "006600" "7a6a00" "000099" "770077" "006b6b" "000000"
      "777777" "cc3333" "3a7a3a" "99994c" "3333bb" "993399" "338f8f" "000000"
    ];
    # Sun's Gallant at its own 12x22, as on a SPARCstation.
    font = "${gallant}/${gallant.fontFile}";
    earlySetup = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${greeter}";
    };
  };

  # LightDM unlocked the keyring at login. Now greetd must, or every app that
  # stores a secret asks for the password again.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # tuigreet keeps the last user name here for --remember.
  systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0755 greeter greeter -" ];
}
