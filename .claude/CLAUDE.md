# Project workflow policy

## Version control is the human's job — do not touch it

You (the agent) must **never** run any command that changes git state or the
project's directory layout. This project owner keeps full manual control of
version control. Specifically, do not run:

- `git branch`, `git checkout`, `git switch`, `git worktree`
- `git commit`, `git merge`, `git rebase`, `git reset`, `git cherry-pick`
  (one narrow exception for `commit`/`add`, below)
- `git push`, `git pull`, `git stash`
- Any command that creates, moves, or deletes directories outside the working
  tree the human already has checked out (no scaffolding new worktrees, no
  relocating the repo).

You **may** run read-only git commands to understand state: `git status`,
`git diff`, `git log`, `git show`, `git blame`. Reading is fine; writing is not.

Work in place, in the branch and directory the human already has open. When a
task reaches a point where committing, branching, or merging would make sense,
**stop and tell the human what you'd suggest** — then let them run it. State the
exact commands you'd recommend so they can copy them, but do not execute them.

### The one carve-out: `/implement-plan --commit`

`/implement-plan` may run `git add` and `git commit`, and only under all of these
conditions at once:

- the human passed the explicit **`--commit`** flag on that invocation;
- the commit happens **after** the batch's reviews came back clean, never before;
- it commits only the paths the implementer reported, plus the plan file;
- the commits are **provisional scratch commits meant to be squashed** — a
  mechanical `plan NNN batch M: <task heading>` subject, no body, no trailers.

Nothing else widens. **No subagent may ever commit**, the flag never authorizes
`push`, `merge`, `rebase`, `amend`, `reset`, `stash`, `checkout`, a branch, or a
worktree, and without the flag that command commits nothing either. A repository
whose own `CLAUDE.md` or settings deny agent commits overrides this carve-out
there.

Why it exists: each approved batch being a commit is what gives the next batch's
reviewer an exact `HEAD~1..HEAD` scope, and what makes a halt leave only the
failing batch uncommitted for you to inspect.

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

### Delegation crosses a boundary safely; rolling forward does not

The rule protects the *model*, not the ceremony. A subagent pins its own model in
its own frontmatter, so spawning one runs that phase on the right model whatever
the session is on. That is why `/create-plan` and `/implement-plan` may run
several phases in one invocation: they never do a phase themselves, they delegate
each one to a fresh agent and adjudicate the result.

This licenses nothing in-session. Continuing into the next phase yourself, on the
current session's model, is still forbidden — and both orchestrators still stop
for the human at their own consent points (`/create-plan` asks its design
questions and stops before implementation; `/implement-plan` halts rather than
guessing).

## The loop

Design → plan → execute in reviewable batches → verify with evidence. The
skills in `.claude/skills/` encode each step. Prefer them over improvising.
Plans live as separate numbered files in `plans/`, one file per feature or
work item — never one monolithic plan document.

Two entry points run the loop end-to-end by delegating, and the plan file is the
interface between them:

```
/create-plan     brainstorm → plan → review the plan → refine → hand over
/implement-plan  implement  → review → refine → next batch → closing gate
```

The single-step commands remain: `/brainstorm`, `/plan`, `/execute`, `/review`,
`/verify`, `/debug`, `/tdd`. Use `/execute` over `/implement-plan` when you want
to watch the work batch by batch; `/implement-plan` runs unattended to the end of
the plan, or to a halt only you can clear.

**A reached bound is not a halt.** A review that will not come clean escalates —
diagnose, re-scope, re-adjudicate, amend the plan — and a stale plan is amended
rather than abandoned. What stops a run is a progress ledger: two consecutive
rounds that resolve nothing, change no finding, touch no file and produce no new
output. The halts that remain are the ones no further agent work can clear: a new
dependency, an unauthorized test, and a decision that would change what gets
built.

Plan numbers are `max + 1` over `plans/*.md` — never the first gap, never reused,
and a collision is a halt rather than a second file sharing a number.

After every batch spawn an agent that is meant to verify if the step
is correctly implemented based on the requirements described.
Every discrepancy should be signalled, as something might have been changed by me,
thus the correct action might be altering the plan.

The loop alters the plan itself rather than stopping: a delegated `planner` in amend
mode, inside a stated boundary — reconcile the plan with the repository, change no
design decision, add no scope — and every amendment is reported to me, because I
approved the plan I read and an amended task is one I have not. A discrepancy stops
the run only when reconciling it would change what gets built.
