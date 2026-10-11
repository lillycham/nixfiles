{ config, pkgs, lib, inputs, ... }:
let
  emacs = config.services.emacs.package;

  # A tiny .app that opens a new frame on the Emacs daemon, so it can be
  # started from Spotlight without a terminal.
  emacsClientApp = pkgs.runCommand "emacs-client-app" { } ''
    app="$out/Applications/Emacs Client.app/Contents"
    mkdir -p "$app/MacOS" "$app/Resources"

    cp ${emacs}/Applications/Emacs.app/Contents/Resources/Emacs.icns "$app/Resources/"

    cat > "$app/MacOS/emacs-client" <<'EOF'
    #!/bin/sh
    # An empty -a starts a daemon if the launchd one isn't running.
    exec ${emacs}/bin/emacsclient -c -n -a "" \
      -e "(select-frame-set-input-focus (selected-frame))"
    EOF
    chmod +x "$app/MacOS/emacs-client"

    cat > "$app/Info.plist" <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>Emacs Client</string>
      <key>CFBundleDisplayName</key><string>Emacs Client</string>
      <key>CFBundleIdentifier</key><string>org.nix-community.home.emacs-client</string>
      <key>CFBundleExecutable</key><string>emacs-client</string>
      <key>CFBundleIconFile</key><string>Emacs</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleVersion</key><string>1.0</string>
      <!-- Frames belong to the daemon, so the launcher needs no Dock icon -->
      <key>LSUIElement</key><true/>
    </dict>
    </plist>
    EOF
  '';
in
{
  # Import shared nix configs
  imports = [
    ../common.nix
    ../../config/hydrus.nix
    ../../config/organize.nix
    inputs.nibble.homeModules.default
    inputs.akyuu.homeModules.default
  ];

  # Load each project's .envrc when I enter it. nix-direnv caches `use flake`
  # and keeps its devShell from being garbage collected. Fish picks the hook
  # up on its own.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
  programs.akyuu = {
    enable = true;
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
      emacsClientApp
      pkgs.czkawka # Duplicate and similar-file finder. Run krokiet for the GUI.
      pkgs.grandperspective # Disk usage shown as a treemap.
      pkgs.telegram-desktop # Qt client. The Mac App Store one leaks memory and crashes.
      pkgs.sillytavern # Chat frontend for LLMs. Serves on http://localhost:8000.
    ];
  };

  # Copy apps instead of symlinking them, so Spotlight indexes them.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };

  # Run Emacs as a daemon under launchd. Uses the package from programs.emacs.
  services.emacs.enable = true;

  # Start the daemon from inside Emacs.app, not bin/emacs, so macOS finds the
  # app bundle and shows the Emacs icon instead of a blank one.
  launchd.agents.emacs.config.ProgramArguments = lib.mkForce [
    "${emacs}/Applications/Emacs.app/Contents/MacOS/Emacs"
    "--fg-daemon"
  ];

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
