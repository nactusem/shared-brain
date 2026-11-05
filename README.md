# shared-brain

**Out of repo, out of mind.**

Claude Code forgets everything outside the folder it runs in. shared-brain lets it pick your whole brain.

I work on five projects at the same time, a day job and a few products of my own. Every session only knew its own folder,
so the same fixes were rebuilt in every repo and good patterns stayed where they were born.
Now when one project solves something well, the others find it and copy it.
This is the setup I use every day. Plain Markdown, one shell hook, one skill. No database, no server, nothing leaves your machine.

## How it works

```
every session      ~/.claude/CLAUDE.md  @imports  MAP.md          (max 100 lines)
in a group folder  SessionStart hook    adds      groups/<x>.md   (max 9,000 chars)
when needed        Claude reads         patterns.md, lessons.md, decisions.md
to update          /brain skill         preview -> your "ok" -> write -> local commit
```

## The catalog is the point

`MAP.md` lists every product with the parts worth copying, down to the file:

| Product | What it does | Worth copying |
|---|---|---|
| Invoicer | Billing for small shops | Retry without a double charge: atomic claim `src/claims.js`, race tests `test/claims.test.js` |
| Scheduler | Recurring tasks | Time zone safe recurrence engine `src/recur.js`, DST cases `test/recur.dst.test.js` |
| Reports | PDF exports | Owner only results: anyone else gets the answer an unknown id gets, `src/jobs/owner.js` |

A session in Scheduler that needs safe retries reads the map, sees that Invoicer already solved it,
and opens that code and its test instead of inventing a new version.
It copies something that already runs in production, not a summary of it.

## Install

```sh
git clone https://github.com/nactusem/shared-brain.git
cd shared-brain
./install.sh              # brain goes to ~/brain, or pass another folder
```

The installer copies the example brain, the hook and the skill, and never overwrites a file that is already there.
It does not touch your Claude Code settings. It prints the two lines you add yourself:
an `@` import in `~/.claude/CLAUDE.md` and a `SessionStart` hook in `~/.claude/settings.json`.

Then make it yours: describe your products in `MAP.md` and tell `map.tsv` which folder belongs to which group.

## What is in the brain

| File | Loads | Holds |
|---|---|---|
| `MAP.md` | every session | who you are, your areas, the product catalog, rules for every session |
| `map.tsv` | read by the hook | folder prefix and the group file it loads |
| `groups/<group>.md` | only in that group's folders | an employer's or a client's details, release rules, status |
| `patterns.md` | when needed | patterns proven in one product, with the code path |
| `lessons.md` | when needed | pains and lessons that help more than one project, open ones marked |
| `decisions.md` | when needed | decisions, newest first, with the why |

## Rules that keep it useful

1. **Small on purpose.** Hard limits per file, checked by `skills/brain/check-limits.sh` before every commit.
   The group limit keeps the hook output below the point where Claude Code cuts it.
2. **Boundaries.** Each group (employer, client, own company) has its own file, loaded only inside that group's folders.
   The map that loads everywhere never holds their details.
3. **A human approves every write.** `/brain` shows what it will write in five lines and waits for "ok".
4. **Lessons, not logs.** `lessons.md` keeps pains that help more than one project, with where the fix lives.
   Unsolved ones are marked open.

## How the hook picks a group

- The longest folder prefix that contains the working directory wins. `~/projects/invoicer-old` is not inside `~/projects/invoicer`.
- The working directory is only compared as a string, never evaluated.
- A map entry that looks like a path is ignored, so the map cannot point outside `groups/`.
- Every failure exits 0 without output. A broken brain never blocks a session.

## Tests

```sh
bash test/run.sh
```

Needs bash, jq and coreutils. CI runs it on Linux and macOS, because macOS ships bash 3.2 and BSD tools.
Every check was confirmed to fail against a deliberately broken copy of the code it guards.

## Why not an auto memory tool

Tools that record every session are great for "what did we do last week" in one project.
This solves a different problem: carrying decisions and proven code across projects, with boundaries a recorder cannot keep.

## License

MIT
