{ config, pkgs, ... }:

{
  # Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
  imports = [
    ./common.nix
    ./config/xinit.nix
    ./config/wm/wms.nix
  ];

  # Override Swift's tests, as they seem to be broken on Linux.
  nixpkgs.config.packageOverrides = pkgs: rec {
    swift = pkgs.swift.overrideDerivation (attrs: {
      doCheck = false;
      checkInputs = [ ];
      checkPhase = "";
    }
    );
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz")).overlay
  ];

  home.username = ("lillycham");
  home.homeDirectory = "/home/lillycham";

  # Packages to install - specific to linux
  home.packages = with pkgs; [
    # swift
    appimage-run
    chrome-gnome-shell
    code-server
    discord
    doas
    drawterm
    fbterm
    fontconfig
    firefox-devedition-bin
    freetype
    gnome-builder
    gnome.dconf-editor
    gnome3.gnome-tweaks
    gnumake
    google-chrome-dev
    google-chrome
    gwenview
    jdk
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rider
    jetbrains.ruby-mine
    jetbrains.webstorm
    kmscon
    konsole
    libsForQt5.qt5.qtwayland
    lm_sensors
    lsof
    obs-studio
    openrgb
    pamixer
    parted
    picom
    polymc
    qemu_full
    racket
    sbcl
    st
    stepmania
    tdesktop
    transmission-gtk
    wayfire
    winetricks
    wineWowPackages.staging
    yaft
  ];
}
