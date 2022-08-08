{
  programs.bash = {
    enable = true;
    # Export PATH Variable and initialize Starship Prompt
    bashrcExtra = ''
      export PATH=~/.nix-profile/bin:/nix/var/nix/profiles/default/bin:~/Go/bin:~/.cabal/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/zfs/bin
      if [ -z "$PS1" ]; then
        return
      fi
      eval "$(starship init bash)"
    '';
  };
}
