{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # The firmware comes from /boot/vendorfw and must stay out of this repository,
  # so build this host on omoide with --impure.
  hardware.asahi.enable = true;

  # U-Boot doesn't let Linux write EFI variables.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # hardware-configuration.nix is generated, so tighten the ESP here. It holds
  # the systemd-boot random seed.
  fileSystems."/boot".options = lib.mkForce [ "fmask=0077" "dmask=0077" ];

  networking.hostName = "omoide";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  time.timeZone = "Europe/London";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Eight eMudhra intermediates have tiny private keys (2026-10-20), so distrust
  # their two roots, as on mirai. Drop the blacklist once cacert is 3.131.1+.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];

  services.xserver.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  programs.niri.enable = true;
  programs.firefox.enable = true;

  # niri's config.kdl starts waybar, so don't set programs.waybar.enable: its
  # systemd unit would start a second bar.
  environment.systemPackages = with pkgs; [
    alacritty
    # niri's brightness keys call it. It goes through logind, so it needs no
    # udev group.
    brightnessctl
    fuzzel
    git
    mako
    swayidle
    swaylock
    vim
    waybar
    # Shows the key names that niri binds use.
    wev
    wget
  ];

  # The icons in waybar's default config.
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
    roboto
  ];

  # pinentry-gnome3 prompts through gcr.
  services.dbus.packages = [ pkgs.gcr ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.lcham = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [ tree ];
  };

  services.openssh.enable = true;

  # Do not change this. See `man configuration.nix`.
  system.stateVersion = "26.11";
}
