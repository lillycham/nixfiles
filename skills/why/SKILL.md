---
name: why
description: Explain why a file, command or listening port exists on this machine, using Lilly's `why` CLI. Use when asked "why is this here", "what is using port N", "where did this file come from", "why is this in the Nix store", "who added this and why", or when debugging EADDRINUSE or a mystery process, symlink, binary or config file.
requires-bin: why
---

# why

`why` is a small Rust CLI (source: `/Users/lcham/devel/why`) that traces a target back to its cause and prints the chain as bullet points. Use it before guessing, or before piecing the answer together from `git blame`, `lsof`, `ps` and `nix-store` by hand.

## Run it

Use `nix run`. It needs no install and always builds the current source:

```bash
nix run path:/Users/lcham/devel/why -- <target>
```

The first run builds the crate and takes a few seconds. Later runs use the cache. If the path does not exist, tell the user. Do not rewrite the tool from memory.

## Targets

| Target | Example | What it reports |
| --- | --- | --- |
| Path | `why ./flake.lock` | Symlink chain. Nix package, derivation and GC roots for store paths. Git: the commit that added it, the latest change, or the ignore rule. |
| Command on PATH | `why node` | The same, for the resolved binary. |
| Port | `why :8080` | The listening process, its parent chain, its working directory, and that directory's repo, branch and latest commit. |

Exit codes: 0 found, 1 nothing listening on that port, 2 bad input.

## How to use the output

- Quote the relevant bullets. Do not paraphrase the commit messages.
- The output shows facts, not opinions. Add your own reading as a separate step.
- GC root lists are often long and mostly old system generations. Say which roots matter.
- Only TCP listeners are supported. For UDP or a specific address, fall back to `lsof`.
- Killing a process or deleting a file is a separate action. Ask the user first.

## Limits

No dependency lookup yet (`Cargo.lock`, `flake.lock`, `package.json`). Do that by hand and mention that `why` does not cover it.
