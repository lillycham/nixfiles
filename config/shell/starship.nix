{ config, lib, ... }:
let
  starship = lib.getExe config.programs.starship.package;
in
{
  # Home Manager's hooks only skip starship when TERM=dumb. These also skip it
  # when NO_STARSHIP is set, for a plain prompt: NO_STARSHIP=1 bash
  programs.bash.initExtra = ''
    if [[ $TERM != dumb && -z ''${NO_STARSHIP-} ]]; then
      eval "$(${starship} init bash --print-full-init)"
    fi
  '';
  programs.fish.interactiveShellInit = ''
    if test "$TERM" != dumb; and not set -q NO_STARSHIP
      ${starship} init fish | source
    end
  '';

  programs.starship = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    settings = {
      format = "$shell$all";

      character = {
        success_symbol = "[λ](bold #ffb6c1)";
        error_symbol = "[ƛ](bold red)";
        vicmd_symbol = "[γ](bold #ffb6c1)";
      };

      git_status = {
        ahead = ">";
behind = "<";
diverged = "<>";
renamed = "r";
deleted = "x";
      };

      aws.symbol = "aws ";
      conda.symbol = "conda ";
      dart.symbol = "dart ";

      directory = {
        read_only = " ro";
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        style = "bold #f88278";
        truncation_symbol = "../";
        home_symbol = "~";
      };

      docker_context.symbol = "docker ";
      elixir.symbol = "ex ";
      elm.symbol = "elm ";
      git_branch.symbol = "git/";
      golang.symbol = "go ";
      haskell.symbol = "hs ";
      hg_branch = {
        symbol = "hg/";
        disabled = false;
      };
      java.symbol = "java ";
      julia.symbol = "jl ";
      memory_usage.symbol = "mem ";
      nim.symbol = "nim ";
      nix_shell = {
        symbol = "nix ";
        impure_msg = "impure";
        pure_msg = "pure";
        format = "via [$symbol$state $name](bold blue) ";
      };
      perl.symbol = "pl ";
      php.symbol = "php ";
      python = {
        symbol = "py ";
        python_binary = [ "py" "python3" "python2.7" ];
      };

      ruby.symbol = "rb ";
      rust.symbol = "rs ";
      scala.symbol = "scala ";
      swift.symbol = "swift ";
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
        symbol = "tailscale";
        format = "(connected to [Tailscale](bold #ff9899)) ";
        disabled = true;
        when =
          "/Applications/Tailscale.app/Contents/MacOS/Tailscale status == 0";
      };
    };
  };
}
