{
  programs.starship = {
    enable = true;
    settings = {
      format = "$shell$all";

      character = {
        success_symbol = "[λ](bold #ffb6c1)";
        error_symbol = "[ƛ](bold red)";
        vicmd_symbol = "[γ](bold #ffb6c1)";
      };

      aws.symbol = "  ";
      conda.symbol = " ";
      dart.symbol = " ";

      directory = {
        read_only = " ";
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        style = "bold #f88278";
        truncation_symbol = "../";
        home_symbol = " ~";
      };

      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      haskell.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = " ";
      nim.symbol = " ";
      nix_shell.symbol = " ";
      perl.symbol = " ";
      php.symbol = " ";
      python = {
        symbol = " ";
        python_binary = [ "py" "python3.9" "python2.7" ];
      };

      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      swift.symbol = "ﯣ ";
      hostname = {
        ssh_only = false;
        format = "on [$hostname](bold #fd6c9e) ";
        disabled = false;
      };

      shell = {
        fish_indicator = "Fish";
        bash_indicator = "Bash";
        zsh_indicator = "Zsh";
        ion_indicator = "Ion";
        elvish_indicator = "Elvish";
        tcsh_indicator = "Tcsh";
        xonsh_indicator = "Xonsh";
        nu_indicator = "Nu Shell";
        powershell_indicator = "PowerShell";
        unknown_indicator = "Unknown shell";
        format = "[✿ $indicator]($style) ";
        style = "#9866c7 bold";
        disabled = false;
      };

      username = {
        style_user = "#ffb6c1 bold";
        style_root = "red bold";
        format = "as [$user]($style) ";
        disabled = false;
        show_always = true;
      };

      cmd_duration = { format = "took [$duration](bold #0c819c) "; };

      custom.tailscale = {
        description = "Shows the current tailscale status";
        symbol = "歷";
        format = "(connected to [Tailscale](bold #ff9899)) ";
        disabled = true;
        when =
          "/Applications/Tailscale.app/Contents/MacOS/Tailscale status == 0";
      };
    };
  };
}
