# Project workflow policy

## Version control is the human's job — do not touch it

You (the agent) must **never** run any command that changes git state or the
project's directory layout. This project owner keeps full manual control of
version control. Specifically, do not run:

- `git branch`, `git checkout`, `git switch`, `git worktree`
- `git commit`, `git merge`, `git rebase`, `git reset`, `git cherry-pick`
- `git push`, `git pull`, `git stash`
- Any command that creates, moves, or deletes directories outside the working
  tree the human already has checked out (no scaffolding new worktrees, no
  relocating the repo).

You **may** run read-only git commands to understand state: `git status`,
`git diff`, `git log`, `git show`. Reading is fine; writing is not.

Work in place, in the branch and directory the human already has open. When a
task reaches a point where committing, branching, or merging would make sense,
**stop and tell the human what you'd suggest** — then let them run it. State the
exact commands you'd recommend so they can copy them, but do not execute them.

## Never read secrets
Never read any secrets or API keys, if read by accident,
always inform the user about it.
SUPER IMPORTANT! Never print them directly anywhere!

## Testing is opt-in

Do **not** assume test-driven development or write tests by default. This
codebase might includes embedded targets where a test harness can be larger and more
expensive than the code under test. Write tests only when the human explicitly
asks (e.g. invokes the `test-driven-development` skill or the `/tdd` command),
or when a plan task explicitly calls for them.

## Step boundaries — signal completion, never auto-advance

Each command does exactly ONE step of the loop (brainstorm, plan, execute,
verify, review, debug, tdd). When a step is finished:

1. **Stop.** Do not begin the next phase on your own initiative.
2. **Signal completion clearly** — e.g. "Planning complete — plans/007-foo.md".
3. State what the next step would be and the command that runs it (e.g.
   "Next: run `/execute plans/007-foo.md`"), but do NOT run it yourself.
4. Wait for the human to invoke the next command.

Why this is strict: each command sets its own model — `/plan` runs on Opus,
`/execute` on Sonnet. Skills that get auto-loaded mid-session do NOT switch the
model; they run on whatever model the session is already on. So if you rolled
from one phase into the next on your own, you'd run it on the wrong model
(executing on Opus = wasted budget; planning on Sonnet = worse reasoning).
Requiring the human to start each step via its command is exactly what keeps the
model correct. **Never cross a phase boundary without the human.**

The one exception: if the human asks you to elaborate, refine, or keep working
*within* the current step, continue in that step. The stop applies only to
moving on to the next step.

## The loop

Design → plan → execute in reviewable batches → verify with evidence. The
skills in `.claude/skills/` encode each step. Prefer them over improvising.
Plans live as separate numbered files in `plans/`, one file per feature or
work item — never one monolithic plan document.

After every batch spawn an agent that is meant to verify if the step
is correctly implemented based on the requirements described.
Every discrepancy should be signalled, as something might have been changed by me,
thus the correct action might be altering the plan.
