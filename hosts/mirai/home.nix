{ config, pkgs, ... }:
{
  # Import shared nix configs
  imports = [ ../common.nix ];
  home = {
    packages = with pkgs; [ ];
  };

  # Run Emacs as a daemon under launchd. Uses the package from programs.emacs.
  services.emacs.enable = true;

  # launchd starts agents with a minimal PATH, so give the daemon the Nix
  # profiles too (for git, language servers, etc.).
  launchd.agents.emacs.config.EnvironmentVariables.PATH = builtins.concatStringsSep ":" [
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
}
