---
name: nix-run-shell
description: Run programs and get tools through Nix without installing them. Use when a command is missing, the user wants to run or try a package, needs a one-off toolchain, asks "nix run vs nix shell vs nix develop", wants to find which package provides a command, or wants to pin a nixpkgs version for a single command.
---

# nix run, nix shell, nix develop

Read `nix-dev` first: toolchains come from Nix, not from system tools or Homebrew. `nix` here is Lix, with flakes enabled. All of these are safe to run freely.

## Pick the command

| Need | Use |
| --- | --- |
| Run one program once | `nix run nixpkgs#<pkg> -- <args>` |
| Several tools on PATH for one command | `nix shell nixpkgs#a nixpkgs#b -c <cmd>` |
| The project's own environment | `nix develop -c <cmd>` (reads `devShells.default`) |
| Run what the project's flake builds | `nix run .` or `nix run .#<name>` |
| Build only, keep `./result` | `nix build .#<name>` |
| A different shell in a project | `nix develop .#<name> -c <cmd>` |

Use `-c` for non-interactive work. Without it, `nix develop` and `nix shell` start an interactive shell that will hang a tool call.

`nix run nixpkgs#foo` runs the package's `meta.mainProgram`. If the binary has another name: `nix shell nixpkgs#foo -c <binary>`.

## Finding a package

```bash
nh search <term>                              # search.nixos.org: version, description, main program, source link
nh search -l 5 <term>                         # limit the results; the best match is at the end
nix search nixpkgs <term>                     # by name or description, from the local flake input
nix eval --raw nixpkgs#<pkg>.version          # check it exists, and its version
nix eval --raw nixpkgs#<pkg>.meta.mainProgram
nix build nixpkgs#<pkg> --no-link --print-out-paths   # then ls <path>/bin
```

`nh search` queries the web (nixos-unstable by default, `-c <channel>` changes it) and needs the network. `nix search nixpkgs` matches the exact nixpkgs revision her flake uses, so use that when the version matters.

For "which package has this command": search for the likely name, then check `ls <out>/bin`. Do not guess attribute names.

## Common patterns

```bash
nix shell nixpkgs#cargo nixpkgs#rustc -c cargo build     # one-off toolchain
nix shell nixpkgs#python3 -c python3 script.py
nix run nixpkgs#jq -- '.a' file.json
nix run github:owner/repo -- <args>                       # a flake from GitHub
nix develop -c cargo test                                 # in a project with a flake
```

Pin a version for one command: `nix run github:NixOS/nixpkgs/<rev>#<pkg>` or `nixpkgs/nixos-24.11#<pkg>`. Say why the pin is needed.

For a project with no flake, ask whether to add one (see `nix-dev` for her flake shape). For a quick check, use `nix shell`.

## Gotchas

- In a git repo, a flake sees only tracked files. Run `git add -N <file>` for new files.
- `nix run .#foo` builds first. A build error is a build error: see `nix-build-debug`.
- The first run downloads. A slow first run is not a hang. Do not kill it.
- Programs that need the network, a GUI or the user's terminal may not work from a tool call. Say so before running them.
- On macOS, `nix run` of a GUI `.app` does not launch it. Build it and open the `.app` in `./result/Applications`.
- Do not use `nix profile install` or `nix-env -i` to get a tool for a task. That changes the user profile (ask first, see `nix-dev`).
