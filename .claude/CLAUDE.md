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
- it commits only the paths that batch's changed-file list names, plus the plan file;
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

## Tests are mandatory, written first, and run on the host

**Tests are part of the code, not an add-on to it.** Every behavior an agent
implements arrives with a test that proves it. There is no opt-in flag, no
"unless the plan asks", and no task that is too small — a change without a test
is an unfinished change.

**Test-first, and prove RED.** The order is not negotiable:

1. Write the test for exactly one behavior.
2. **Run it and show it fail** — the real output, naming the behavior that is
   missing. A test that has never failed has not been shown to test anything; it
   may pass because the assertion is vacuous, the fixture is wrong, or the case
   never executes.
3. Only then write the smallest production change that turns it GREEN.
4. Re-run and show it pass.

RED that cannot be demonstrated is a **halt**, not a formality to wave through.
If the test passes before the code exists, either the behavior is already
implemented — a plan discrepancy — or the test is not testing what it claims.

**Tests run on this host, directly.** Natively compiled, executed by the test
runner on this machine, in one command a human can re-run. Not cross-compiled to
a target, not flashed to a device, not inside a container, an emulator, a
simulator, or over a network to another machine.

This is *why* tests are affordable here rather than a reason they are not. The
embedded targets are exactly what makes on-target testing expensive, so logic
belongs behind a host-testable seam and the target-only part stays thin. Where
code cannot be tested on the host, the **design** is the defect: say so, and
treat it as a design question for me rather than a licence to skip the test.

**A test is never a deferred check.** Deferring is for things this machine
genuinely cannot do — reading a sensor, driving a peripheral, measuring real
timing. Those remain deferred, reported with the exact command and the machine
they belong on, and they are **not** a substitute for a host test of the same
logic. "It needs the target" is a claim to be checked, not accepted.

## Step boundaries — signal completion, never auto-advance

There are exactly four commands: `/review-project`, `/create-plan`,
`/implement-plan`, `/debug`. Each is one step. When a step is finished:

1. **Stop.** Do not begin the next phase on your own initiative.
2. **Signal completion clearly** — e.g. "Planning complete — plans/007-foo.md".
3. State what the next step would be and the command that runs it (e.g.
   "Next: run `/implement-plan plans/007-foo.md`"), but do NOT run it yourself.
4. Wait for the human to invoke the next command.

Why this is strict: each command pins its own model and effort in its own
frontmatter — `/review-project`, `/create-plan` and `/implement-plan` on Opus,
`/debug` on Sonnet.
Skills that get auto-loaded mid-session do NOT switch the model; they run on
whatever model the session is already on. So if you rolled from one phase into
the next on your own, you'd run it on whatever model the session happened to be
on rather than the one chosen for that phase. Requiring the human to start each
step via its command is exactly what keeps the model correct. **Never cross a
phase boundary without the human.**

The one exception: if the human asks you to elaborate, refine, or keep working
*within* the current step, continue in that step. The stop applies only to
moving on to the next step.

### A pinned model crosses a boundary safely; rolling forward does not

The rule protects the *model*, not the ceremony. Two things pin a model, and both
count: a subagent pins one in its own frontmatter, and **a slash command pins one
in its own frontmatter too**. Either way the phase runs on a model chosen for it
rather than on whatever the session happened to be on.

That is why `/create-plan` and `/implement-plan` may run several phases in one
invocation. Both delegate every phase and adjudicate the results —
`/create-plan` to brainstormer, planner, plan-reviewer and plan-simplifier,
`/implement-plan` to
implementer, reviewer, and the rarer debugger, verifier and planner. Neither
orchestrator writes the artifact its own reviewer will read.

What makes per-batch delegation affordable is that the orchestrator establishes
the project **once** — the build directory, the incremental build and test
commands, the layout and conventions — and hands the same brief to every spawn.
A spawn that re-runs project setup costs more than it saves, so re-configuring or
wiping a configured build tree is forbidden to every spawned agent, always.

The orchestrator does it at exactly **two scheduled points**: once before the
first batch, to establish a baseline that actually builds and whose suite is
green — otherwise no later failure can be attributed to a batch — and once at the
closing gate, so the completion claim is not an artifact of incremental state.
Everything in between is strictly incremental. `rm -rf` on a build tree remains
mine; the build system's own `--wipe`/`--reconfigure`/`--fresh` is the
orchestrator's at those two points.

Every agent and every command in this workflow states both `model:` and `effort:`
explicitly. Neither is left to inherit the session's, and neither should be added
without setting both.

This licenses nothing in-session. Continuing into the next phase yourself, on the
current session's model, is still forbidden — and both orchestrators still stop
for the human at their own consent points (`/create-plan` asks its design
questions and stops before implementation; `/implement-plan` halts rather than
guessing).

## The loop

Design → plan → execute in reviewable batches → verify with evidence. Each phase
is a delegated agent in `.claude/agents/`, pinned to its own model and effort;
the commands below orchestrate them. Prefer them over improvising.
Plans live as separate numbered files in `plans/`, one file per feature or
work item — never one monolithic plan document.

Entry points run the loop end-to-end by delegating, and each hands the next a
file:

```
/review-project  scope → audit N lenses → verify each finding → reviews/NNN-*.md
/create-plan     brainstorm → plan → review + simplify → refine → plans/NNN-*.md
/implement-plan  implement  → review → refine → next batch → closing gate
```

`/debug` is the fourth command: a single root-cause pass on a failure, used on
its own or when a run hands you something it could not explain.

`/review-project` is the only one that starts from no request at all — it asks
what the code *is*, on several lenses at once, and writes an evidenced report I
read before deciding what is worth doing. It changes nothing, and it never
flows into `/create-plan` on its own: choosing which findings become work is
mine. Review reports are numbered `max + 1` over `reviews/*.md`, cited as
"review NNN, finding A4", and never edited once written — a superseded review
stays as it was and a new audit takes a new number.

There is deliberately nothing else, and a fifth command needs a reason of the
same kind these four have: its own artifact, its own pinned model, and a phase
boundary I want to stand at. The per-phase commands that used to exist
(`/brainstorm`, `/plan`, `/execute`, `/review`, `/verify`, `/tdd`) are gone, and
so are the per-phase skills that mirrored them — every phase now lives in the
agent that runs it, reached through one of the three commands. Two skills remain
because a command depends on each: `systematic-debugging`, which is the substance
of `/debug`, and `test-driven-development`, which is the discipline the mandatory
testing rule above runs on.

Do not recreate a phase as a skill. A skill sits in every session's listing as a
route the model can take *instead* of the command, on whatever model the session
happens to be on — which is how the old per-phase skills drifted into
contradicting the commands they were meant to support.

**A reached bound is not a halt.** A review that will not come clean escalates —
diagnose, re-scope, re-adjudicate, amend the plan — and a stale plan is amended
rather than abandoned. What stops a run is a progress ledger: two consecutive
rounds that resolve nothing, change no finding, touch no file and produce no new
output. The halts that remain are the ones no further agent work can clear: a new
dependency, an undemonstrable RED, and a decision that would change what gets
built.

RED that cannot be demonstrated is also such a halt: it means the test or the
task is wrong, and no further agent work settles which.

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
