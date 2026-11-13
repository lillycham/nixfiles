---
name: subagent-branch-task
description: Hand a defined piece of work to an Opus subagent on its own branch, then review it and merge it. Use when Lilly says "spin up an opus subagent to do X", "get the subagent to do those outstanding things, then review its work", or "set a subagent onto X, commit as it needs to, then merge into dev". Not for work she wants to write herself (see learn-by-building).
---

# Subagent branch task

1. **Agree the scope.** Take it from `TODO.md` or the chat, with a short acceptance list. Ask only if the scope is unclear.
2. **Start the subagent** with the Agent tool and `model: opus`. Give it its own worktree branch off the integration branch (`dev` in akyuu and nibble: check `git branch -a`). Tell it to commit in small steps and run the tests.
3. **Review.** When it finishes, read its diff and run the tests yourself. Report problems and fix or re-delegate them before you merge. She asks for this review each time.
4. **Merge** into the integration branch with `git merge --ff-only` (the `finish-branch` skill has the clean-up). Do not touch `main` until she says "merge into main".
5. **Report** in a few lines: what changed, what the tests show, what is left.

Her own code is not the subagent's to change. Keep it away from files she is writing.
