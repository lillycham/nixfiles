---
name: nix-dev
description: Lilly's Nix conventions and the entry point to her other Nix skills. Use when a project needs a toolchain or dev environment (cargo, python, node and so on), when creating or editing a flake.nix, .envrc or devShell, touching her ~/nixfiles system config, or when a command is missing on this machine, because the answer is Nix, not a system tool.
links: nix-build-debug, nix-darwin-switch, nix-flake-ops, nix-package, nix-run-shell, nix-store-inspect, why
requires-bin: nh, nix
---

# Nix, the way Lilly does it

## The main rule

**Get toolchains from Nix. Do not use system tools.** Do not use the Xcode or `/usr/bin` toolchain (`swift`, Apple's `python3` 3.9, `gcc` and so on), Homebrew, or `pip install --user`. They are not portable, and Lilly has said she does not want them. If a command is missing, get it from nixpkgs (see `nix-run-shell`):

```bash
nix shell nixpkgs#cargo nixpkgs#rustc -c cargo --version   # one-off
nix develop -c <cmd>                                         # inside a project flake
```

`nix` here is Lix, with `nix-command` and `flakes` already enabled. No `--extra-experimental-features` flag is needed.

## Which skill

| Task | Skill |
| --- | --- |
| Run a program, get a one-off tool, find a package | `nix-run-shell` |
| A Nix command or build fails | `nix-build-debug` |
| Write or bump a package, overlay or hash | `nix-package` |
| Update or inspect flake inputs | `nix-flake-ops` |
| Rebuild, diff, switch or roll back the system | `nix-darwin-switch` |
| Sizes, closures, GC roots, "why is this in my closure" | `nix-store-inspect` |
| Why a file, binary or port exists | `why` |

## Her machines

- `mirai`: MacBook, `aarch64-darwin`, nix-darwin and home-manager.
- `ikigai`: PC, `x86_64-linux`, NixOS and home-manager.
- Config repo: `~/nixfiles`. Hosts are in `hosts/<name>/{default,home}.nix`, shared parts in `hosts/common.nix`, program configs in `config/`, overlays in `overlays/`, own packages in `pkgs/`.
- Separate nixpkgs inputs (`nixpkgs-asahi`, `nixpkgs-hydrus`) are pinned on purpose. Update them only when she asks.

## `nh`

`nh` (Yet Another Nix Helper) is installed. It wraps the system commands, shows a closure diff, and uses `nix-output-monitor`. Prefer it for system work. The skills above say where it applies: `nh darwin build|switch`, `nh os build|switch`, `nh clean`, and `nh search`. `nh <command> --help` lists the flags.

## New project flake

Match her existing flakes (`~/devel/tiny-lm/flake.nix` is the model):

- `inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";`
- `systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];` and a `forAllSystems` helper built on `nixpkgs.lib.genAttrs`.
- `devShells.default = pkgs.mkShell { packages = [ ... ]; };`
- A `.envrc` containing `use flake`.
- Add a `packages.default` only if the project is a program someone runs. `~/devel/why/flake.nix` is the model (see `nix-package`).
- For editors, link the environment to a fixed path in `shellHook`, as `tiny-lm` does with `.python-env`, because store paths change on every update.
- Put the reason in a comment when a choice is not obvious. Her flakes explain *why* (for example, why MLX comes from Apple's wheels), not what the line does.
- Prefer few dependencies. Keep std-only or near std-only where that is reasonable, because it keeps the flake build simple.

## Two things to remember

- **Untracked files are invisible to a flake inside a git repo.** After you create a file, run `git add -N <file>` before you build.
- **The Nix sandbox has no Metal compiler**, so nixpkgs MLX is CPU-only. Check this before promising GPU support in a Nix build on macOS.

## Ask first

These change the system or delete data, so get a clear yes from Lilly before you run them:

- `darwin-rebuild switch`, `nixos-rebuild switch`, `nh darwin switch`, `nh os switch`, `./result/activate`, `sudo` anything.
- `nix-collect-garbage`, `nh clean`, and `nix profile remove`. Deleted generations do not come back, and old ones are rollback points.
- `nix profile install`, and edits to `~/nixfiles`. Propose the change and let her choose.
- `nix flake update` for all inputs. Update one input at a time, and say which.

Building, evaluating, `nix develop`, `nix run` and `nix shell` are safe to run freely.
