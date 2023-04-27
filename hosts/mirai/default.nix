{ pkgs, config, lib, nixpkgs, nixpkgs-tny, ... }:
{
  # Import homebrew package config
  imports = [ ./brew.nix ];
  
  # Make sure the nix daemon always runs
  services = {
    nix-daemon.enable = true;
    # emacs.enable = true;
    
  };
  
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
      fish
      bash
      zsh
      neovim
      #((pkgs.emacsPackagesFor pkgs.emacsMacport).emacsWithPackages (import ../../config/editors/epkgs.nix))
    ];

    # Set the Nix SSL cert. May not be necessary, but randomly had issues
    # w/this, so leaving in.
    variables = {
      NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
      EDITOR = "hx";
    };
  };

  users = {
    users.lillycham = {
      home = /Users/lillycham;
      shell = pkgs.fish;
      description = "Lilly Cham";
    };

    groups = {
      devel = {
        members = ["lillycham"];
      };
    };
  };

  nixpkgs.config = {
    # Allow "non-free" packages to be installed
    allowUnfree = true;
    input-fonts.acceptLicense = true;
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    
    package = pkgs.nixUnstable;

    # Enable automatic GC
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
    };
  };
}
