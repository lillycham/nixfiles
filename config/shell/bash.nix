{
  programs.bash = {
    enable = true;
    # Export PATH Variable and initialize Starship Prompt
    bashrcExtra = ''
      export PATH=/Users/lillycham/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/Users/lillycham/Go/bin:/Users/lillycham/.cabal/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/zfs/bin
      eval "$(starship init bash)"
    '';
  };
}
