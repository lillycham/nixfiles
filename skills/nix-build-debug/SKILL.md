---
name: nix-build-debug
description: Diagnose a failing `nix build`, `nix eval`, `nix develop`, flake check or derivation. Use when a Nix command errors, a build fails, a hash mismatches, an attribute is missing, a flake file "does not exist", infinite recursion appears, or the user pastes a Nix error and asks what is wrong.
---

# Debugging Nix failures

Read `nix-dev` first for Lilly's conventions. This skill is the diagnosis order. All commands here are safe to run.

## 1. Read the error from the bottom

The last `error:` line is the cause. Lines above it are the call chain. Do not guess from the top.

```bash
nix build .#foo --show-trace 2>&1 | tail -40   # eval errors: full trace
nix log .#foo                                  # build errors: the builder's output
nix log /nix/store/<hash>-foo.drv              # same, from a drv path in the error
```

Lix prints a build log tail on failure. If it is cut off, `nix log` has all of it.

## 2. Match the symptom

| Symptom | Cause and fix |
| --- | --- |
| `path '.../x' does not exist` or a file is "not found" inside a flake | The flake is in a git repo and the file is untracked. Run `git add -N <file>`. Outside git, use `path:/abs/dir`. |
| `hash mismatch in fixed-output derivation` | Take the `got:` hash and put it in `hash =`. For a new source, set `lib.fakeHash` first. Check that the URL or tag is the one meant: a moved tag changes the hash. |
| `attribute 'x' missing` | Do not guess names. `nix search nixpkgs x`, or `nix eval nixpkgs#x.version`. Check `devShells.<system>` has the current system. |
| `infinite recursion encountered` | An overlay or module refers to the thing it defines. Use `--show-trace` and look for `final` where `prev` is needed. |
| `cannot coerce ... to a string` | A set or null is used as a path or string. Print it: `nix repl --file . ` then `:p x`. |
| `unfree` or `broken` or `insecure` package | Set the matching `config.allow*` or `permittedInsecurePackages` on purpose, and say why. Do not set `allowUnfree` globally without asking. |
| `error: builder ... failed` with no network messages | Look for network use. The sandbox has none: a fetch inside a build must be a fixed-output derivation. |
| Compiler or Metal tool missing on macOS | The sandbox has no Xcode or Metal compiler. nixpkgs MLX is CPU-only. Do not promise GPU builds. |
| `Cargo.lock` / `cargoLock` errors | Run `cargo generate-lockfile` and `git add -N Cargo.lock`. A git dependency needs `outputHashes`. |
| A fetch from `elpa.gnu.org` fails with `curl: (35) TLS connect error ... wrong version number` | ELPA blocks Lilly's VPN. Ask her to retry with the VPN off. Do not debug the derivation. She prefers MELPA or nixpkgs packages to ELPA ones. |
| `lock file ... is out of date` | Run `nix flake lock`. Update one input only: `nix flake update <input>`. |
| Many packages rebuild | An input changed, an overlay touched a core package, or a cache missed. See the "why rebuild" step below. |

## 3. Narrow it down

```bash
nix flake show                                  # what the flake provides
nix flake check --show-trace                    # evals every output
nix eval .#packages.$(nix eval --impure --raw --expr builtins.currentSystem) --apply builtins.attrNames
nix build .#foo --keep-failed                   # keep the failed build dir; the error names it
nix develop .#foo -c bash                       # get the build env, then run phases by hand
nix repl --file . / nix repl .                  # then :l <nixpkgs>, :p, :t
```

To step through a package: `nix develop nixpkgs#foo`, then `unpackPhase; cd $sourceRoot; patchPhase; configurePhase; buildPhase`. This finds a failing phase quickly.

## 4. Why did it rebuild, or what changed

```bash
nix build .#x --dry-run                         # lists what builds and what is fetched
nix store diff-closures /nix/store/<old> /nix/store/<new>
nix why-depends .#a .#b
```

## Rules

- Do not "fix" an error by turning off the sandbox, `--impure`, or `--option` flags unless the cause needs it. Say what the flag does.
- Do not delete store paths or run garbage collection to fix a build. That is not a fix and it needs Lilly's yes (see `nix-dev`).
- State the cause, then the fix. If you cannot reproduce the failure, say so.
