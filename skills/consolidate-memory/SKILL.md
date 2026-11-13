---
name: consolidate-memory
description: Find and resolve duplicate, forked and stale memories in the akyuu store. Use when Lilly says "consolidate the memories", "clean up the memory store", "run the check", or when akyuu check reports problems.
requires-mcp: akyuu
---

# Consolidate memory

The procedure is a memory in the store, so that any agent can follow it.
Read it first, then do what it says:

1. `ref_get` the ref `policy/consolidation`, then `get` the memory.
2. Follow it. Start with a dry run (`check`, `compare`, and the report only).
3. Apply a verdict only when Lilly asked for a real run.

Use the akyuu MCP tools (`check`, `compare`, `review`, `get`, `ref_set`).
The CLI has the same commands if the tools are not there.
If the ref is missing, say so and stop. Do not make up the procedure.
