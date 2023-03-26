{
  programs.fish = {
    enable = true;
    shellAbbrs = {      
      a = "acme";
      drs = "darwin-rebuild switch --flake ~/nixfiles";
      e = "emacs";
      g = "git";
      gc = "nix store gc";
      hms = "home-manager switch";
      m = "make";
      n = "nvim";
      nrs = "nixos-rebuild switch";
      o = "open";
      s = "sudo";
      b = "nix build";
      r = "nix run";
    };

    # interactive init
    shellInit = ''
      starship init fish | source
      # Fancy regex based flake run/build commands
      abbr -a nix_run_flake --position command --regex ".+#.+" --function nix_runner
      abbr -a L --position anywhere --set-cursor "% | less"
      abbr -a --position anywhere -- -sht --show-trace
      direnv hook fish | source
    '';
    
    functions = {
      # MOTD message
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = ''
          echo Welcome to fish, the friendly interactive shell
          echo -n It\'s (set_color yellow;date ; set_color normal)
          echo on $hostname
          echo For help with using fish type (set_color green; echo help; set_color normal)
          echo Have a great day!
        '';
      };

      mkdcd = {
        description = "Make a directory tree and enter it";
        body = "mkdir -p $argv[1]; and cd $argv[1]";
      };

      nix_runner = {
        description = "Run a nix flake";
        body = "echo nix run $argv";
      };

      nix_fbuilder = {
        description = "Run a nix flake";
        body = "echo nix build $argv";
      };
    };
  };
}
