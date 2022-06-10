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
    parted
    tdesktop
    appimage-run
    kmscon
    st
    swift
    drawterm
    gnome-builder
    wineWowPackages.staging
    winetricks
    code-server
    gnumake
    qemu_full
    konsole
    wayfire
    libsForQt5.qt5.qtwayland
    gnome.dconf-editor
    discord
    google-chrome
    lsof
    chrome-gnome-shell
    doas
    gnome3.gnome-tweaks
    fbterm
    fontconfig
    yaft
    freetype
  ];
}
