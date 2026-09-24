{ config, pkgs, lib, ... }:
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
  ];
  home = {
    packages = [ emacsClientApp ];
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
