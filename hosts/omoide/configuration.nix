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

  services.xserver.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  programs.niri.enable = true;
  programs.waybar.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    git
    mako
    swayidle
    swaylock
    vim
    wget
  ];

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
