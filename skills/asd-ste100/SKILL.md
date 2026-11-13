---
name: asd-ste100
description: Write or rewrite text in ASD-STE100 Simplified Technical English. Use when writing or checking commit message bodies, PR titles and descriptions, release notes, changelogs, review summaries or similar project write-ups for Lilly, or when she asks to simplify, shorten or "STE-ify" a text. Not for code comments (unless asked), chat replies, or text in her own voice.
---

# ASD-STE100 for project write-ups

Lilly writes commits, PRs, release notes and review summaries in Simplified Technical English. This skill is the working rules and a way to check them. It does not make the text longer: STE text is shorter.

## Where it applies

| Text | STE? |
| --- | --- |
| Commit message **body**, PR title and description, release notes, review summaries | Yes |
| Commit **subject line** | Follow the repo's convention (usually Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`). Keep the words simple. |
| Code comments | No, unless she asks. If she asks for doc comments in STE, apply the rules to the comment text only and keep the usual markup (for example Haddock) |
| Chat replies or text in her own voice | No |

## The rules that matter most

1. **Sentence length.** Up to 20 words for an instruction, up to 25 for a description. Cut longer ones in two.
2. **One idea per sentence.** One instruction per sentence.
3. **Active voice.** "The parser reads the file." Not "The file is read by the parser."
4. **Simple tenses.** Use the simple present, past or future. Avoid the perfect and progressive ("has been changing").
5. **Approved words, one meaning each.** Use the plain word: `use`, not `utilize`; `start`, not `initiate`; `show`, not `display` or `illustrate`; `make sure`, not `ensure`; `help`, not `facilitate`; `about`, not `approximately`; `remove`, not `eliminate`.
6. **Avoid -ing forms and phrasal verbs** where a simple verb works. "Fix a crash that occurs on start", not "Fix crash occurring when starting up". "Remove", not "take out". "Start", not "kick off".
7. **Name things the same way every time.** Do not change a term for variety. If it is `flake.lock` once, it is `flake.lock` always, not "the lockfile".
8. **Technical names are allowed.** Command names, flags, file names, functions and project terms stay as they are, in backticks. Do not "simplify" them.
9. **Short noun groups.** Three nouns or fewer. "Build cache key" is fine. "Flake input lock update step" is not: write "the step that updates the lock file".
10. **Say what happens, and why.** Give the reason in one short sentence. Do not add filler ("Basically", "In order to", "It should be noted that").
11. **Use articles** (a, an, the). Do not drop them to save space.
12. **No jokes, idioms or figures of speech.** "Out of the box", "under the hood", "low-hanging fruit" are out.

## Commit body

- Say what changed and why. The diff shows how.
- A short paragraph, or a few short lines. No list of every changed file.
- Keep the trailer lines the harness asks for (such as `Co-Authored-By:`) exactly as given.

```text
fix: stop the status line from flickering

The status line cleared and redrew on each refresh.
Now it only updates when the text changes.
```

### When the work is hers

Sometimes Lilly writes the code and asks only for a message ("write me a commit message"). Then:

1. Read the staged diff (`git diff --cached`), or the working tree if nothing is staged.
2. Write the subject in the repo's style (`git log --oneline -10`), and a short STE body if one helps.
3. Give it in a fenced `text` block. Do not run `git commit`.
4. Leave out `Co-Authored-By:` and other Claude trailers. The work is hers.

If she asks Claude to commit her work, still leave out the trailers. Commit Claude's own changes separately from hers, so the history shows whose work is whose.

## PR description

Keep it as short as possible: a summary of what changed and why, and only the notes a reviewer needs. The commits hold the detail.

```text
## Summary
Add a guard that checks commit messages before `git commit` runs.

The guard denies a message that breaks the repo's commit style.
It gives the reason, so the author can fix the message.

## Notes
The guard only checks repos that already use Conventional Commits.
```

## Rewriting: before and after

| Before | After |
| --- | --- |
| Refactored the module in order to facilitate easier testing of the parsing logic. | Split the parser from the I/O code. Tests can now call the parser directly. |
| This change basically ensures that stale entries are being removed from the cache. | Remove stale entries from the cache. |
| Fixes an issue whereby the app would crash when the config file was missing. | Fix a crash when the config file is missing. |
| Updated flake inputs. | Update `nixpkgs`. The new revision fixes the `hydrus` build. |

## How to check a text

1. Split it into sentences. Count the words in each. Over 25, or over 20 for an instruction: cut.
2. Look for passive verbs, "-ing" forms, "will be", and words from rule 5.
3. Look for a term that changes between sentences.
4. Check that each sentence has a reason or a result, not only a label.
5. Read it again for length. Delete what the diff already says.

STE here is a working standard, not a certification. If a rule makes a sentence unclear, keep the sentence clear and tell Lilly what you chose. Do not claim the text is "fully ASD-STE100 compliant".
