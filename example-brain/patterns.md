# Patterns

> Engineering patterns proven in one product and worth copying into another. Always with the code path.
> A lesson that turned into a pattern moves here and leaves a one line pointer in `lessons.md`.

## Retry without a double effect
Invoicer charges once even when the same job runs twice. An atomic claim marks the work before the side effect.
A stale claim is resolved by asking the source of truth whether the effect happened, never by a timeout alone.
Code: `~/projects/invoicer/src/claims.js`. The race tests in `test/claims.test.js` use a barrier so that concurrent
answers really overlap; without it they pass on broken code too.

## Owner only answers
Reports: the result of an export job belongs to the user who started it. Everyone else gets exactly the answer an
unknown id gets, same status, same body. A different answer would confirm that the job exists.
Code: `~/projects/reports/src/jobs/owner.js`.

## Guard tests over habits
Scheduler: rules that matter are tests that scan the whole tree, not review comments. Example: no em dash in user
facing text, comments and log lines excluded. Code: `~/projects/scheduler/test/no-em-dash.test.js`.
