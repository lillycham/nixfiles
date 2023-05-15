{ pkgs, config, lib, ... }:

{
  # Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
  imports = [
    ../common.nix
  ];
  
  manual.manpages.enable = false;

  # Override Swift's tests, as they seem to be broken on Linux.
  nixpkgs.config.packageOverrides = pkgs: rec {
    swift = pkgs.swift.overrideDerivation (attrs: {
      doCheck = false;
      checkInputs = [ ];
      checkPhase = "";
    }
    );
  };
  
  home = {
    username = ("lillycham");
    homeDirectory = "/home/lillycham";
    # Packages to install - specific to linux
    packages = with pkgs; [
      appimage-run
      chrome-gnome-shell
      discord
      fontconfig
      freetype
      glava
      gnumake
      google-chrome-dev
      gwenview
      kmscon
      konsole
      libsForQt5.qt5.qtwayland
      lm_sensors
      lsof
      lutris
      obs-studio
      p7zip
      parted
      prismlauncher
      protontricks  
      qemu_full
      rust-analyzer
      spotify
      stepmania
      tdesktop
      tor-browser-bundle-bin
      torsocks
      transmission-gtk
      wayfire
    ];
  };
}
