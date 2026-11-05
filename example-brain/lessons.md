# Lessons

> Read before proposing an idea, a tool or a new product. Only lessons that help more than one project.
> Format: **topic.** pain. lesson. (where the fix lives) [open]. Max 15,000 characters.

## Working with agents
- **A yes is for the next step.** One "yes" turned into building the whole feature in one go. A yes approves the next small step only.
- **Read only is a promise, not a setting.** A "read only" review agent wrote into `node_modules`, and two staging deploys shipped it. Say "write no files" in the prompt and run `npm ci` before every deploy. (Invoicer deploy script)
- **Claims from memory.** An agent stated seven things in a confident tone and all seven were wrong. A claim is proven in the same message, or the answer is "let me check".
- **Many agents, little gain.** A fix for two bugs took three agents and three hours. Extra reviewers paid off only in security review, where they disproved a third of the findings. Review by risk, not by habit.

## Security
- **A refusal is a signal.** "This name already exists" told an outsider that the record was there. A caller without access gets the answer an unknown id gets. (`patterns.md` Owner only answers)
- **Totals are data.** A count computed with app permissions showed how many items a user could not see. Show totals only to users who can see every item. [open: Invoicer dashboard]

## Tests
- **Counting is not covering.** A suite with 300 tests passed on a broken claim check. Break the code on purpose and make sure a test fails.
- **Habits do not hold, tests do.** Nineteen em dashes slipped into UI text one by one, and a reviewer missed them twice. (`patterns.md` Guard tests over habits)

## Releases and git
- **Push every slice.** A local repack lost 45 unpushed commits. Push the branch after every slice of work.
- **Set the identity first.** An empty global git identity produced commits with a made up email. In a new repo, set the local identity before the first commit.

## Open pains
1. Analytics, rate limiter and license checks are copied into every product and drift apart.
2. Nothing catches a silent failure in production: no error, no event, just missing work.
