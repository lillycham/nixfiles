---
name: nix-darwin-switch
description: Safely change and apply Lilly's system config in ~/nixfiles with darwin-rebuild (mirai, the Mac) or nixos-rebuild (ikigai, the PC, which does not run Nix at the moment). Use when she asks to rebuild, switch, apply, deploy or update the system, roll back, see what changed, list generations, or change the nix-darwin or home-manager config.
---

# Building and switching the system

Read `nix-dev` first. Building and diffing are safe. **Switching changes the running system: get a clear yes from Lilly first, every time.** An earlier yes does not cover a later switch.

Hosts: `mirai` (aarch64-darwin, `darwin-rebuild`), `ikigai` (x86_64-linux, `nixos-rebuild`). Check with `hostname -s` and build the host you are on. Do not build `ikigai` on `mirai` unless she asks.

**ikigai does not run Nix at the moment** (as of 2026-10-05). Its config stays in the flake. Do not build it, switch it, or report its config as broken unless she asks.

**Emacs uses two repos.** `~/nixfiles` has the Emacs packages, the launchd daemon (`org.nix-community.home.emacs`) and the emacsclient launcher. `~/.emacs.d` is a separate git repo with `init.el` and the themes. When a change touches both, commit each repo on its own, and push both when she asks ("commit and push both").

## The workflow

1. **Edit** the config in `~/nixfiles` (`hosts/<name>/`, `hosts/common.nix`, `config/`, `overlays/`, `pkgs/`). Run `git add -N` for new files, because the flake ignores untracked files.
2. **Build and diff without switching.** Use `nh`. It builds with a progress display and prints a closure diff. It does not change the system:
   ```bash
   nh darwin build ~/nixfiles -H mirai
   ```
   `-H` picks the host from `darwinConfigurations`. On a failure, see `nix-build-debug`. To build without `nh`: `darwin-rebuild build --flake ~/nixfiles#mirai`, then `nix store diff-closures /run/current-system ./result`.
3. **Report the diff.** `nh` ends with `PATHS`, `SIZE` and `DIFF` lines, and "No version or size changes" for an empty diff. Summarise it for Lilly: packages added, removed, upgraded, and anything surprising (a big closure, a service restart).
4. **Ask.** Say what the diff shows and ask if she wants to switch. Wait for a clear yes.
5. **Switch**, only after the yes. It needs sudo, so it may need her to run it:
   ```bash
   nh darwin switch ~/nixfiles -H mirai --ask
   ```
   `nh` calls sudo itself, and `--ask` makes it show the diff and wait for her answer. Both need a terminal, so a tool call cannot finish this. Give her the command in a fenced `bash` block to run herself. Do not try to work around the password prompt.
6. **Check:** `darwin-rebuild --list-generations | tail -3`. Then `git status` in `~/nixfiles`.

On NixOS the same steps use `nh os build|switch ~/nixfiles -H ikigai`. `nh os test` activates without making a boot entry, and `nh os rollback` goes back (a switch: ask first). `nh os info` lists generations. `nh home build|switch` is the same for a standalone home-manager config.

## Rolling back

```bash
darwin-rebuild --list-generations          # what exists
darwin-rebuild switch --rollback           # go back one; this is a switch: ask first
                                           # (`nh darwin` has no rollback command)
```

A generation that was deleted does not come back. Do not run `nix-collect-garbage -d` or `nh clean` or delete generations without a clear yes, because old generations are the rollback points. `nh clean all` keeps only 1 generation by default. If she asks for it, add `--keep <n>` or `--keep-since <duration>`, and try `--dry` first (`nh clean all --dry` still needs sudo).

## Updating inputs

Update one input at a time and say which:

```bash
nix flake update nixpkgs            # not all inputs at once
nix flake update nixpkgs-emacs      # on purpose: it rebuilds all Emacs packages
```

Then run steps 2 and 3 above. `nh darwin build -U <input>` updates one input and builds in one step. The `flake.lock` diff goes in its own commit.

## Do not

- Do not run `switch`, `activate`, `./result/activate` or any `sudo` command without a fresh yes.
- Do not edit `/etc`, `/run/current-system` or the Nix daemon config by hand. Change `~/nixfiles` instead.
- Do not run `nix flake update` with no input name.
- Do not commit or push `~/nixfiles` unless asked. If asked, follow her commit rules (Conventional Commits, ASD-STE100 body).
