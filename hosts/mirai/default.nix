{ pkgs, config, lib, nixpkgs, ... }:
{
  imports = [ ./brew.nix ];
  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;
  
  programs.zsh.enable  = true;
  programs.fish.enable = true;

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      fira-code
      aileron
      go-font
      input-fonts
      roboto
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      home-manager
      iina
      iterm2
      utm
    ];

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
    allowUnfree = true;
    input-fonts.acceptLicense = true;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    package = pkgs.nixUnstable;
  };
}
