---
name: nix-store-inspect
description: Inspect the Nix store, closures and garbage-collection roots. Use when asked how big something is, why a package is in a closure, what keeps a store path alive, what can be garbage collected, how much space Nix uses, or what changed between two system generations. For "why is this file or port here" use the `why` skill first.
links: why
requires-bin: nh, nix
---

# Inspecting the store

All commands here only read. Deleting is a separate step and needs a clear yes (see `nix-dev`). For "why is this file, binary or port here", use the `why` skill; this skill is for sizes, closures and roots.

## Commands

```bash
nix path-info -Sh <path>                      # size of the path plus its closure
nix path-info -rSh <path> | sort -k2 -h       # every path in the closure, by size
nix why-depends <a> <b>                       # why a depends on b (add --all for every path)
nix store diff-closures <old> <new>           # what changed between two closures
nix-store --query --roots <path>              # what keeps a path from being collected
nix-store --query --referrers <path>          # what directly refers to it
nix derivation show <installable>             # inputs and build steps of a derivation
```

Common arguments: `/run/current-system`, `~/.nix-profile`, `./result`, `nixpkgs#<pkg>`, `/nix/var/nix/profiles/system-<n>-link`.

`nix-store --query --roots` may print `removing stale link ...` and delete a dead auto-root link. That is harmless housekeeping, but tell her if you see it.

## Answering common questions

- **"Why is X on my system?"** `nix why-depends /run/current-system <X's path>`. Report the shortest chain, then say which of her config entries causes it.
- **"What is big?"** Closure sizes sorted, top 10. Name what in `~/nixfiles` pulls each one in.
- **"What changed in the last switch?"** `nix store diff-closures /nix/var/nix/profiles/system-<n-1>-link /nix/var/nix/profiles/system-<n>-link`. List generations with `ls -l /nix/var/nix/profiles/ | grep system-`.
- **"How much space can I get back?"** Run `nix-collect-garbage --dry-run` (shows what would go, deletes nothing). `nh clean user --dry` shows which user profile generations it would delete and does not need sudo. `nh clean all --dry` covers system profiles too and does need sudo. Report the size. Say that old system generations are rollback points, and that the garbage collector cannot bring them back.
- **"Why won't this path be collected?"** `nix-store --query --roots`. GC roots are mostly old system generations, `result` links in project dirs, and home-manager generations. Say which ones matter.

## Rules

- `nix-collect-garbage`, `nix-collect-garbage -d`, `nh clean ...`, `nix store gc`, `nix profile wipe-history` and `nix-store --delete` delete data. Without `--dry`, `nh clean` deletes at once, and `nh clean all` keeps only the newest generation unless `--keep` or `--keep-since` is set. Ask first, say what goes, and recommend a bounded form: `nix-collect-garbage --delete-older-than 30d` is safer than `-d`, which removes every old generation including rollback points.
- Do not delete `result` symlinks in her projects unless she asks. They are roots on purpose.
- A closure size includes shared paths. Do not add up sizes of two packages and call it the total.
