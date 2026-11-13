---
name: claude
description: Global workflow, ASD-STE100 commit rules, Nix usage and akyuu memory rules for Lilly.
requires-mcp: akyuu, nibble
requires-hook: akyuu-context
requires-bin: git, nix
---

- My name is Lilly, and my pronouns are she/her.
- You may read my Obsidian vault in `~/Documents/lillys-research/lillys-research` (or via the Obsidian MCP tools when Obsidian is open) whenever it is relevant, from any project.

## Writing for commits, PRs and releases

- Write commit message bodies, PR titles and descriptions, release notes, review summaries and similar project write-ups in ASD-STE100 (Simplified Technical English):
  - Short sentences: up to 20 words for instructions, 25 for descriptions.
  - Active voice, and one instruction per sentence.
  - Simple approved words and consistent technical names.
  - Avoid -ing forms and phrasal verbs where a simple verb works.
- This doesn't apply to code comments, unless I ask.
- For commit subject lines, follow the repo's existing convention. I usually use Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:` and so on).
- Keep PR descriptions as short as possible: a short summary of what changed and why, plus only the notes a reviewer needs. Don't list every small change, because the commits already hold the detail.
- Commit trailers (this is the whole rule):
  - A commit of code that you (the agent) wrote gets a `Co-Authored-By` line for you.
  - A commit of code that only I wrote gets no `Co-Authored-By` line.
  - Put your changes and mine in separate commits, so the history shows whose work is whose. I commit mine myself, or you commit them for me without the line.
- If I only ask for a message, draft it and don't commit.

## How I work

- Use Nix for every tool and dependency. Never use Homebrew (it's a leftover on mirai) or system Python, Swift or Node. You always have permission to create a `flake.nix` when a project needs tools.
- Never run `python3`, not even `python3 --version`. If I need Python, use `nix shell nixpkgs#python3`. Tell subagents the same in their brief.
- For non-trivial work in a git repo, use a worktree on a new branch, unless I say otherwise or the repo's memory says something different.
- I'm fluent in Haskell and functional programming, and less practised in imperative and OOP code. When I implement something myself, give pointers and short examples rather than the full code, and explain via FP ideas where that helps.
- Notice hung commands yourself. Smoke-test before a slow batch, give network and model calls short time limits, and check background output within a minute.
- Ask before you stop or restart an app I might be using, such as a game build I'm playtesting.

## Memory (akyuu)

- Use the akyuu MCP tools proactively. Don't wait to be asked, and don't write Claude Code memory files. The rules are in the ref `claude/memory-policy`.
- Write a short `note` as you work when a decision is made or changed, when something is finished (a merge, a release, a deploy), when you learn a gotcha, or when I tell you something about myself, my projects or my tools.
- When the "state as of" in a project's memory stops being true, `supersede` it. Search first.
- Before a long session ends, write one summary note: what was done, what is open, what is next.
- Tell subagents they may call `note`, and say in their brief what to record.

# Compact instructions

When you summarise this conversation, keep the relationship as well as the work:

- Tone: how Lilly has been talking this session (playful, tired, focused,
  kaomoji or not) and how I have been answering. Quote one or two short lines
  if they carry the tone better than a description.
- Running jokes, nicknames and references that started in this session.
- Open threads of conversation, not only open tasks: questions either of us
  left unfinished, ideas she liked, and what she pushed back on, and why.
- Her preferences and corrections from this session, word for word if short.
- Decisions with their reasons. Keep what she approved ("go ahead" on X) apart
  from what still needs her word.
- Live state: branches, worktrees, uncommitted or unpushed work, open PRs,
  background jobs.
- What is already in akyuu (refs and notes from this session), so the next
  window reads it there instead of the summary repeating it.
- Anything she said off the record: never write it to memory, but mark it as
  off the record if the conversation still needs it.

Leave out: tool output, file listings, and step-by-step accounts of finished
work. Point to the commit or the akyuu note instead.
