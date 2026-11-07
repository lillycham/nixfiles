# engi archives closed agent sessions (Claude Code, Codex, omp, pi): it strips
# image data and signatures, compresses each session with zstd and records it in
# a manifest. It never changes or deletes an original.
#
# - `engi-archive` runs once a day under launchd. It archives, then verifies.
#   A job that was missed (the Mac was asleep) runs when the Mac wakes.
# - Export to an external drive is off until `exportRecipient` and `exportDest`
#   are set. Then a second agent runs each time a volume is mounted, and sends
#   the new files, encrypted with age, if the destination folder exists. It
#   needs only the public key. Keep the private key off this Mac.
{ config, pkgs, lib, inputs, ... }:
let
  engi = inputs.lillycham-nur.packages.${pkgs.stdenv.hostPlatform.system}.engi;
  home = config.home.homeDirectory;

  archive = "${home}/.local/share/engi/archive";

  # The folders that agents write sessions to, by agent name.
  sources = {
    claude = "${home}/.claude/projects";
    codex = "${home}/.codex/sessions";
    omp = "${home}/.omp/agent/sessions";
    pi = "${home}/.pi/agent/sessions";
  };
  sourceArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (agent: dir: "--source ${agent}=${lib.escapeShellArg dir}") sources
  );

  # Set both to turn on the export. The recipient is a public key (age1...).
  # The destination is a folder on the drive. It must exist, so a drive that is
  # not mounted is never written to the internal disk.
  # The private key is not on this Mac.
  exportRecipient = "age1equ37c706ca4t4f7x9pc462zvxn8hg57uq0etxhj84pj43tlfdks4vzhnc";
  # The export runs only when this folder exists. Make it with
  # `mkdir /Volumes/Ext/engi` when you want the export to start.
  exportDest = "/Volumes/Ext/engi";
  exportOn = exportRecipient != null && exportDest != null;

  logFile = "${home}/Library/Logs/engi.log";

  archiveScript = pkgs.writeShellApplication {
    name = "engi-archive";
    runtimeInputs = [ engi ];
    text = ''
      mkdir -p ${lib.escapeShellArg archive}
      echo "== $(date -u +%Y-%m-%dT%H:%M:%SZ) archive"
      status=0
      engi archive --archive ${lib.escapeShellArg archive} ${sourceArgs} || status=1
      engi verify --archive ${lib.escapeShellArg archive} || status=1
      exit "$status"
    '';
  };

  exportScript = pkgs.writeShellApplication {
    name = "engi-export";
    runtimeInputs = [ engi ];
    text = ''
      dest=${lib.escapeShellArg (toString exportDest)}
      if [ ! -d "$dest" ]; then
        echo "engi-export: $dest is not there (drive not mounted?), nothing to do"
        exit 0
      fi
      echo "== $(date -u +%Y-%m-%dT%H:%M:%SZ) export"
      engi export --archive ${lib.escapeShellArg archive} --dest "$dest" --recipient ${lib.escapeShellArg (toString exportRecipient)}
    '';
  };
in
{
  home.packages = [ engi ] ++ lib.optional exportOn exportScript;

  launchd.agents.engi-archive = {
    enable = true;
    config = {
      ProgramArguments = [ "${archiveScript}/bin/engi-archive" ];
      StartCalendarInterval = [
        {
          Hour = 3;
          Minute = 30;
        }
      ];
      ProcessType = "Background";
      LowPriorityIO = true;
      Nice = 10;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };

  launchd.agents.engi-export = lib.mkIf exportOn {
    enable = true;
    config = {
      ProgramArguments = [ "${exportScript}/bin/engi-export" ];
      StartOnMount = true;
      ProcessType = "Background";
      LowPriorityIO = true;
      Nice = 10;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
