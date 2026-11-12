{ config, pkgs, lib, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  # Import shared nix configs
  imports = [
    ../common.nix
    ../../config/hydrus.nix
    ../../config/organize.nix
    ../../config/engi.nix
    ../../config/dashboard
    ../../config/akyuu-dev.nix
    ../../config/nixpkgs-sync.nix
    ../../config/obsidian.nix
    ../../config/sketchybar.nix
    inputs.nibble.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
    inputs.akyuu.homeModules.default
  ];

  bell-system.enable = true;

  # Keep Hugging Face models on the external drive. With the drive unplugged,
  # HF fails to create the folder instead of filling the internal disk.
  home.sessionVariables.HF_HOME = "/Volumes/Ext/hf";

  programs.spicetify = {
    enable = false;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      shuffle
      {
        name = "colourmush.js";
        src = ../../config/spicetify;
      }
    ];
  };

  # A small local model on demand. `nibble serve` runs under launchd and holds
  # no model until something connects. Settings live here, so nibble's own
  # settings page is read-only.
  services.nibble = {
    enable = true;
    gui.enable = true;
    # Models stay outside the store: they are large, and easy to swap.
    model = "${config.home.homeDirectory}/.local/share/nibble/models/Qwen3-4B-Instruct-2507-4bit";
    # What chats and Claude's delegated tasks may read. launchd starts the
    # server in /, so without this they could read nothing.
    settings.roots = [ "~/devel" "~/nixfiles" "~/Writing" ];
  };

  # A store of memories for agents. AKYUU_ROOT points at it, so `akyuu` and
  # `akyuu mcp` find it from any shell. GC and the backup run once a day under
  # launchd. The web UI is not a service: run `akyuu serve` when needed.
  # policyRef is the ref that `akyuu mcp` tells a client to read first.
  # Put ~/.local/bin on PATH (Hermes Agent installs its commands there).
  # The Hermes installer appends this line to the shell rc files, unless a
  # PATH=...~/.local/bin line is already there. Home Manager makes those files
  # read-only, so the append fails and the install stops. The login shell is
  # bash, so it touches .bashrc, .profile and .bash_profile.
  programs.bash =
    let
      pathLine = ''
        case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
      '';
    in
    {
      bashrcExtra = pathLine;
      profileExtra = pathLine;
    };

  # The GnuPG agent has no pinentry of its own on macOS, so a signature asked for
  # from a GUI app or an agent has nowhere to prompt. pinentry-mac opens a window,
  # and the passphrase stays cached for an hour (eight at most). After a switch:
  # gpgconf --kill gpg-agent
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    default-cache-ttl 3600
    max-cache-ttl 28800
  '';

  # Home Manager generates .bash_profile with no option to extend it.
  home.file.".bash_profile".source = lib.mkForce (pkgs.writeText "bash_profile" ''
    # include .profile if it exists
    [[ -f ~/.profile ]] && . ~/.profile

    # include .bashrc if it exists
    [[ -f ~/.bashrc ]] && . ~/.bashrc

    # Hermes Agent command
    case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
  '');

  programs.akyuu = {
    enable = true;
    package = inputs.lillycham-nur.packages.${pkgs.stdenv.hostPlatform.system}.akyuu;
    policyRef = "claude/memory-policy";
    gc.enable = true;
    backup.enable = true;
    # A git repository of the memories in the store root, one commit a day (04:15).
    versioning.enable = true;
    # Push each commit to the private remote (github.com/lillycham/akyuu-mem).
    versioning.push = true;
    # Search by meaning (docs/embeddings.md in the akyuu repo). Nix runs the
    # model (nomic-embed-text v1.5, Q8_0) with llama.cpp when a search needs it,
    # and stops it after 2 minutes idle. No other program has to be open.
    # Run `akyuu embed` once after the first switch.
    embed = {
      enable = true;
      local.enable = true;
      model = "nix-llama:nomic-v1.5-q8_0";
      queryPrefix = "search_query: ";
      documentPrefix = "search_document: ";
      minScore = 0.55;
    };
  };

  home = {
    packages = [
      pkgs.czkawka # Duplicate and similar-file finder. Run krokiet for the GUI.
      pkgs.grandperspective # Disk usage shown as a treemap.
      pkgs.omp # oh-my-pi coding agent, a fork of pi. Config lives in ~/.omp.
      # pkgs.telegram-desktop # Qt client. The Mac App Store one leaks memory and crashes.
      pkgs.sillytavern # Chat frontend for LLMs. Serves on http://localhost:8000.
      pkgs.spicetify-cli
      # My own command-line tools, from my NUR repository.
      inputs.lillycham-nur.packages.${pkgs.stdenv.hostPlatform.system}.lambdash
      inputs.lillycham-nur.packages.${pkgs.stdenv.hostPlatform.system}.why
    ];
  };

  # Copy apps instead of symlinking them, so Spotlight indexes them.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
