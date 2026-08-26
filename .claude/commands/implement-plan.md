---
description: Drive one plan file to done — implement, review, refine, escalate, repeat — stopping at the end, or only where it needs you
argument-hint: [--commit] <plan file, e.g. plans/007-uart-dma.md>
model: opus
effort: medium
---
Drive the plan file below from its first task to its last. You are the implementer *and* the
orchestrator: you read the plan, you **write the code yourself**, you delegate the review, you
adjudicate, you report.

**You implement in-session. You do not spawn an implementer.** This is deliberate and it is
the main thing that makes this command fast. A fresh implementer starts cold: it re-reads the
plan, re-derives the repository layout, and rediscovers the conventions you already know — and
it does that once per batch, and again per fix pass. You are already holding all of it. Writing
the batch yourself costs a few edits instead of a whole cold context, and it is why a batch
here is a matter of minutes rather than a matter of spawns.

**What you still delegate is review, and only review.** Not because reviewing is expensive to
do inline, but because you cannot do it: a reviewer that also wrote the code is not an
independent second look, it is the author re-reading their own reasoning. Independence is the
one property here that a subagent supplies and you cannot. Everything else is faster in your
own context.

Three named exceptions, none of them an implementer and none of them writing the batch for
you: a fresh `debugger` for a failure nobody has explained (§12 rung 1), a fresh `verifier` for
the closing evidence gate (§15), and a fresh `planner` in amend mode when the plan itself has
to change (§14) — that last one because §17 forbids *you* from editing the plan beyond its
checkboxes, and delegating is how that constraint is honoured. All three are rare. The
per-batch steady state is: you implement, reviewers review.

This does **not** stop for the human between batches. It runs to the
end of the plan, or to a halt only the human can clear. A review that will not come clean
escalates (§12) rather than stopping, and a plan that no longer matches the repository is
amended (§14) rather than abandoned. That autonomy is the reason the rules below are strict
rather than advisory.

**Cost shape, so it is not a surprise.** Orchestration and implementation both run here, on
opus at medium effort. Each batch is reviewed by one or two `reviewer` spawns on sonnet at high
effort. A twelve-task plan needing no refinement is roughly 12–24 reviewer spawns and **zero**
implementer spawns; a plan needing a refine pass per batch adds one re-review per batch, not a
second implementer. Prefer a short plan for a first run.

A batch that reaches the escalation ladder (§12) costs more — a diagnosis spawn, then a fix
pass per surviving finding, all of the fixes still yours. That is the price of not stopping,
and §12 requires the batch report to name it rather than letting the bill be the first the
human hears of it.

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

## 2. State the batching before starting

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
YOU implement the batch  (its tasks, in place, then run its verification)
  ├─ the plan contradicts the repository ──────────────► AMEND the plan (§14), re-do
  ├─ a verification failure you cannot explain ────────► ESCALATE (§12)
  └─ record the changed-file list yourself — it is the review scope (§7)
fresh reviewer      ┐  spawned in ONE message, both read-only
conventions reviewer┘  (only where the project defines one, and it applies — §6)
adjudicate every finding
  ├─ accepted findings? → YOU fix them → fresh re-review
  │    └─ 2 rounds and still not clean ────────────────► ESCALATE (§12), budget resets
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

## 4. A fresh reviewer for every review

You wrote the code, so you can never be its reviewer — that is the whole reason review is the
one thing delegated here. And never reuse a reviewer across a refine iteration: a reviewer that
has already approved its own reasoning is not an independent second look either. Every review
spawn is a new agent with no memory of the last one.

Correspondingly: **do not spawn an `implementer` from this command**, not for a batch, not for
a fix pass, not for a "small" task you would rather hand off. The agent exists for the
`feature-development` skill, which has no warm orchestrator to do the work. Here you are that
orchestrator, and handing your own context away and paying to rebuild it is exactly the cost
this command was rewritten to remove.

## 5. Spawn the reviewers in one message

They are read-only, so they cannot conflict and they should run concurrently. Spawn both in a
single message. Never edit files while a review of those files is in flight — finish writing,
then review what you wrote.

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
instead: the batch's task text, **the changed-file list you kept while implementing**, and a
note naming the files earlier batches already touched whose changes are reviewed and out of
scope. A finding against an already-reviewed file is answered with that note, not a fix.

Keeping that list is now your own bookkeeping rather than something you read out of a
subagent's report, so **write it down as you go** — every path you create or edit in the
batch, at the moment you touch it. Do not reconstruct it afterwards from `git status`: that
picks up anything the human left in the tree and anything an earlier batch touched, and a
review scoped to it will spend its findings outside the batch. If you genuinely lose track,
say so in the batch report rather than shipping a scope you invented.

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
paths on your §7 changed-file list — **plus the plan file if its checkboxes changed** — and
commit them. Never before review, never a partial batch, never a file that is not on the
list.

The plan file is included deliberately: you tick its checkboxes as you go, and leaving those
edits out would leave the tree dirty from batch 2 onward, falsifying §10's claim that a halt
leaves only the failing batch uncommitted.

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

A refine loop gets **2 rounds** of the straightforward thing: you fix the accepted findings,
then a fresh re-review. Reaching the second without a clean review ends *that approach*, not
the batch. Take the next unused rung below, then continue with a fresh budget of 2.

The budget is 2 rather than 3 because a fix round no longer costs a cold implementer spawn —
you are fixing in place, in context, so a round that was going to work usually works on the
first pass. A second identical attempt is already weak evidence; a third was mostly buying
time for an agent that had to re-learn the batch each round, and there is no such agent now.

1. **Diagnose before fixing again.** Spawn a fresh `debugger` for a failure, or a fresh
   `verifier` for a check whose output nobody has explained, with the surviving findings and
   the exact command. Both are diagnostic: they establish the root cause, they do not
   implement the batch — you still write the fix. Trying the same fix a third time is not an
   escalation, it is the same rung again, and two identical attempts having failed is evidence
   the assignment is wrong rather than the execution.
2. **Re-adjudicate, then amend if the task is the defect.** Read the surviving findings again
   yourself, as in §8. A finding that has outlived two fix attempts is frequently one the
   reviewer is wrong about, or one whose fix the task forbids: reject it with a rationale that
   goes in the report. If instead the task as written cannot be satisfied, the task is the
   defect and no further attempt will discover otherwise — **amend the plan** (§14) and run
   the batch against the amended task.

Each rung is used **at most once per batch**, and the batch report names every rung taken and
what it changed. Using both hands the batch to §13.

## 13. The progress ledger — how the loop knows it is still getting somewhere

Removing the iteration cap needs something in its place, and a bigger number is not it. After
every round — refine, escalation, or gate — record whether that round **made progress**. It
did when at least one of these is true:

- an open finding was resolved, or rejected with a rationale;
- the set of open findings *changed* — one appeared, one disappeared, one turned out to be a
  different defect. The same set restated in new words is not a change;
- the batch's changed-file list (§7) grew — you actually edited something;
- a verification command produced output it had not produced before, **including a new
  failure** — a different failure is information;
- the plan was amended (§14).

A round where none of these holds is **unproductive**. One unproductive round forces the next
rung of §12's ladder immediately, rather than spending the rest of that budget. **Two
consecutive unproductive rounds end the run**: report and stop.

With a 2-round budget and a 2-rung ladder — each rung granting a fresh budget of 2 — a batch
that never converges costs at most six re-reviews and one diagnostic spawn before it reaches
you, and the ledger usually ends it sooner than that. That is the intended shape:
this loop is meant to clear the batches that are merely fiddly and hand you the ones that are
actually wrong, quickly, rather than grinding on them.

Keep the ledger in the batch report, one line per round naming which signal fired. It is the
evidence that the loop was converging rather than circling, and when the loop does stop it is
the account of everything that was tried.

## 14. Amending the plan — delegated, bounded, and reported loudly

When the repository and the plan disagree, the plan is often the thing to fix: the human may
have changed the code since it was written, and a discrepancy is a signal about the plan, not
only about the code. Amend it. Do not guess, and do not stop.

**Triggers.** Work a task describes is already present. A path, symbol or command a task names
has moved or been renamed. A verification step cannot run as written. A task that cannot be
satisfied as written (rung 2 of §12). A structural defect that leaves the file unbatchable
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
gate. The gate gets its own budget of **2 rounds**, counted separately from any batch's, plus
its own copy of §12's two-rung ladder and §13's ledger: a reached bound here escalates exactly
as it does inside a batch, and a gate finding that turns out to be a plan defect amends the
plan through §14 like any other. The fixes are yours, as everywhere else in this command.

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
- **Do not spawn an `implementer`, and do not spawn a general-purpose agent to stand in for
  one.** The code in this command is yours to write (§4). The only agents this command spawns
  are `reviewer` and any project conventions reviewer every batch, and `debugger`, `verifier`
  and `planner` at the three rare points §12, §15 and §14 name.

## Why implementing in-session does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because **each phase belongs on a
deliberately chosen model**, and rolling forward inside one session would run the next phase
on whatever model the session happened to be on. That is the property the boundary protects —
not the ceremony of a subagent.

This command satisfies it two ways at once. Review runs on a model this repository chose for
review: `reviewer` pins `sonnet` at `high` effort in its own frontmatter, whatever this session
is. And implementation runs on a model this repository chose for implementation, because a
slash command pins its own model too — the frontmatter at the top of this file sets `opus` at
`medium` effort, and that is what you are running on right now. Nothing here inherits an
accidental model.

What the old shape bought with a per-batch `implementer` spawn was a *different* model for the
implement phase. What it paid was a cold context per batch and per fix pass. Since a command
can pin its own model, the boundary is honoured without paying that, and the payment is the
whole reason this command was slow.

The rule that has not moved: **do not roll from this command into the next phase yourself.**
When the plan is done, this command stops and reports. What happens next — another plan,
a review of the whole change, a commit — is the human's to start.

## Related entry points

There are three commands in total. `/create-plan` produces the plan file this one consumes,
and `/debug` handles a failure on its own. Everything else that used to be a command is now
either a phase inside these two or a skill you can invoke by name.

Plan file: $ARGUMENTS
