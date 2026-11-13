---
name: nix-package
description: Write or edit a Nix package (derivation). Use when packaging a program, adding a package to ~/nixfiles/pkgs or to Lilly's NUR repo (~/devel/nur-packages), writing buildRustPackage, buildPythonApplication, buildGoModule, buildNpmPackage or stdenv.mkDerivation, using fetchFromGitHub or fetchPypi, getting a hash, writing an overlay, or bumping a package version.
links: nix-build-debug, nix-flake-ops, nur-release
requires-bin: nix
---

# Packaging with Nix

Read `nix-dev` first, and use `nix-build-debug` when a build fails. Building is safe to run freely.

## Where the package goes

| Package is | Put it in |
| --- | --- |
| Useful to others, or a program of hers | `~/devel/nur-packages/pkgs/<name>/default.nix`, listed in that repo's `default.nix`. Then the system config gets it from the `lillycham-nur` input. Recent commits show this move (hydrus-tagger). For the whole flow from GitHub to the switch, use `nur-release`. |
| Glue or a patch used only by her machines | `~/nixfiles/pkgs/<name>.nix`, added in `~/nixfiles/overlays/default.nix` as `<name> = final.callPackage ../pkgs/<name>.nix { };` |
| The project's own program | `packages.default` in that project's flake (see `nix-dev`) |

If unsure, ask which one. Do not add a package to the system config (`hosts/`) yourself: propose it and let her choose.

## Shape

Match the files already there. Her style:

- Arguments as a function set, one per line when long; `callPackage` fills them.
- `meta` with `description`, `homepage`, `license`, and `mainProgram`.
- A comment that says **why** for anything odd (a removed dependency, a disabled test), not what the line does.
- Few dependencies. Prefer what nixpkgs already has.

Builders:

| Language | Builder | Key attributes |
| --- | --- | --- |
| Rust | `rustPlatform.buildRustPackage` | `cargoLock.lockFile = ./Cargo.lock;` (run `cargo generate-lockfile`, then `git add -N Cargo.lock`). Git dependencies need `cargoLock.outputHashes`. |
| Python app | `python3Packages.buildPythonApplication` | `pyproject = true;` and `build-system`, or `format = "wheel"` with `fetchPypi`. `dependencies`, `pythonImportsCheck`. |
| Go | `buildGoModule` | `vendorHash`; set `lib.fakeHash` first. |
| Node | `buildNpmPackage` | `npmDepsHash`. |
| Other | `stdenv.mkDerivation` | `installPhase` into `$out/bin`; `makeWrapper` for runtime PATH. |

## Hashes

```bash
# 1. Put lib.fakeHash (or hash = "";) in the expression
# 2. Build; copy the "got:" hash from the error into the file
nix build .#<name>                     # in a flake
nix-build -A <name>                    # in nur-packages

# For a URL or file you want to hash yourself
nix store prefetch-file --hash-type sha256 <url>
# For a GitHub source at a tag
nix run nixpkgs#nix-prefetch-github -- <owner> <repo> --rev <tag>
```

Use `hash = "sha256-..."` (SRI form), not the old `sha256 =`. Pin to a tag or a full commit, not a branch. A moved tag changes the hash: say so if the build shows a mismatch for a source that did not change.

## Overlays

```nix
final: prev: {
  foo = final.callPackage ../pkgs/foo.nix { };                    # add a package
  bar = prev.bar.overrideAttrs (old: { doCheck = false; });       # change one; comment why
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: { baz = pyprev.baz.overridePythonAttrs (_: { doCheck = false; }); })
  ];
}
```

Use `final` for dependencies and `prev` for the thing being changed. Using `final.x` for the package you define causes infinite recursion.

## Check before saying it works

```bash
nix build .#<name> --no-link --print-out-paths   # builds, prints the path
<out>/bin/<name> --version                       # run it
nix build .#<name> --rebuild                     # optional: is the build reproducible?
```

On macOS the build sandbox has no Xcode or Metal compiler (see `nix-dev`). If the package is Linux-only, set `meta.platforms` and say so. Test on the platform she uses (`mirai` is `aarch64-darwin`).

## Bumping a version

1. Change `version` (and `rev` or `tag` if it is set separately).
2. Set the source `hash` to `lib.fakeHash`, and the `cargoHash` / `vendorHash` / `npmDepsHash` too.
3. Build, copy each real hash, build again.
4. Read the upstream changelog for new dependencies and changed build steps.

## Do not

- Do not copy a derivation from memory and say it builds. Build it.
- Do not push to `nur-packages` or edit `~/nixfiles` without being asked. After a change to `nur-packages`, `nix flake update lillycham-nur` in `~/nixfiles` is a separate step (see `nix-flake-ops`).
- Do not leave `lib.fakeHash` in a file you hand back.
