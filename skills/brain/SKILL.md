---
name: brain
description: Updates the shared brain in __BRAIN_DIR__ with what this session learned. Runs when the user types /brain. Claude also offers it when a session ships a product, makes a decision that matters, or learns a lesson that would help another project. It always previews first and waits for the user's ok.
---

# /brain: update the shared brain

The brain lives in `__BRAIN_DIR__`. `MAP.md` loads in every session. `groups/<group>.md` loads only inside the
folders `map.tsv` assigns to that group. `patterns.md`, `lessons.md` and `decisions.md` are read when needed.

## Steps
0. Before writing anything, show what you will write in at most five short bullets and wait for the user's "ok".
1. Find this session's group in `map.tsv`: the longest folder prefix that contains the working directory wins.
   No match means only the shared files apply.
2. Keep only what other sessions need to know:
   - A product's version or status changed: the group file, and the product row in `MAP.md` if needed.
   - A feature or pattern another product could copy: `patterns.md` with the code path, and the
     "Worth copying" column in `MAP.md`.
   - A decision: the top of `decisions.md`, dated, with the why in the same line.
   - A pain or lesson that helps more than one project: one bullet in `lessons.md` with the pain, the lesson
     and where the fix lives. Mark an unsolved one `[open]`. A lesson that only matters to one project stays
     in that project. A lesson that became a pattern moves to `patterns.md` and leaves a one line pointer.
   - A new product or folder: a line in `map.tsv`, a row in `MAP.md`, and a line in the group file.
3. If nothing matters beyond this session, write nothing and say so in one sentence.
4. Write short. Update the existing line instead of adding a second one, and delete what is no longer true.
5. Run `bash check-limits.sh __BRAIN_DIR__` from this skill's folder. If a file is over its limit, shorten or
   merge before you commit.
6. Never write secrets, tokens, customer data or personal finance. A group's details stay in its group file:
   `MAP.md` loads everywhere and never holds them.
7. Commit only the brain: `git -C __BRAIN_DIR__ add -A && git -C __BRAIN_DIR__ commit -m "<what changed>"`.
8. Tell the user in at most five bullets which file got what.
