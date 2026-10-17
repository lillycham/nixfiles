# `akyuu-dev-switch`: switch to this system with akyuu built from the local
# checkout (~/devel/akyuu, or $AKYUU_SRC), with no push and no lock update.
# The build takes the tracked files of the checkout, with uncommitted edits,
# but not new untracked files.
#
# The lock still names the old akyuu, so a plain switch later goes back to it.
# After a push, run `nix flake update akyuu` in ~/nixfiles as usual.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "akyuu-dev-switch";
      text = ''
        src="''${AKYUU_SRC:-$HOME/devel/akyuu}"
        if ! git -C "$src" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          echo "akyuu-dev-switch: $src is not a git checkout" >&2
          exit 1
        fi
        echo "akyuu from $src ($(git -C "$src" rev-parse --short HEAD)$(git -C "$src" diff --quiet || echo ', with uncommitted edits'))"
        echo "The lock is not changed: after a push, run nix flake update akyuu."
        exec nh darwin switch "$HOME/nixfiles" -H "$(hostname -s)" --ask "$@" -- --override-input akyuu "git+file://$src"
      '';
    })
  ];
}
