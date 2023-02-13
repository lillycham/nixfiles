{ pkgs, config, lib, ... }:

{
  # Import common.nix, with all of our packages and configs, then define any linux "platform specific" configs in here
  imports = [
    ./common.nix
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

  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz")).overlay
  ];

  home.username = ("lillycham");
  home.homeDirectory = "/home/lillycham";

  # Packages to install - specific to linux
  home.packages = with pkgs; [
    appimage-run
    prismlauncher
    chrome-gnome-shell
    #code-server
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
    gnome3.gnome-tweaks
    gnumake
    google-chrome
    google-chrome-dev
    gwenview
    kmscon
    konsole
    kotatogram-desktop
    libsForQt5.qt5.qtwayland
    lm_sensors
    lsof
    libsForQt5.neochat
    lutris
    obs-studio
    openrgb
    pamixer
    parted
    pcem
    picom
    qemu_full
    racket
    rust-analyzer
    sbcl
    spotify
    st
    stepmania
    tdesktop
    tor-browser-bundle-bin
    torsocks
    tor
    transmission-gtk
    wayfire
    wineWowPackages.staging
    winetricks
    yaft
    p7zip
    gnome.zenity
    protontricks    
  ];
}
