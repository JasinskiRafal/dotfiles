---
description: Drive one plan file to done — implement, review, refine, escalate, repeat — stopping at the end, or only where it needs you
argument-hint: [--commit] <plan file, e.g. plans/007-uart-dma.md>
model: opus
---
Drive the plan file below from its first task to its last. You are the orchestrator: you
read, you delegate, you adjudicate, you report. You do not write production code yourself
— every implementation and every review is a fresh subagent.

Unlike `/execute`, this does **not** stop for the human between batches. It runs to the
end of the plan, or to a halt only the human can clear. A review that will not come clean
escalates (§12) rather than stopping, and a plan that no longer matches the repository is
amended (§14) rather than abandoned. That autonomy is the reason the rules below are strict
rather than advisory.

**Cost shape, so it is not a surprise.** Orchestration runs on opus, each implement pass on
sonnet, and each batch is reviewed by one or two opus agents. A twelve-task plan needing no
refinement is roughly 12 implementer and 12–24 reviewer spawns; a plan needing two refine
passes per batch roughly triples the review count. Prefer a short plan for a first run.

A batch that reaches the escalation ladder (§12) costs more again — a diagnosis pass, then a
fix pass per surviving finding. That is the price of not stopping, and §12 requires the batch
report to name it rather than letting the bill be the first the human hears of it.

## 1. Parse the arguments, then read the plan in full and critique it

The argument at the end of this file carries the plan path and optionally the flag
**`--commit`**. Strip the flag; the remaining token is the plan file. Without the flag the
loop never commits, which is the default.

**When `--commit` is present, check two preconditions once, before batch 1. Each unmet one
is a halt.**

- **The working tree is clean** — `git status --porcelain` must be empty. Otherwise the
  first commit would capture unrelated work in progress. On failure, report the dirty
  paths and stop; the human decides whether to commit them or set them aside.
- **HEAD is not the default branch** — resolve it with
  `git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to whichever of
  `main` or `master` exists when there is no remote HEAD. You may not create a branch, so
  on the default branch report the `git switch -c <name>` command for the human and stop.

Then read the whole file — Goal, Context, Constraints, Tasks, Out of scope, Open questions.
Then say what is wrong with it. Ambiguity, a task that contradicts the codebase, a
verification step that cannot be run, an Open question whose answer changes a task: raise
all of it now.

If a problem can be settled by inspecting the repository, settle it and say so. If the plan
is *wrong* about the repository — a path that moved, work already present, a verification
command that cannot run as written — amend the plan through §14 and carry on. The plan is a
specification, and a specification written before the code moved is the thing at fault.

What remains a **halt** is a problem only the human can settle: a decision the plan left open
whose answer changes what gets built, or a task that needs a dependency. Never a guess, and
never a "reasonable assumption" recorded in a footnote.

## 2. State the batching before spawning anything

Default: **one batch per `###` heading inside the plan's `## Tasks` section**, whatever
that heading is labelled. Merge two adjacent tasks only when one is meaningless without the
other, and name the merge and its reason. There is no human at a checkpoint to confirm a
proposed batching, which is exactly why the default is mechanical rather than a judgement
call.

Match on position, not on wording. Plans in the wild use at least three task-heading
conventions — `### Task 1 — …`, `### 1. …`, and `### Phase A — …` — and a rule keyed to any
one of them silently finds nothing in the others. The `###` headings under `## Tasks` are
the batches in all three.

If the plan has no `## Tasks` section, or that section contains no `###` heading, do not
invent a batching from prose — and do not stop either. Send the file to §14 for a structural
amendment, where a fresh `planner` reshapes the work **already written in the file** into
`### Task N` headings and changes nothing else. If the file cannot be divided without
inventing work that is not in it, that is a **halt**: the split is a design decision, and it
is the human's.

Print the batching, then begin.

## 3. The per-batch loop

```
fresh implementer  (batch tasks + plan path + accumulated-changes note)
  ├─ reports a plan/repository discrepancy ─────────────► AMEND the plan (§14), re-run
  ├─ reports an unexplained verification failure ──────► ESCALATE (§12)
fresh reviewer      ┐  spawned in ONE message, both read-only
conventions reviewer┘  (only where the project defines one, and it applies — §6)
adjudicate every finding
  ├─ accepted findings? → fresh implementer (fix mode) → re-review
  │    └─ 3 rounds and still not clean ────────────────► ESCALATE (§12), budget resets
  │         └─ ladder used up, two rounds no progress ─► STOP and report (§13)
commit the batch  (only with --commit; never before review passes)
emit batch report, continue without waiting
```

The three arrows that used to read HALT are what §12–§14 exist for. A review that will not
come clean and a plan that contradicts the repository are both **work this loop can still
do**; treating either as a stop wastes a run that was one changed approach away from
finishing. What ends the run is §13's ledger — the loop having demonstrably run out of moves
— not a counter reaching three. The halts left in §10 are the ones no amount of agent work
can resolve.

## 4. A fresh agent for every assignment

Never reuse an implementer as its own reviewer. Never reuse a reviewer across a refine
iteration — a reviewer that has already approved its own reasoning is not an independent
second look. Every spawn is a new agent with no memory of the last one.

## 5. Spawn the reviewers in one message

They are read-only, so they cannot conflict and they should run concurrently. Never run two
file-mutating agents at the same time.

## 6. The second review angle is conditional

Some repositories define their own conventions reviewer — a project-level
`.claude/agents/guidelines-reviewer.md` or similar — that audits a diff against that
project's written coding rules. Check whether one exists before batch 1 and say what you
found.

- **No such agent** — spawn the correctness `reviewer` alone, every batch, and say so once.
- **It exists** — spawn it beside `reviewer`, but only when the batch's changed-file list
  actually falls under its remit (typically source files, not markdown, compose files, or
  shell scripts). When it does not apply, record in the batch report that the pass was
  skipped and why. Inventing a rule ID for a file the rules do not govern is a defect, not
  thoroughness.

## 7. Scope each review explicitly

`git diff` shows the whole working tree against `HEAD`, so by the third batch it contains
the first two. Narrowing it with git is forbidden. Give every reviewer three things
instead: the batch's task text, the changed-file list the implementer reported, and a note
naming the files earlier batches already touched whose changes are reviewed and out of
scope. A finding against an already-reviewed file is answered with that note, not a fix.

If an implementer's report omits the changed-file list, ask it for the list rather than
reconstructing one from `git status` — the point of taking it from the report is that it
records what that agent believes it changed, which is what the review is scoped to.

**With `--commit` active this gets simpler.** Every approved batch is already a commit, so
from batch 2 onward the scope is exactly `HEAD~1..HEAD`, and you tell the reviewer so. The
three-part prose scope above remains the fallback for two cases: the whole no-flag path,
and batch 1, where no commit from this run exists yet. Say which of the two you are using.

## 8. Adjudicate every finding — do not obey blindly

Accept a `blocking` or `should-fix` finding when it is technically justified and inside the
batch's scope. Reject the rest, each with a one-line rationale that goes into the report.
A `nit` never starts a refine iteration. An accepted finding that turns out to require a plan
change goes to §14 for an amendment — not to a halt, and not to a fix that quietly
contradicts the task it was working from.

## 9. Commit the batch — only with `--commit`, and only after review

Once the batch's reviews come back clean and its findings are adjudicated, `git add` the
paths the implementer reported — **plus the plan file if its checkboxes changed** — and
commit them. Never before review, never a partial batch, never a file the implementer did
not report.

The plan file is included deliberately: the implementer ticks its checkboxes as it goes, and
leaving those edits out would leave the tree dirty from batch 2 onward, falsifying §10's
claim that a halt leaves only the failing batch uncommitted.

The message is mechanical, because these are scratch commits:

```
plan NNN batch M: <the batch's task heading, verbatim>
```

No body, no co-author trailer, no generated-with line. **These commits are provisional and
exist to be squashed** — they buy exact review scope and a recoverable halt, not history.
Do not "improve" them into messages meant to survive; the human writes the one that does.

A commit here means *implemented and reviewed clean*, which is the property that makes
`HEAD~1..HEAD` a scope a reviewer can trust in §7.

## 10. Halt conditions — the ones no further agent work can resolve

Every halt left on this list needs something only the human has: their consent, or knowledge
that is not in the repository.

- A task needs a **new third-party dependency** — that requires asking, with a usage example
  and an honest cost/benefit.
- A task calls for a **test the plan did not authorize**. Testing is opt-in.
- A decision the plan left in **Open questions**, or a discrepancy whose resolution would
  change what gets built, that inspection cannot settle. This is §14's line: reconciling the
  plan with reality is yours, choosing a different shape is theirs.
- The loop has **run out of moves** — §13's ledger unproductive twice running. Because the
  first unproductive round already forces a new rung of §12's ladder, a second one means the
  approach changed and still moved nothing. This is the only loop-exhaustion stop that
  remains, and it reports what the loop tried, not merely that it stopped.

**A review that will not come clean is not on this list, and neither is a plan that
contradicts the repository.** Those escalate (§12) or amend (§14). A reached bound changes the
approach; it does not end the run.

On any halt: emit the full report for the batches already completed, state the halt reason
and precisely what is needed to resolve it, change nothing further, and stop. A halt is a
successful outcome of this command, not a failure of it.

**With `--commit` active, a halt leaves every approved batch committed and only the failing
batch dirty and uncommitted.** That is the state a human wants to inspect. Say so in the
report, and offer `git reset --soft HEAD~1` as text if they want the last batch unpicked —
it is the human's to run, so it goes in the report and nowhere else.

## 11. Not a halt

A check that needs a resource you cannot reach from here — target hardware, an accelerator,
a device, a deployed environment, credentials you do not hold. Record it as a **deferred
check** and continue, naming the exact command and the machine it belongs on. Where the
project batches such checks into one pass at the end of a plan series, follow that.

## 12. The escalation ladder — what a reached bound does instead of stopping

A refine loop gets **3 rounds** of the straightforward thing: accepted findings to a fresh
implementer in fix mode, then a fresh re-review. Reaching the third without a clean review
ends *that approach*, not the batch. Take the next unused rung below, then continue with a
fresh budget of 3.

1. **Diagnose before fixing again.** Spawn a fresh `debugger` for a failure, or a fresh
   `verifier` for a check whose output nobody has explained, with the surviving findings and
   the exact command. Hand its root cause to the next implementer. Sending the same
   assignment to a fourth fresh implementer is not an escalation — it is the same rung again,
   and three identical attempts having failed is evidence the assignment is wrong.
2. **Re-scope.** Give each surviving finding its own implementer, scoped to only the files
   that finding touches. A batch that will not converge as a whole often converges one
   finding at a time, because two fixes were undoing each other.
3. **Re-adjudicate.** Read the surviving findings again yourself, as in §8. A finding that has
   outlived three fix attempts is frequently one the reviewer is wrong about, or one whose fix
   the task forbids. Reject it with a rationale that goes in the report, or recognise it as a
   plan defect and take rung 4.
4. **Amend the plan** (§14). If the task as written cannot be satisfied, the task is the
   defect and no further implementer will discover otherwise.

Each rung is used **at most once per batch**, and the batch report names every rung taken and
what it changed. Using all four hands the batch to §13.

## 13. The progress ledger — how the loop knows it is still getting somewhere

Removing the iteration cap needs something in its place, and a bigger number is not it. After
every round — refine, escalation, or gate — record whether that round **made progress**. It
did when at least one of these is true:

- an open finding was resolved, or rejected with a rationale;
- the set of open findings *changed* — one appeared, one disappeared, one turned out to be a
  different defect. The same set restated in new words is not a change;
- the implementer reported a non-empty changed-file list;
- a verification command produced output it had not produced before, **including a new
  failure** — a different failure is information;
- the plan was amended (§14).

A round where none of these holds is **unproductive**. One unproductive round forces the next
rung of §12's ladder immediately, rather than spending the rest of that budget. **Two
consecutive unproductive rounds end the run**: report and stop.

Keep the ledger in the batch report, one line per round naming which signal fired. It is the
evidence that the loop was converging rather than circling, and when the loop does stop it is
the account of everything that was tried.

## 14. Amending the plan — delegated, bounded, and reported loudly

When the repository and the plan disagree, the plan is often the thing to fix: the human may
have changed the code since it was written, and a discrepancy is a signal about the plan, not
only about the code. Amend it. Do not guess, and do not stop.

**Triggers.** Work a task describes is already present. A path, symbol or command a task names
has moved or been renamed. A verification step cannot run as written. A task that cannot be
satisfied as written (rung 4 of §12). A structural defect that leaves the file unbatchable
(§2).

**How.** Spawn a fresh `planner` in amend mode with the plan path, the specific task, the
evidence for the discrepancy, and this boundary stated verbatim: *reconcile the plan with the
repository; change no design decision and add no scope.* You never edit the plan yourself
beyond its checkboxes — the constraint in §17 is unchanged, and delegating is how it is
honoured. Then re-read the amended task and run the batch against it.

**Report every amendment loudly** — in the batch report and again in the final one, with what
changed and the evidence that prompted it. The human approved the plan they read; an amended
task is a task they have not read. Burying that in a summary is how an unattended loop
quietly builds something else.

**The line an amendment may not cross.** If reconciling the plan with reality would change
*what gets built* — a different approach, a different interface, work the design put out of
scope — that is not an amendment. It is a design decision, and §10 has it. Reality can be
reconciled autonomously; intent cannot.

With `--commit` active the amended plan file rides along in the batch's commit, which §9
already includes.

## 15. The closing gate

After the last batch, spawn a fresh `verifier` for the evidence gate and a fresh `reviewer`
with whole-plan scope. Claim completion only when both come back clean.

If either does not, adjudicate its findings as in §8 and run a fix pass, then re-run the
gate. The gate gets its own budget of **3 rounds**, counted separately from any batch's, plus
its own copy of §12's ladder and §13's ledger: a reached bound here escalates exactly as it
does inside a batch, and a gate finding that turns out to be a plan defect amends the plan
through §14 like any other.

The gate stops the run only on §13's terms — the ladder used up and two consecutive
unproductive rounds. By the time the gate runs, nearly all of the run's work is already spent,
which is the argument for escalating here rather than stopping on a count. It is equally the
argument for stopping *honestly* when there is nothing left to try, instead of circling on the
most expensive part of the run: report the unresolved findings, the evidence gathered, every
batch that did pass, and the ladder rungs already taken, and make no further change.

## 16. The final report

- the plan path, and the batching used;
- batches completed, and the files changed by each;
- verification evidence — real command output, not claims;
- review history per batch, with the **progress ledger** and the escalation rungs taken;
- every **plan amendment**: the task, what changed, and the evidence that prompted it. Give
  this its own section — it is the part of the run the human has not read;
- findings **rejected**, and the rationale for each;
- deferred checks, with the exact commands and the machine to run them on;
- **with `--commit`: the commit list**, one line per batch with its short SHA, plus the
  reminder that they are provisional and the `git rebase -i <base>` command for squashing
  them;
- the git commands the human may choose to run.

## 17. Hard constraints

- **Git is tiered by reversibility.** Read-only (`status`, `diff`, `log`, `show`,
  `blame`) is always allowed. The **additive** tier — `git add` and `git commit` — is
  available to *you only*, only with `--commit`, and only at the post-review checkpoint in
  §9; this is the single carve-out in `~/.claude/CLAUDE.md`'s version-control policy, and it
  does not widen. No agent you spawn may commit. The **destructive** tier — all of
  `git stash` and `git checkout`, plus `restore`, `clean`, `rm`, `reset --hard`, `rebase`,
  `commit --amend`, `push`, `branch -D`, `tag -d`, `worktree add`/`remove` and the rest — is
  the human's alone, and some projects deny it mechanically in `.claude/settings.json`.
  Never branch, switch, or create a worktree. Put any command you may not run in the report
  for the human.
- **A project that forbids agent commits outright wins.** If the repository's own
  `CLAUDE.md` or settings deny `add`/`commit`, `--commit` is unavailable there: say so and
  run the unflagged loop instead of working around it.
- Never read or print a secret or an API key.
- Do not edit the project's guideline or convention documents. The loop is held to those
  rules; it does not rewrite them.
- Do not edit the plan file yourself beyond ticking its checkboxes. A substantive change goes
  through a delegated `planner` in amend mode (§14), inside that section's boundary, and is
  reported.

## Why running several phases unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each phase belongs on a
different model, and rolling forward inside one session would run the next phase on the
current session's model. Delegation does not have that problem: every agent pins its own
model in its own frontmatter, so implement runs on sonnet and review runs on opus whatever
this session is. Spawning a subagent is the one way to cross a phase boundary while
preserving exactly what the boundary protects. Do not read this loop as a licence to cross
a boundary in-session.

## Related entry points

This drives one plan file. `/execute` remains the batch-at-a-time alternative for a plan the
human wants to watch as it goes, and `/review` remains available for a standalone pass over
the current diff.

Plan file: $ARGUMENTS
