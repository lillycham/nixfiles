---
name: nur-release
description: Publish one of Lilly's own programs through her NUR repo (~/devel/nur-packages) and use it from ~/nixfiles. Use when she says "add X to my NUR repo", "publish it to github and NUR", "switch the input to NUR", "bump X in NUR" or "release a new version of X". Past cases are nibble, dq and hydrus-tagger.
links: nix-darwin-switch, nix-package
requires-bin: gh, git, nix
---

# Releasing a program through NUR

This flow spans three repos: the project, `~/devel/nur-packages` and `~/nixfiles`. Read `nix-package` for how to write the derivation, and `nix-darwin-switch` for the switch. Each push needs her go-ahead, unless she has already asked for it in this request.

## First release

1. **Project repo.** Check that it is on GitHub as `github.com/lillycham/<name>` and is public. If it is not, ask before you create it (`gh repo create`).
   - It needs a licence. Check the dependency licences first, for example with `cargo deny check licenses` for Rust.
   - The copyright holder is Lilly Cham. "Lemniscate Labs" is used only for BoxBreathe. Ask if unsure.
2. **Package.** Write `~/devel/nur-packages/pkgs/<name>/default.nix`, pinned to a commit `rev` that is already pushed. Add it to the repo's top-level `default.nix`.
   - Get `hash` and `cargoHash`, `vendorHash` or `npmDepsHash` with `lib.fakeHash`, build, copy, and build again.
3. **Build** in nur-packages: `nix-build -A <name>`, then run the binary once (`--version` or `--help`).
4. **Commit and push** nur-packages with `feat: add <name>`.
5. **nixfiles.** Run `nix flake update lillycham-nur` and commit the lock on its own (`chore: update lillycham-nur`).
   - Then point the config at the NUR package, and remove the old local `pkgs/` entry or the direct flake input if this replaces one. Commit that as `refactor: get <name> from my NUR repository`.
6. **Build and switch** with `nix-darwin-switch`: build, report the diff, and give her the switch command.

## Later releases

Push the project first. In `pkgs/<name>/default.nix`, bump `version` and `rev`, then reset the hashes and get them again (step 2). Build, commit (`feat: update <name> to <version>`), push, and do step 5.

Some programs are a flake input in nixfiles (for example `nibble`, which follows its `dev` branch) and are not used from NUR there. For those, `nix flake update <input>` is the step in nixfiles. Check `flake.nix` before you choose.

## Do not

- Do not pin a `rev` that is not on GitHub. The build cannot fetch it.
- Do not run `nix flake update` with no input name.
