---
name: nix-flake-ops
description: Work with Nix flake inputs and the flake itself. Use when updating flake.lock or one input, running nix flake check/show/metadata, pinning or overriding an input, adding an input, using follows, handling "lock file out of date", or working on the inputs of ~/nixfiles (nixpkgs, home-manager, darwin, nur, lillycham-nur, akyuu, nibble).
requires-bin: nix
---

# Flake operations

Read `nix-dev` first. Reading and checking are safe to run freely. Changing `flake.lock` is a change to her config: say which input and why before you do it.

## Look first

```bash
nix flake metadata                 # inputs, locked revisions, last-modified dates
nix flake metadata --json | jq '.locks.nodes.root.inputs'
nix flake show                     # what the flake provides, per system
nix flake check --show-trace       # evaluates every output; run before and after a change
git diff flake.lock                # what an update changed
```

Last-modified dates show how stale each input is.

## Updating

**One input at a time. Never run `nix flake update` with no name.**

```bash
nix flake update nixpkgs                  # one input
nix flake update lillycham-nur            # after a change in ~/devel/nur-packages
nh darwin build ~/nixfiles -H mirai -U nixpkgs   # update one input, then build and diff; `-u` updates all, so do not use it
nix flake lock --override-input foo path:../foo   # try a local checkout; does not need a commit
```

In `~/nixfiles`:

- Pinned inputs (`nixpkgs-hydrus`, `nixos-apple-silicon`) and her own project inputs (`lillycham-nur`, `akyuu`, `nibble`) are updated on purpose, only when she asks.
- `home-manager`, `darwin`, `lillycham-nur`, `akyuu` and `nibble` follow `nixpkgs`. Update `nixpkgs` and check the others still evaluate.
- After any update, build before you switch (see `nix-darwin-switch`), and look at the closure diff.
- Commit `flake.lock` alone, with a Conventional Commits subject (`chore: update nixpkgs`). The commit body follows her ASD-STE100 rule. Only commit if she asks.

If an update breaks a build, go back with `git checkout flake.lock` (this discards the update: confirm first if she has other lock changes), then update a different input or pin `nixpkgs` to an earlier revision.

## Inputs

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  foo = {
    url = "github:owner/foo";
    inputs.nixpkgs.follows = "nixpkgs";      # one nixpkgs; fewer rebuilds and downloads
  };
};
```

- Use `follows` for nixpkgs unless the input needs its own (say why in a comment).
- Pin to a rev with `github:owner/repo/<rev>` or a branch with `?ref=<branch>`. Say why in a comment.
- A comment above an input says why it is there. Her flake does this, and it should stay that way.
- `nix flake metadata` shows duplicate nixpkgs. Fix them with `follows`.

## Common errors

| Error | Fix |
| --- | --- |
| `lock file ... is out of date` or `not locked` | `nix flake lock`, which adds missing inputs without updating the rest. |
| `does not provide attribute` | Wrong system or name. `nix flake show` and check `<system>`. |
| A new file is not seen | `git add -N <file>`. A flake in git sees tracked files only. |
| `error: unable to download ... 403` or rate limit | GitHub's API limit. Wait, or use an access token set by Lilly. Do not put a token in a command. |
| Local edits in an input are ignored | Use `--override-input name path:/abs/dir`. |
| `Git tree is dirty` warning | Harmless for builds. It means uncommitted changes are in the build. |

## Do not

- Do not edit `flake.lock` by hand.
- Do not remove an input without checking what uses it: `grep -rn <input> .` first.
- Do not run an update, a `--recreate-lock-file`, or `--commit-lock-file` and say "done" without a build that passes.
