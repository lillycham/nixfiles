---
name: finish-branch
description: Merge a finished branch or PR and clean up after it. Use when Lilly says "merge once CI passes", "merge it", "clean up", "cleanup as usual", "tidy up the old branches/worktrees", or "merge it locally / no PR". Works for any of her git repos (BoxBreathe, dq, nibble, scm-rs, nixfiles and others).
---

# Finishing a branch

Most of her work happens on a worktree branch. This is how it ends. Merge only when she has asked for a merge.

## First

1. Run `git status` in the worktree. If there are uncommitted changes (for example "commit that stuff, then finish branch"), commit them first. Keep Claude's changes in separate commits from hers, and add no Co-Authored-By line to her code.
2. Find the target branch. If the repo has an integration branch (`dev` in akyuu and nibble: check `git branch -a`), merge into that. Merge into `main` only when she says so ("merge into main").

## With a PR

1. Watch CI with `gh pr checks <pr> --watch`. If a check fails, stop, show the failure and do not merge.
2. When CI passes, merge with the repo's usual method. Check recent merged PRs if unsure: `gh pr list --state merged -L 3`. Do not use `--admin` to skip a check.
3. Clean up (below).

## Without a PR ("merge it locally", "no PR")

1. In the main checkout, switch to the target branch (`main`, or `dev` as above) and run `git merge --ff-only <branch>`. If it cannot fast-forward, ask whether to rebase the branch or make a merge commit.
2. Push only if she asks.
3. Clean up (below).

## Clean up

1. In the main checkout, run `git switch main` and then `git pull --ff-only`. If she has "already pushed", only pull.
2. Remove the worktree: `git worktree remove <path>`. If it has uncommitted changes, stop and show them. Do not use `--force`.
3. Delete the local branch with `git branch -d <branch>`, not `-D`. If `-d` refuses, the branch is not merged: ask.
4. Delete the remote branch only when both are true:
   - `git branch -r --merged origin/main` lists it.
   - Its PR is merged.
   Then run `git push origin --delete <branch>`. The merged PR keeps the commits and has a "Restore branch" button.
5. Run `git worktree prune` and `git fetch --prune`.
6. Say in one line what was merged and what was removed.

"Tidy up all the old branches" means the same steps for each branch that is merged. Show the list first, and list any branch that is not merged without deleting it.

## Do not

- Do not delete an unmerged branch, local or remote, without a clear yes.
- Do not force-push `main`.
- Some repos keep their own notes about this (for example BoxBreathe's project memory). Those come first.
