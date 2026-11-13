{ config, pkgs, lib, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  akyuuBin = lib.getExe inputs.lillycham-nur.packages.${system}.akyuu;
  nibbleBin = "${inputs.nibble.packages.${system}.default}/bin/nibble";
in
{
  imports = [ inputs.skillx.homeModules.default ];

  programs.skillx = {
    enable = true;
    name = "lilly-skills";
    version = "0.1.0";
    sources.local = ../skills;

    always = [ "claude" ];
    entry = [
      "asd-ste100"
      "consolidate-memory"
      "finish-branch"
      "learn-by-building"
      "nix-dev"
      "obsidian-notes"
      "subagent-branch-task"
      "why"
    ];

    mcp = {
      akyuu = {
        command = akyuuBin;
        args = [ "--root" "${config.home.homeDirectory}/.local/share/akyuu" "mcp" ];
      };
      nibble = {
        command = nibbleBin;
        args = [ "mcp" ];
      };
      obsidian = {
        command = "${config.home.profileDirectory}/bin/obsidian-mcp";
        args = [ ];
      };
    };

    hooks = {
      akyuu-context = {
        event = "SessionStart";
        inject = true;
        command = ''
          for page in 1 2 3; do
            ${akyuuBin} --root "$HOME/.local/share/akyuu" context --page "$page" 2>/dev/null || true
            printf '\n'
          done
        '';
      };
    };

    availableBins = [
      "git"
      "gh"
      "nh"
      "nix"
      "why"
    ];

    places = {
      "~/devel/nur-packages".entry = [ "nur-release" ];
      "~/nixfiles".entry = [ "nix-darwin-switch" ];
    };

    targets = {
      claudeCode.enable = true;
      antigravity.enable = true;
      openCode.enable = true;
      codex.enable = true;
    };
  };
}
