# `nixpkgs-sync`: lock the nixpkgs input of my Haskell flakes to the nixpkgs
# rev of this system, so that they share one GHC, HLS and package set in the
# store. Only flake.lock changes: the input URL in flake.nix stays as it is,
# so the projects build the same for anyone else.
#
#   nixpkgs-sync              every Haskell flake in ~/devel (main checkouts)
#   nixpkgs-sync DIR...       only these
#   nixpkgs-sync -n ...       show what would change, change nothing
#
# Linked worktrees are skipped unless named, because their branch has its
# own work. A flake whose flake.lock has uncommitted changes is skipped.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "nixpkgs-sync";
      runtimeInputs = [ pkgs.jq pkgs.git ];
      text = ''
        dry=0
        if [ "''${1:-}" = "-n" ]; then dry=1; shift; fi

        nixfiles="''${NIXFILES:-$HOME/nixfiles}"
        # Resolve the node of the root `nixpkgs` input: it may be `nixpkgs_2`.
        rev=$(jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev' "$nixfiles/flake.lock")
        echo "target: nixpkgs $rev (from $nixfiles)"

        if [ $# -eq 0 ]; then
          for d in "$HOME"/devel/*/; do
            d=''${d%/}
            [ -f "$d/flake.lock" ] || continue
            cabal=("$d"/*.cabal)
            [ -f "''${cabal[0]}" ] || [ -f "$d/package.yaml" ] || continue
            [ -f "$d/.git" ] && continue  # a linked worktree
            set -- "$@" "$d"
          done
        fi

        for d in "$@"; do
          name=$(basename "$d")
          node=$(jq -r '.nodes.root.inputs.nixpkgs // empty | strings' "$d/flake.lock")
          if [ -z "$node" ]; then
            echo "skip  $name: no root nixpkgs input"; continue
          fi
          cur=$(jq -r --arg n "$node" '.nodes[$n].locked.rev' "$d/flake.lock")
          if [ "$cur" = "$rev" ]; then
            echo "ok    $name"; continue
          fi
          if git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
             && ! git -C "$d" diff --quiet HEAD -- flake.lock 2>/dev/null; then
            echo "skip  $name: flake.lock has uncommitted changes"; continue
          fi
          echo "bump  $name: ''${cur:0:10} -> ''${rev:0:10}"
          if [ $dry -eq 0 ]; then
            (cd "$d" && nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$rev" 2>&1 \
              | grep -v '^warning: Git tree' || true)
          fi
        done
      '';
    })
  ];
}
