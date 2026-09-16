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

`/implement-plan` may run `git add` and `git commit`, but only when the human
passed the explicit **`--commit`** flag on that invocation. Its full conditions —
only after that batch's reviews came back clean, only the paths on that batch's
changed-file list plus the plan file, and mechanical `plan NNN batch M: <task
heading>` subjects that exist to be squashed — are stated in
`.claude/commands/implement-plan.md` §9, which loads whenever that command runs.

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

**This binds the autonomous track; the assisting commands may not pretend
otherwise.** Everything above governs the loop, where an agent claims a behavior
is implemented. `/just` makes no such claim — it produces a diff and stops,
untested by construction — and it must say the change is unverified and name
`/verify`, never imply that it works. That is the entire exemption: a narrower
claim, not a lower standard. A change big enough that it needs a test to be
believed is a change `/just` bails upward on rather than types.

## Two tracks: the autonomous loop, and the assisting commands

There are seven commands, on two tracks, and they are not interchangeable.

**The autonomous loop — four commands.** `/review-project`, `/create-plan`,
`/implement-plan`, `/debug`. Each is one step of the loop. Each pins its own
model and effort, each does its own writing and delegates its reading to the
read-only agents in `.claude/agents/`, and the first three each leave a file
behind. These carry the full discipline in this document: mandatory test-first,
evidence for every claim, and a phase boundary I stand at.

**The assisting commands — three.** `/just`, `/review`, `/verify`. These are not
loop steps and they are not phases. Each runs on Sonnet in a single pass,
delegates nothing, writes no artifact, and hands the result straight back to me.
I am in the loop for every one of them; they exist for when I already know what I
want and need typing, a second pair of eyes, or evidence — not for autonomous
operation.

Never route between the tracks on your own initiative. An assisting command that
runs into loop-sized work says so and stops — `/just` bails upward and tells me
to run `/create-plan`, and does not plan it itself. A loop command never
substitutes an assisting command for one of its delegated phases:
`/implement-plan`'s reviewer is the `reviewer` agent, never the `/review`
command, and its closing gate is the `verifier` agent, never `/verify`.

## Writers run inline; readers are spawned, and spawned together

**One rule decides where a phase runs. A phase that changes a file runs inline,
in the command's own context. A phase that only reads runs as a spawned agent,
and every spawn a step needs goes out in a single message.**

`.claude/agents/` therefore holds **read-only agents only**, each with
`tools: Read, Grep, Glob, Bash`, writing nothing, and each pinning its own
`model:` and `effort:` — `ls .claude/agents/` is the inventory. There is no
`implementer`, `test-writer`, `planner` or `debugger` agent: implementing,
writing tests, writing and amending plans, and debugging are all things the
commands do themselves, on the model their own frontmatter pins.

**Review is the one thing that is never inline** — at any size, on any round,
however obvious the finding looks. The property the loop rests on is that **the
reader never wrote what it reads and cannot see why it was written that way.**

**The hazard inlining introduces: never edit a file while a spawn is in flight.**
Spawns keep running while the orchestrator works, so nothing mechanically stops
it starting the next batch, or a fix, over files a reviewer is still reading. A
reviewer that reads a file mid-edit reports findings against a state that no
longer exists, and a refine round is then spent on a phantom. Finish writing,
verify, assemble the changed-file list, spawn — then touch nothing until every
reader of that scope has reported.

Why the split is drawn here, what it costs and what holds the line:
`.claude/workflow-rationale.md`.

## Step boundaries — signal completion, never auto-advance

Each of the four loop commands is one step. When a step is finished:

1. **Stop.** Do not begin the next phase on your own initiative.
2. **Signal completion clearly** — e.g. "Planning complete — plans/007-foo.md".
3. State what the next step would be and the command that runs it (e.g.
   "Next: run `/implement-plan plans/007-foo.md`"), but do NOT run it yourself.
4. Wait for the human to invoke the next command.

**Never cross a phase boundary without the human.** Each command pins its own
model and effort in its own frontmatter, and a skill auto-loaded mid-session does
not switch the model — so rolling forward on your own initiative would run the
next phase on whatever model the session happened to be on rather than the one
chosen for it.

The one exception: if the human asks you to elaborate, refine, or keep working
*within* the current step, continue in that step. The stop applies only to
moving on to the next step.

A pinned model crosses that boundary safely: a slash command pins one in its own
frontmatter just as a subagent does, which is why `/create-plan` and
`/implement-plan` may run several phases in one invocation — each writes its own
artifact on its pinned model and delegates every *reading* phase, concurrently.
Neither orchestrator reviews what it wrote. **No spawn re-runs project setup**:
re-configuring or wiping a configured build tree is forbidden to every spawned
agent, always. The orchestrator does it at exactly two scheduled points — a
baseline that builds and whose suite is green before batch 1, and a clean rebuild
at the closing gate — and everything in between is strictly incremental. `rm -rf`
on a build tree remains mine. Never add an agent or a command without setting
both `model:` and `effort:`. The reasoning: `.claude/workflow-rationale.md`.

## The loop

Design → plan → execute in reviewable batches → verify with evidence. The
writing phases run inline in the command, on the model and effort its frontmatter
pins; the reading phases are read-only agents in `.claude/agents/`, each pinned
to its own, spawned concurrently. Prefer these commands over improvising.
Plans live as separate numbered files in `plans/`, one file per feature or
work item — never one monolithic plan document. Each entry point hands the next a
file: `/review-project` → `reviews/NNN-*.md`, `/create-plan` → `plans/NNN-*.md`,
`/implement-plan` → the implemented batches. Each command states its own
numbering, bounds and halt conditions.

`/review-project` is the only one that starts from no request at all — it asks
what the code *is*, on several lenses at once, and writes an evidenced report I
read before deciding what is worth doing. It changes nothing, and it never
flows into `/create-plan` on its own: choosing which findings become work is
mine. A review report is never edited once written — a superseded review stays as
it was and a new audit takes a new number.

The loop takes no fifth step. A new *loop* command needs a reason of the same
kind these four have: its own artifact, its own pinned model, and a phase
boundary I want to stand at. **Do not recreate a loop phase as a skill, and do
not add an assisting command that shadows one** — `.claude/workflow-rationale.md`
records why the per-phase skills were removed. Two skills remain because a
command depends on each: `systematic-debugging`, which is the substance of
`/debug`, and `test-driven-development`, which is the discipline the mandatory
testing rule above runs on.

**Two reviews, never three.** Any review→fix→re-review cycle in this workflow is
capped at **two rounds**: the review, one fix pass, one re-review. What happens
instead of a third is adjudication, not another spawn: re-read the surviving
findings assuming the reviewer may be wrong and reject what is mistaken, with the
rationale in the report; diagnose where a failure is unexplained; and where the
task itself is the defect, amend the plan and re-run that batch once. **A batch
closed on stated rejections, or a plan handed over with one named open finding,
is a legitimate outcome.** A reached bound is not a halt — it changes the
approach rather than ending the run; what stops a run is a progress ledger of two
consecutive rounds that resolve nothing, plus the halts no further agent work can
clear, which each command enumerates (`/implement-plan` §10 and §12).

After every batch spawn a read-only agent to verify that the step is correctly
implemented against the requirements described — never judge your own batch, at
any size. Every discrepancy should be signalled, as something might have been
changed by me, thus the correct action might be altering the plan.

The loop alters the plan itself rather than stopping: `/implement-plan` amends it
inline, inside a stated boundary — reconcile the plan with the repository, change no
design decision, add no scope — and every amendment is reported to me in its own
section, because I approved the plan I read and an amended task is one I have not.
A discrepancy stops the run only when reconciling it would change what gets built.
