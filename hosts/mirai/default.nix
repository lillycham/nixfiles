{ pkgs, config, lib, nixpkgs, ... }:
{
  # Import homebrew package config
  imports = [ ./brew.nix ];
  
  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;
  
  programs.zsh.enable  = true;
  programs.fish.enable = true;

  # Install fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      fira-code
      aileron
      go-font
      input-fonts
      roboto
      lmmath
    ];
  };

  environment = {
    # Packages that should be available globally
    systemPackages = with pkgs; [
      home-manager
      iina
      iterm2
      utm
    ];

    # Set the Nix SSL cert. May not be necessary, but randomly had issues
    # w/this, so leaving in.
    variables = {
      NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
    };
  };

  users = {
    users.lillycham = {
      home = /Users/lillycham;
    };
  };

  nixpkgs.config = {
    # Allow "non-free" packages to be installed
    allowUnfree = true;
    input-fonts.acceptLicense = true;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    package = pkgs.nixUnstable;
  };
}
