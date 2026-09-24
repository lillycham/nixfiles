{ pkgs, config, lib, ... }:
{
  nix.package = pkgs.lixPackageSets.stable.lix;

  # Make sure the nix daemon always runs
  services = {
    # emacs.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Install fonts
  fonts = {
    packages = with pkgs; [
      fira-code
      aileron
      go-font
      # input-fonts
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
      fish
      bash
      zsh
      neovim
      # gnupg
      git
      nixd
      nixpkgs-fmt
      sketchybar
      jq

      ### AI Tools
      (pkgs.symlinkJoin {
        name = "pi-coding-agent-wrapped";
        paths = [ pkgs.pi-coding-agent ];

        nativeBuildInputs = [ pkgs.makeWrapper ];
        # Overwrite the symlinked 'pi' binary with an environment-aware wrapper
        postBuild = ''
          wrapProgram $out/bin/pi \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs pkgs.bun ]}
        '';
      })

      # ((pkgs.emacsPackagesFor pkgs.emacs-macport).emacsWithPackages (import ../../config/editors/epkgs.nix))
    ];

    # Set the Nix SSL cert. May not be necessary, but randomly had issues
    # w/this, so leaving in.
    variables = {
      NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
      EDITOR = "hx";
    };
  };

  users = {
    users.lcham = {
      home = "/Users/lcham";
      shell = pkgs.fish;
      description = "Lilly Cham";
    };
  };

  nixpkgs.config = {
    # Allow "non-free" packages to be installed
    allowUnfree = true;
    input-fonts.acceptLicense = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = false;
    };

    # Enable automatic GC
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
    };
  };

  system.stateVersion = 6;
  system.primaryUser = "lcham";
}
