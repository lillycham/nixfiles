{ pkgs, config, lib, ... }:

{
  # Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
  imports = [
    ../common.nix
    # ./config/wm/xinit.nix
    # ./config/wm/wms.nix
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
      doas
      drawterm
      element-desktop
      fbterm
      firefox-devedition-bin
      fontconfig
      freetype
      glava
      gnome-builder
      gnome.dconf-editor
      gnome.zenity
      gnome3.gnome-tweaks
      gnumake
      google-chrome
      google-chrome-dev
      gwenview
      kmscon
      konsole
      kotatogram-desktop
      libsForQt5.neochat
      libsForQt5.qt5.qtwayland
      lm_sensors
      lsof
      lutris
      obs-studio
      openrgb
      p7zip
      pamixer
      parted
      pcem
      picom
      prismlauncher
      protontricks  
      qemu_full
      racket
      rust-analyzer
      sbcl
      spotify
      st
      stepmania
      tdesktop
      tor
      tor-browser-bundle-bin
      torsocks
      transmission-gtk
      wayfire
      wineWowPackages.staging
      winetricks
      yaft  
    ];
  };
}
