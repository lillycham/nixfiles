---
name: obsidian-notes
description: Read and write notes in Lilly's Obsidian vault (~/Documents/lillys-research/lillys-research). Use when she says "add this to my reading list", "add that to obsidian", "write this up in obsidian", "update our notes", "tick it off", or pastes papers, research findings, or project ideas to save.
requires-mcp: obsidian
---

# Obsidian notes

Lilly's vault is at `~/Documents/lillys-research/lillys-research`. Reading there is allowed from any project.

When the Obsidian MCP server (`obsidian-mcp`, backed by Obsidian's Local REST API on `127.0.0.1:27123`) is available and Obsidian is open, use its tools; otherwise read and write the Markdown files in `~/Documents/lillys-research/lillys-research` directly.

## Where notes live

| Content | Path in vault |
| --- | --- |
| Papers, articles, books, links to read | `org/reading.md` |
| Ideas for papers | `org/paper-ideas.md` |
| Project notes, results, TODOs and roadmaps | `org/<project>.md` (for example `org/tiny-lm.md`, `org/owl-neurons.md`) |
| Research questions (canonical write-ups) | `research/<slug>/<Topic> — narrative.md` and `research/<slug>/<Topic> — rabbit holes.md` |
| Design notes and new project ideas | `ideas/<Project> — <Title>.md` |

Make a new file only when none of the existing notes fits, and ask first if unsure where it belongs.

## Formats

Read the target file first and match its style.

### Reading list (`org/reading.md`)

Entries sit under a `# Section` heading as `##` children (or at `#` with inline tags):

```markdown
## **TODO** Title

Authors, venue, year. <https://link>

One to three lines on what it is and why it matters to her work.
```

- Check for the title or URL first so you do not add a duplicate.
- "Tick it off" means changing `**TODO**` to `**DONE**`.
- Check a citation (authors, year, link) before you write it. If you cannot verify it, say so in chat.
- "Copy out only names and links" means plain output with no commentary.

### Research notes (`research/<slug>/`)

Each research question gets a pair of notes linked with `[[...]]` wikilinks:

1. `<Topic> — narrative.md`: YAML frontmatter (`question`, `project`, `model`, `status`, `updated`, `tags`), followed by `## Question`, `## Current answer`, `## Evidence for` (with strength in brackets), alternatives, and what would change her mind.
2. `<Topic> — rabbit holes.md`: dated log of promoted, parked, and dead-end side paths.

Point `akyuu` memories at the Obsidian note instead of duplicating long research write-ups in both places.

### Project notes (`org/<project>.md`)

Add new results under the existing results heading with the date, the numbers, and what they mean. Do not rewrite her earlier notes.
