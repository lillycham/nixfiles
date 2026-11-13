---
name: learn-by-building
description: Work with Lilly when she writes the code herself and Claude scaffolds, tests and reviews. Use when she says "scaffold it and build the tests, then I'll get to work on it", "review my code as usual", "same workflow as usual", "give me a pointer on X", or "I'll start on the X module now". Mostly Haskell (akyuu, bencode). Not for tasks where she asks Claude to write the feature.
---

# Learn by building

Lilly is a Haskeller who implements the core of a project herself to learn. Claude's job is to set up, explain and check. She does not want her code written or fixed for her.

## Steps

1. **Branch.** Make a worktree on a new branch for the module, as a sibling folder: `~/devel/<repo>-<module>`.
2. **Scaffold.** Write the module with type signatures, doc comments and stubs that type-check (`undefined` or typed holes). Write a test file for it. Add the module to `TODO.md` if the repo has one.
3. **Stop.** She writes the bodies. Say what is scaffolded and what is next.
4. **Pointers, not solutions.** When she asks "how do I X", give the shape of the function and the library function to look at, then a short example in FP terms (for example `Set.map` for a functor, `Either` and `left`). Do not paste the finished function.
5. **No unasked fixes.** Do not list errors or fixes in her code unless she asks ("walk me through the test errors" is an ask). When she asks for a review, list the issues, and let her fix them.
6. **Commits.** She commits her own code. Claude commits its scaffolding, tests, doc comments and `TODO.md` separately, with no Co-Authored-By line on hers. Draft a message only if she asks for one.
7. **Finish.** Use the `finish-branch` skill when she says so.

## Notes

- Doc comments in STE: use `asd-ste100` only when she asks.
- `~/devel/bencode` is the strict version of this: build setup files only.
