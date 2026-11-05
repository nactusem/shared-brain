# Map

> Loaded in every Claude Code session through an `@` import in `~/.claude/CLAUDE.md`. Max 100 lines.
> Update it with `/brain`. Group details never go here: this file loads everywhere.

## Who
Alex. Backend engineer, 12 years of Java. Works on a day job and on two products of a small own company.

## Areas
| Area | What | Folders | Group brain |
|---|---|---|---|
| Acme | Day job, payments platform | `~/work/acme/` | `groups/acme.md` |
| Northwind | Own company, small SaaS products | `~/projects/northwind/` and the product folders | `groups/northwind.md` |
| Personal | Side projects, no group brain | `~/projects/personal/` | none |

`map.tsv` decides which group brain loads in which folder.

## Product map and catalog
Before building something, look here. If another product already solved it, read that code and its test first.

| Product | Group | What it does | Code | Worth copying |
|---|---|---|---|---|
| Invoicer | Northwind | Billing for small shops | `~/projects/invoicer` | retry without a double charge: atomic claim `src/claims.js`, race tests `test/claims.test.js`; webhook replay guard `src/webhooks/dedupe.js` |
| Scheduler | Northwind | Recurring tasks | `~/projects/scheduler` | time zone safe recurrence engine `src/recur.js`, DST cases `test/recur.dst.test.js`; tree scan test against em dashes in UI text `test/no-em-dash.test.js` |
| Reports | Northwind | PDF exports | `~/projects/reports` | owner only results: a job's result goes to its owner, anyone else gets the answer an unknown id gets, `src/jobs/owner.js` |

Acme products are not listed: their details live in `groups/acme.md` and load only inside Acme folders.

## Read when needed
- `patterns.md`: engineering patterns proven in one product, with the code path.
- `lessons.md`: pains and lessons that help more than one project. Read before proposing an idea.
- `decisions.md`: decisions, newest first.

## Rules for every session
1. Before building, check the catalog above. Before proposing an idea, read `lessons.md` and check what already exists.
2. Never write secrets, tokens or customer data into the brain.
3. Update the brain only with `/brain`. It previews and waits for "ok".
