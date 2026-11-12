{ pkgs, ... }:
# The M1 MacBook Air booted into macOS. The same machine boots NixOS as
# omoide (hosts/omoide). It has 8 GB of memory and a small macOS partition,
# so this config stays much lighter than mirai's.
{
  nix.package = pkgs.lixPackageSets.stable.lix;

  networking = {
    hostName = "omoide-mac";
    computerName = "omoide-mac";
    localHostName = "omoide-mac";
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  fonts.packages = with pkgs; [
    fira-code
    ibm-plex
    nerd-fonts.symbols-only
  ];

  environment = {
    systemPackages = with pkgs; [
      fish
      bash
      zsh
      neovim
      git
      claude-code
      codex
    ];

    variables =
      let
        caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      in
      {
        NIX_SSL_CERT_FILE = caBundle;
        SSL_CERT_FILE = caBundle;
      };
  };

  users.users.lcham = {
    home = "/Users/lcham";
    shell = pkgs.fish;
    description = "Lilly Cham";
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;
      trusted-users = [ "lcham" ];
      # The macOS partition is small (about 45 GiB free on 2026-11-12).
      # Collect garbage during a build if free space falls under 3 GiB.
      min-free = 3 * 1024 * 1024 * 1024;
      max-free = 10 * 1024 * 1024 * 1024;
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 14d";
    };
  };

  # Spotlight indexing of the Nix store wastes CPU and IO.
  system.activationScripts.postActivation.text = ''
    /usr/bin/mdutil -i off /nix >/dev/null 2>&1 || true
  '';

  system.stateVersion = 6;
  system.primaryUser = "lcham";
}
