{ config, pkgs, ... }:

{
  # Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
  imports = [
    ./common.nix
    ./config/xinit.nix
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
    freetype
    gnome-builder
    gnome.dconf-editor
    gnome3.gnome-tweaks
    gnumake
    google-chrome
    kmscon
    konsole
    libsForQt5.qt5.qtwayland
    lm_sensors
    lsof
    obs-studio
    parted
    qemu_full
    st
    tdesktop
    wayfire
    winetricks
    wineWowPackages.staging
    yaft
  ];
}
