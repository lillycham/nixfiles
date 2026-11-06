# `akyuu-dev-switch`: switch to this system with akyuu built from the local
# checkout (~/devel/akyuu, or $AKYUU_SRC), with no push and no lock update.
# The build takes the tracked files of the checkout, with uncommitted edits,
# but not new untracked files.
#
# A plain switch restores the NUR package. After publication, update
# lillycham-nur for the CLI and akyuu for its module, helpers and fonts.
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
        echo "The lock is not changed: a normal switch restores the NUR package."
        exec nh darwin switch "$HOME/nixfiles" -H "$(hostname -s)-akyuu-dev" --ask "$@" -- --no-write-lock-file --override-input akyuu "git+file://$src"
      '';
    })
  ];
}
