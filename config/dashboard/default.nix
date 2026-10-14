{ config, pkgs, lib, inputs, ... }:
let
  home = config.home.homeDirectory;
  akyuu = config.programs.akyuu;

  glancePort = 8091;
  shikiPort = 8092;
  # hydrus-web's port, from config/hydrus.nix.
  hydrusWebPort = 45880;

  minute = 60;
  hour = 60 * minute;
  day = 24 * hour;

  # The look: akyuu's embedded fonts, then the Manuscript rules for Glance.
  assets = pkgs.runCommand "glance-assets" { } ''
    mkdir $out
    cat ${inputs.akyuu}/web/fonts.css ${./manuscript.css} > $out/manuscript.css
  '';

  # The tile for shiki: one line per group, then only the probes that are not ok.
  shikiTemplate = ''
    <ul class="list list-gap-14">
    {{ range .JSON.Array "groups" }}
      <li>
        <div class="shiki-group">
          <span class="probe-dot probe-{{ .String "state" }}"></span>
          <span class="color-highlight shiki-name">{{ .String "group" }}</span>
          <span class="size-h6">{{ .String "summary" }}</span>
        </div>
        {{ range .Array "probes" }}{{ if ne (.String "state") "ok" }}
        <div class="shiki-probe size-h6"><span class="shiki-{{ .String "state" }}">{{ .String "name" }}</span> · {{ .String "summary" }}</div>
        {{ end }}{{ end }}
      </li>
    {{ end }}
    </ul>
  '';

  repository = name: {
    type = "repository";
    repository = "lillycham/${name}";
    pull-requests-limit = 3;
    issues-limit = 3;
    commits-limit = 3;
  };

  # JSON is YAML, so Glance reads this as it is.
  glanceConfig = pkgs.writeText "glance.yml" (builtins.toJSON {
    server = {
      host = "127.0.0.1";
      port = glancePort;
      assets-path = "${assets}";
    };
    branding = {
      app-name = "mirai";
      logo-text = "求";
      hide-footer = true;
    };
    theme = {
      # Washi. The stylesheet changes to ai when the system is dark, so the
      # picker is off.
      background-color = "45 27 94";
      primary-color = "217 64 45";
      positive-color = "152 47 31";
      negative-color = "9 70 41";
      light = true;
      custom-css-file = "/assets/manuscript.css";
      disable-picker = true;
    };
    pages = [{
      name = "mirai";
      columns = [
        {
          size = "small";
          widgets = [
            {
              type = "weather";
              # From the environment: see glanceStart.
              location = "\${GLANCE_WEATHER_LOCATION}";
              units = "metric";
              hour-format = "24h";
            }
            {
              type = "server-stats";
              servers = [{
                type = "local";
                name = "mirai";
                # On macOS "/" is the sealed system volume, which is always
                # full. The data is on the Data volume.
                hide-mountpoints-by-default = true;
                mountpoints."/System/Volumes/Data" = { name = "Data"; hide = false; };
              }];
            }
            {
              type = "monitor";
              title = "Sites";
              cache = "1m";
              sites = [{ title = "lillycham.com"; url = "https://lillycham.com"; }];
            }
          ];
        }
        {
          size = "full";
          widgets = [
            {
              type = "custom-api";
              title = "Shikigami";
              cache = "1m";
              url = "http://127.0.0.1:${toString shikiPort}/probes";
              template = shikiTemplate;
            }
            {
              type = "hacker-news";
              limit = 15;
              collapse-after = 6;
            }
          ];
        }
        {
          size = "small";
          widgets = [ (repository "akyuu") (repository "nibble") (repository "shiki") ];
        }
      ];
    }];
  });

  # Glance fills ${GLANCE_WEATHER_LOCATION} from the environment. The location
  # is in a file outside this repository, which is public.
  glanceStart = pkgs.writeShellScript "glance-start" ''
    location_file="${home}/.config/glance/weather-location"
    if [ -r "$location_file" ]; then
      GLANCE_WEATHER_LOCATION="$(cat "$location_file")"
    else
      GLANCE_WEATHER_LOCATION="London, United Kingdom"
    fi
    export GLANCE_WEATHER_LOCATION
    exec ${pkgs.glance}/bin/glance -config ${glanceConfig}
  '';
in
{
  imports = [ inputs.shiki.homeModules.default ];

  # The probes behind the Shikigami tile. Durations are in seconds.
  services.shiki = {
    enable = true;
    port = shikiPort;
    probes =
      let
        launchd = group: name: label: extra: { inherit group name label; kind = "launchd"; every = 5 * minute; } // extra;
        hm = name: "org.nix-community.home.${name}";
      in
      [
        (launchd "akyuu" "backup" "akyuu-backup" { })
        (launchd "akyuu" "version" "akyuu-version" { })
        (launchd "akyuu" "gc" "akyuu-gc" { })
        (launchd "akyuu" "embed" "akyuu-embed" { })
        {
          group = "akyuu"; name = "backups"; kind = "file-age";
          path = akyuu.backup.directory;
          warn-after = 26 * hour; fail-after = 50 * hour; every = 10 * minute;
        }
        {
          group = "akyuu"; name = "store"; kind = "git";
          path = akyuu.root;
          warn-after = 26 * hour; every = 10 * minute;
        }
        {
          group = "akyuu"; name = "check"; kind = "command";
          argv = [ "${akyuu.package}/bin/akyuu" "--root" akyuu.root "check" "--json" ];
          output = "json-array";
          warn-where.severity = "problem";
          count-by = "severity";
          every = 15 * minute; timeout = 30;
        }

        (launchd "hydrus" "client" (hm "hydrus-client") { running = true; every = minute; })
        (launchd "hydrus" "web" (hm "hydrus-web") { running = true; every = minute; })
        (launchd "hydrus" "tagger" (hm "hydrus-tagger") { })
        { group = "hydrus"; name = "api"; kind = "http"; url = "http://127.0.0.1:45869/api_version"; }
        {
          group = "hydrus"; name = "inbox"; kind = "dir-count";
          path = "${home}/Pictures/Hydrus Inbox";
          warn-above = 50; every = 5 * minute;
        }

        (launchd "nibble" "serve" (hm "nibble") { running = true; every = minute; })
        { group = "nibble"; name = "proxy"; kind = "http"; url = "http://127.0.0.1:8765/"; }

        (launchd "mirai" "emacs" (hm "emacs") { running = true; every = minute; })
        (launchd "mirai" "organize" (hm "organize") { })
        (launchd "mirai" "glance" (hm "glance") { running = true; every = minute; })
        {
          group = "mirai"; name = "weekly review"; kind = "file-age";
          path = "${home}/nixfiles/.claude-review";
          warn-after = 8 * day; every = hour;
        }
        {
          group = "mirai"; name = "nixfiles"; kind = "git";
          path = "${home}/nixfiles";
          every = 10 * minute;
        }
      ];
  };

  launchd.agents.glance = {
    enable = true;
    config = {
      ProgramArguments = [ "${glanceStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${home}/Library/Logs/glance.log";
      StandardErrorPath = "${home}/Library/Logs/glance.log";
    };
  };

  # Put the dashboard on the tailnet: https://<this machine's tailnet name>/,
  # and hydrus-web on port 8443. Tailscale keeps this in its own state, so this
  # sets it again at each switch. The CLI is from the standalone Tailscale app
  # (see hosts/mirai/default.nix).
  home.activation.tailscaleServe = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ts=/Applications/Tailscale.app/Contents/MacOS/Tailscale
    if [ -x "$ts" ]; then
      run "$ts" serve --bg --https=443 http://127.0.0.1:${toString glancePort} > /dev/null \
        || warnEcho "tailscale serve failed for the dashboard"
      run "$ts" serve --bg --https=8443 http://127.0.0.1:${toString hydrusWebPort} > /dev/null \
        || warnEcho "tailscale serve failed for hydrus-web"
    else
      warnEcho "Tailscale.app is missing, so the dashboard is not on the tailnet"
    fi
  '';
}
