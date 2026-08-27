---
description: Drive one plan file to done — implement, review, refine, escalate, repeat — stopping at the end, or only where it needs you
argument-hint: [--commit] <plan file, e.g. plans/007-uart-dma.md>
model: opus
effort: medium
---
Drive the plan file below from its first task to its last. You are the orchestrator: you read
the plan, you **delegate the test to a fresh `test-writer` and the code to a fresh
`implementer`**, you delegate the review to a fresh `reviewer`, you adjudicate all of it, you
report.

**You delegate. You write neither the tests nor the batch yourself.** Each batch is a fresh
`test-writer` that proves RED, then a fresh `implementer` that turns it GREEN; each fix pass is
a fresh `implementer`. All of them pin `sonnet` at `medium` effort in their own frontmatter, so
those phases run on a model chosen for them rather than on the `opus` this file pins for
orchestrating. That split is the point: orchestration and adjudication want the stronger model,
writing a test or satisfying an already-specified one does not.

**Testing is mandatory here and tests run natively on this host.** The RED-before-GREEN order
is a hard rule, not a preference — see the self-verification gate in §3 and the halts in §10.
A batch without a demonstrated failing test is not a batch this loop will implement.

**What you also delegate is review, and for a different reason.** Not cost — you *cannot* do
it: a reviewer that also wrote the code is not an independent second look, it is the author
re-reading their own reasoning. Here neither of you wrote it, which makes the independence
cleaner still.

Two more delegates, both rare: a fresh `debugger` for a failure nobody has explained (§12 rung
1) and a fresh `verifier` for the closing evidence gate (§15); plus a fresh `planner` in amend
mode when the plan itself has to change (§14) — that last one because §17 forbids *you* from
editing the plan beyond its checkboxes, and delegating is how that constraint is honoured. The
per-batch steady state is: a test-writer specifies, an implementer implements, reviewers
review, you adjudicate.

Three different agents per batch is also what makes the review honest. The `implementer` did
not write the test it has to satisfy, and the `reviewer` wrote neither — so nobody in the chain
is checking their own reasoning.

**What you never do is let a spawn rediscover the project.** A cold spawn's expensive half is
not writing the code — it is re-deriving the build, the layout and the conventions, once per
test-writer, once per implementer, and again per fix pass. That is what the **warm handoff** below removes: you establish
the build directory and the project facts *once*, before batch 1, and hand the same brief to
every spawn. A spawn that re-runs project setup has cost more than it saved, and the handoff
section makes that a rule rather than a hope.

This does **not** stop for the human between batches. It runs to the
end of the plan, or to a halt only the human can clear. A review that will not come clean
escalates (§12) rather than stopping, and a plan that no longer matches the repository is
amended (§14) rather than abandoned. That autonomy is the reason the rules below are strict
rather than advisory.

**Cost shape, so it is not a surprise.** Orchestration and adjudication run here on opus at
medium effort. Each batch costs **one `test-writer` and one `implementer` spawn** on sonnet at
medium effort, plus one or two `reviewer` spawns on sonnet at high effort. A twelve-task plan
needing no refinement is roughly 12 test-writer + 12 implementer + 12–24 reviewer spawns; a
plan needing a refine pass per batch adds one implementer and one reviewer per batch — a fix
pass re-uses the batch's existing RED and never re-writes the test. Prefer a short plan for a
first run.

The RED step is the reason this is affordable rather than merely thorough: a test proven to
fail is a specification the implementer cannot satisfy by accident, which is what stops the
refine loop being where correctness gets discovered.

A batch that reaches the escalation ladder (§12) costs more — a diagnosis spawn, then a fix
spawn per round. That is the price of not stopping, and §12 requires the batch report to name
it rather than letting the bill be the first the human hears of it.

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

Print the batching. Then assemble the warm handoff below — that is the last thing before
batch 1, and it is what every spawn will be handed.

## The warm handoff — established once, handed to every spawn

Everything a spawn would otherwise rediscover, you establish **once, before batch 1**, and
pass verbatim in every `test-writer` and `implementer` prompt for the rest of the run. This is
the section that makes delegation affordable; skipping it turns each batch into a cold project
setup — and with three spawns per batch that cost is now paid three times over.

### Exactly two clean points in a run — and this is the first

Clean rebuilds are not banned; they are **scheduled**, and both of them are yours:

| When | What | Who |
|---|---|---|
| **Once, before batch 1** | establish a trustworthy baseline (below) | you |
| **Once, at the closing gate** | rebuild from scratch and re-run the suite (§15) | you |
| **Everything in between** | strictly incremental, never re-configured | nobody re-configures |

The reason the middle is incremental is cost. The reason the ends are not is **trust**: a run
that never cleans cannot tell you whether the code is correct or whether the cache is lying to
it, and a run that cleans per batch pays minutes a batch for an answer it already had.

**Prefer the build system's own clean mechanism, never `rm -rf`.** `meson setup --wipe <dir>`,
`meson setup --reconfigure <dir>`, `cmake --fresh -S . -B <dir>`, or the project's documented
equivalent. `rm -rf` on a mistyped path is unrecoverable and stays the human's; a scoped
`--wipe` is not the same command and is yours at these two points.

### The baseline, before batch 1

**Find the existing build directory before considering a new one.** A configured build tree is
often hundreds of megabytes and minutes of cross-compilation, and it is already on disk.

But do not trust it blindly — **an inherited build directory has unknown provenance.** It may
be configured for a different branch, a different option set, or a different cross-file, and
every batch and the closing gate would then inherit that. Before batch 1, establish that the
baseline is real:

1. **Check its configuration matches what this plan needs** — the options, the generator, the
   cross-file. `meson configure <dir>` and `cmake -LA -N -B <dir>` print it without building.
   Where it does not match, or where you cannot tell, **clean-configure it once, now.**
2. **Build and run the host suite once, before any spawn.** A baseline that does not build, or
   whose suite is already red, is a **halt** (§10): with a broken baseline you cannot attribute
   any later failure to a batch, and the whole run's evidence becomes uninterpretable.
3. **Print the result** — reused as-is, or clean-configured and why, plus the baseline suite
   result. That line is what every later failure is measured against.

Once that baseline passes, the directory is **frozen for the run**: from here to the closing
gate nothing re-configures it, and no spawn may.

### Finding it

**Find the existing one before considering a new one.** A configured build tree is often
hundreds of megabytes and minutes of cross-compilation, and it is already on disk. Look for
it, in this order:

- an existing configured directory — `<dir>/meson-info/`, `<dir>/CMakeCache.txt`,
  `<dir>/build.ninja`, or a `compile_commands.json` naming its own directory;
- the directory the repository's own docs use — `README.md`, `CONTRIBUTING.md`, or the build
  section of its `CLAUDE.md`;
- only if neither exists: create it, once, with the exact command those docs prescribe.

Where several are configured — a native `build/` beside a cross `build-rpi5/` or a sanitizer
`build-tsan/` — **name the one this plan's verification needs**, and say why in the batching
report. Where the plan's tasks need two (a native build plus a cross build, say), name both
explicitly and label which verification belongs to which. Never leave a spawn to infer it: a
spawn that guesses configures a third one.

**Then state the incremental command, not the setup command.** The brief gives the build and
test invocations that reuse the directory as it stands:

| build system | build | test |
|---|---|---|
| Meson | `meson compile -C <dir>` | `meson test -C <dir>` |
| CMake | `cmake --build <dir>` | `ctest --test-dir <dir>` |
| Cargo / npm / go | the project's own command — these cache in place, no directory to name | likewise |

A repository's README typically documents the **first** build — `meson setup build && meson
compile -C build`. That first line is a one-time cost that has already been paid, and a spawn
that copies the recipe verbatim pays it again. The brief exists so the spawn never reads that
line as an instruction.

### Forbidden to every spawn — always — and to you between the two clean points

Re-running project setup mid-run is not a fix for a confusing build state — it is the most
expensive thing in the run, and it discards a cache the rest of the plan depends on. The
following are **never** a spawn's, in any mode, and not yours either once the baseline has
passed and until the closing gate:

- **no re-configuring a configured directory** — no `meson setup` on an existing one, no
  `--wipe`, no `--reconfigure`, no `cmake` fresh configure, no `--fresh`;
- **no deleting or recreating a build directory** — `rm -rf <dir>` is unrecoverable on a
  mistyped path and stays the human's under §17, whatever the build system and whichever of
  the two clean points you are at;
- **no second directory** under a new name because the first looked wrong;
- **no changing the configured options** (`-Daxelera=`, `-DCMAKE_BUILD_TYPE=`, a different
  `--cross-file`) — that reconfigures the tree for every later batch. A task that genuinely
  needs different options needs a *second named directory in the brief*, decided at the
  baseline by you, not improvised mid-batch.

**Put the prohibition in the brief without the exception.** A spawn never needs to know that
the orchestrator cleans at two points; it needs to know that *it* never does. Telling a spawn
about a sanctioned clean is how a spawn talks itself into one.

If a spawn reports that the build directory is genuinely unusable — a toolchain change, a
corrupt cache, options that contradict the task — that is **not** for it to repair. It reports
and stops, and you decide between three moves, in this order:

1. **Amend the brief and re-run the batch**, where the spawn simply used the wrong directory
   or the wrong command.
2. **Bring the closing gate's clean rebuild forward**, where the tree really is corrupt. This
   spends the run's second clean point early: do it once, say so in the batch report, and note
   that the gate will clean again — the two are separately justified, and skipping the gate's
   clean because you cleaned mid-run would leave every batch after this one unproven.
3. **Halt**, where cleaning would not help — a moved toolchain, an option set the plan and the
   repository disagree about. Put the exact command in the report for the human.

### What the brief contains

Assemble it once and reuse it. Every `implementer` prompt carries, verbatim:

1. **the plan path**, and the specific tasks or findings this spawn owns;
2. **the build directory or directories**, and the incremental build and test commands above.
   Name the **host test command** explicitly and separately (`meson test -C <dir>`,
   `ctest --test-dir <dir>`, or the project's own) — every spawn runs it, and a `test-writer`
   that has to go looking for it is a `test-writer` that may pick the cross-compiled target
   suite instead;
3. **the project facts you already established** — where the source lives, which docs are
   authoritative for conventions, the guideline pages that apply. Enough that the spawn need
   not go looking; not so much that it stops reading the plan;
4. **the files earlier batches already touched**, so it leaves them alone (§7's note);
5. **the setup prohibitions above**, stated rather than referenced — the spawn does not have
   this file.

Re-derive nothing per batch. When a batch teaches you a project fact worth having — a build
target that is slow, a test that needs a flag, a directory the plan misnames — add it to the
brief so the next spawn starts with it. The brief only grows.

**Print the brief once, when you assemble it**, so the human can see what every spawn will be
told. Then print only what changed.

## 3. The per-batch loop

```
fresh test-writer  (the brief + this batch's behaviours; writes the tests, proves RED)
  ├─ RED not demonstrated (test passes already) ───────► HALT (§10) — test or task is wrong
  └─ returns the failing output and the test paths
fresh implementer  (GREEN mode: the brief + the demonstrated RED; it verifies, it reports)
  ├─ it reports a plan/repository discrepancy ─────────► AMEND the plan (§14), re-spawn
  ├─ it reports an unexplained verification failure ───► ESCALATE (§12)
  ├─ it reports the build directory unusable ──────────► fix the brief, or halt (warm handoff)
  └─ take the changed-file list from BOTH reports — that is the review scope (§7)
fresh reviewer      ┐  spawned in ONE message, both read-only
conventions reviewer┘  (only where the project defines one, and it applies — §6)
adjudicate every finding
  ├─ accepted findings? → fresh implementer in FIX mode → fresh re-review
  │    └─ 2 rounds and still not clean ────────────────► ESCALATE (§12), budget resets
  │         └─ ladder used up, two rounds no progress ─► STOP and report (§13)
commit the batch  (only with --commit; never before review passes; yours alone)
emit batch report, continue without waiting
```

Every spawn on that diagram is **fresh** and carries **the same warm handoff brief**. Fresh is
what keeps the review independent and stops a fix pass inheriting the reasoning that failed;
the shared brief is what stops fresh meaning cold.

**Every batch starts with a demonstrated RED.** Testing is mandatory on this project, tests
run natively on this host, and the order is not negotiable: a fresh `test-writer` writes the
batch's tests and shows them **fail** before any production code exists. Check its report
before spawning the implementer:

- **RED demonstrated** — pass the failing output and the test paths to the `implementer` in
  GREEN mode, and proceed;
- **the test passed before the code existed** — that is `RED_NOT_DEMONSTRATED`, and it is a
  **halt** (§10). Either the behaviour is already implemented, which is a plan discrepancy for
  §14, or the test does not test what it claims. Both need a decision, and neither is cleared
  by trying again;
- **the behaviour is not testable on this host** — do not accept it at face value. The
  `test-writer` is required to look for a seam first; if it reports that none exists without a
  design change, that is a §10 halt, because changing the design is yours to decide, not mine.
  Never let an on-target or manual check stand in for the host test;
- **no harness exists at all** — introducing a test framework is a new dependency, so §10.

**Then the batch is self-verified before it is reviewed.** The `implementer` turns RED into
GREEN, re-reads the task against what it changed, and returns the real command output — that
is its assignment, not an optional extra. Check its report for that evidence *before* spawning
the reviewers:

- **evidence present, checks pass** — proceed to review;
- **evidence present, a check fails** — do not review a batch that does not build. Route it:
  a failure the implementer explained goes to a fix spawn, one nobody explained goes to §12;
- **a deferred check** (target hardware, a device, credentials you do not hold) — proceed to
  review and carry it to §11, naming the command and the machine;
- **no evidence, or a bare claim that it passed** — that is a defective report. Re-spawn for
  the verification rather than reviewing on trust, and say in the batch report that you did.

Reviewing an unverified batch spends a reviewer on findings a build would have caught, and the
review that matters — is this code right? — gets buried under them. This is also why the loop
does not need a human checkpoint between batches: every batch is specified by a test that was
proven to fail, implemented by an agent that did not write that test, and reviewed by a third
that wrote neither. That is strictly more than a glance from you at a checkpoint would give it.

The three arrows that used to read HALT are what §12–§14 exist for. A review that will not
come clean and a plan that contradicts the repository are both **work this loop can still
do**; treating either as a stop wastes a run that was one changed approach away from
finishing. What ends the run is §13's ledger — the loop having demonstrably run out of moves
— not a counter reaching three. The halts left in §10 are the ones no amount of agent work
can resolve.

## 4. A fresh agent for every implement, fix, and review

**Every spawn is new, with no memory of the last one.** That holds in all three roles and for
a different reason in each:

- **implement** — a fresh `implementer` per batch, on sonnet at medium effort. It gets the
  brief, so fresh costs almost nothing.
- **fix** — a fresh `implementer` in fix mode, never the one whose work drew the findings. An
  agent asked to fix its own code argues with the finding as often as it addresses it.
- **review** — a fresh `reviewer`, and never the reviewer from the previous refine round: one
  that has already approved its own reasoning is not an independent second look either.

**You write no production code.** Not a batch, not a fix pass, not a one-line change you could
make faster yourself. The moment you edit source, you become the author of code a `reviewer`
you spawned is about to review on your behalf, and the independence the whole loop rests on is
gone — quietly, with nothing in the report to show it. Your two hands on the tree are the plan
file's checkboxes (§17) and `git add`/`git commit` under `--commit` (§9).

The temptation is strongest exactly where it is most expensive: a finding that looks like a
typo, on the third refine round, at the end of a long batch. Spawn the fix.

## 5. Spawn the reviewers in one message

They are read-only, so they cannot conflict and they should run concurrently. Spawn both in a
single message.

**Never overlap a writing spawn with a reading one.** The `implementer` must have reported and
stopped before the reviewers go out, and no fix spawn starts while a review of those same files
is still in flight. One writer at a time, and never a writer beside a reader: a reviewer that
reads a file mid-edit reports findings against a state that no longer exists, and two
implementers in the same tree corrupt each other's diff.

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
instead: the batch's task text, **the changed-file list from the implementer's report**, and a
note naming the files earlier batches already touched whose changes are reviewed and out of
scope. A finding against an already-reviewed file is answered with that note, not a fix.

That list comes out of the `implementer`'s **Files changed** section — it is required to report
one, and it is the authority on its own diff. Do not reconstruct it from `git status`: that
picks up anything the human left in the tree and anything an earlier batch touched, and a
review scoped to it will spend its findings outside the batch. Carry the list forward across
fix passes too — a fix spawn's report adds to the batch's list, it does not replace it.

If a spawn returns without a usable **Files changed** section, that is a defective report, not
a licence to guess: re-spawn it for the list, or say in the batch report that the scope is
uncertain and why. Never ship a review scope you invented.

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
- **RED cannot be demonstrated** — the batch's test passes before the production change
  exists (`RED_NOT_DEMONSTRATED`). Either the work is already present, or the test is not
  testing what it claims; both need you, and a retry settles neither.
- **The behaviour is not testable on this host without a design change.** Tests are mandatory
  and host-native, so an untestable behaviour is a design question, and the design is yours.
  Report the seam the `test-writer` said it would need. Never resolve this by skipping the
  test or by substituting an on-target check.
- **No test harness exists** and the batch would need one introduced — that is a new
  dependency, and the bullet above applies.
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
check** and continue, naming the exact command and the machine it belongs on.

**A test is never one of these.** Tests are host-native and mandatory, so the suite is always
runnable from here. A "deferred test" is a contradiction: either it runs on this host, or the
code needs a seam so it can (§10). Deferral covers reading a real sensor, driving a peripheral,
measuring true timing — and such a check is always *additional* to a host test of the same
logic, never a replacement for one. Where the
project batches such checks into one pass at the end of a plan series, follow that.

## 12. The escalation ladder — what a reached bound does instead of stopping

A refine loop gets **2 rounds** of the straightforward thing: a fresh `implementer` in fix
mode on the accepted findings, then a fresh re-review. Reaching the second without a clean
review ends *that approach*, not the batch. Take the next unused rung below, then continue with
a fresh budget of 2.

The budget is 2 rather than 3 because each round costs a spawn, and because a second identical
attempt is already weak evidence. Two fix spawns having failed on the same findings says the
*assignment* is likely wrong rather than the execution — which is what rung 2 exists to test.
Buying a third attempt buys another cold pass at a task that may not be satisfiable.

**Every escalation spawn gets the warm handoff brief too**, plus the surviving findings and
what the previous rounds already tried. A diagnosis spawn that begins by re-configuring the
build directory has spent the escalation on the thing the brief was written to prevent.

1. **Diagnose before fixing again.** Spawn a fresh `debugger` for a failure, or a fresh
   `verifier` for a check whose output nobody has explained, with the surviving findings and
   the exact command. Both are diagnostic: they establish the root cause, they do not implement
   the batch — the fix that follows is a fresh `implementer` in fix mode, carrying the
   diagnosis. Trying the same fix a third time is not an escalation, it is the same rung again,
   and two identical attempts having failed is evidence the assignment is wrong rather than the
   execution.
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
- the batch's changed-file list (§7) grew — a spawn actually edited something;
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

**First, clean-rebuild once — this is the run's second and last clean point.** Before spawning
the gate, wipe and re-configure the build directory yourself (`meson setup --wipe <dir>` or the
project's documented equivalent, never `rm -rf`), rebuild, and run the full host suite.

This is not ceremony. Every batch since the baseline was incremental, and incremental state
hides exactly the defects that matter at a completion claim:

- a header a translation unit uses but never includes, compiling only because a stale object
  or precompiled header still carries it;
- a file removed from the build definition but still linked from a previous object;
- generated code that was never regenerated after its generator or input changed;
- a test that passes only against a stale fixture, binary, or copied resource;
- an option changed mid-run whose effect was never actually rebuilt into everything.

Each of those makes a plan look finished and fails on the next clean checkout — which is to
say, on the human's machine, after the run reported success.

**A clean rebuild that fails is a real finding, not an environment problem.** Route it like any
other: a failure you can explain goes to a fix spawn, one nobody can explain goes to §12. Never
"resolve" it by going back to the incremental tree — that tree is exactly what was hiding it.

Then spawn a fresh `verifier` for the evidence gate and a fresh `reviewer` with whole-plan
scope, both handed the clean-rebuild output. Claim completion only when both come back clean.

Both get the warm handoff brief, so the gate does not begin by rediscovering the build — and
the brief now says the tree was just cleaned, so no gate spawn cleans it again.

If either does not come back clean, adjudicate its findings as in §8 and send them to a fresh
`implementer` in fix mode, then re-run the gate. The gate gets its own budget of **2 rounds**,
counted separately from any batch's, plus its own copy of §12's two-rung ladder and §13's
ledger: a reached bound here escalates exactly as it does inside a batch, and a gate finding
that turns out to be a plan defect amends the plan through §14 like any other. A gate fix is a
spawn like every other fix in this command — §4 has no exception for the last one.

The gate stops the run only on §13's terms — the ladder used up and two consecutive
unproductive rounds. By the time the gate runs, nearly all of the run's work is already spent,
which is the argument for escalating here rather than stopping on a count. It is equally the
argument for stopping *honestly* when there is nothing left to try, instead of circling on the
most expensive part of the run: report the unresolved findings, the evidence gathered, every
batch that did pass, and the ladder rungs already taken, and make no further change.

## 16. The final report

- the plan path, and the batching used;
- **the warm handoff brief as finally stated** — the build directory or directories, the
  incremental commands, and anything added to it mid-run. It is what every spawn was told, so
  it is the first thing to check when a batch went wrong;
- batches completed, and the files changed by each;
- **the spawn count** — test-writers, implementers, reviewers, and any diagnostic spawns —
  plus any spawn that reported configuring or re-configuring a build directory. That last one
  must be **zero**, always: cleaning is the orchestrator's at two scheduled points and no
  spawn's ever. A non-zero count names the spawn and why, because it is the cost this shape
  exists to avoid;
- **the two clean points** — whether the baseline was reused or clean-configured and why, the
  baseline suite result, and the clean-rebuild result at the gate. A run whose incremental
  batches passed but whose clean rebuild failed is the single most important line in this
  report;
- verification evidence — real command output, not claims;
- **the RED-to-GREEN record per batch** — the test files added, the failing output that proved
  RED, and the passing output after. This is the evidence that the loop specified before it
  built, and it is the first thing to check when a batch looks wrong;
- **any batch where a test was changed rather than added**, with the reason. This should be
  empty; a non-empty entry is the one thing in this report that most needs your eyes;
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
- **Write no production code and no tests.** Every batch is a fresh `test-writer` then a
  fresh `implementer`; every fix pass is a fresh `implementer` (§4). Do not stand a
  general-purpose agent in for either — each pins the model, the effort and the discipline its
  phase needs, and a general-purpose agent pins none of them. The agents this command spawns
  are: `test-writer` then `implementer` every batch, `implementer` every fix, `reviewer` and
  any project conventions reviewer every review, and `debugger`, `verifier` and `planner` at
  the three points §12, §15 and §14 name.
- **Never weaken, skip, disable, or delete a test to get a batch through.** Not yours to do
  and not a fix to accept from a spawn: a review finding whose fix is "loosen the assertion"
  is rejected, and a spawn that did it is a defect to report. If a test is genuinely wrong, it
  is a plan discrepancy for §14.
- **No spawn ever re-runs project setup — and you do it at exactly two points.** The warm
  handoff names the build directory and the incremental commands. Re-configuring, wiping,
  deleting or duplicating that directory is forbidden to **every spawn, in every mode, always**;
  it is yours alone, and only at the baseline before batch 1 and the clean rebuild at the
  closing gate (§15). Between those two points nothing cleans, including you.
- **Use the build system's clean mechanism, not `rm -rf`.** `meson setup --wipe`,
  `meson setup --reconfigure`, `cmake --fresh` are scoped and yours at those two points.
  `rm -rf <build dir>` is not the same command — a mistyped path is unrecoverable — and stays
  the human's: put it in the report rather than running it.

## Why running every phase unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because **each phase belongs on a
deliberately chosen model**, and rolling forward inside one session would run the next phase
on whatever model the session happened to be on. That is the property the boundary protects —
not the ceremony of a subagent.

Every phase here runs on a model chosen for it, in its own frontmatter. Orchestration and
adjudication: `opus` at `medium`, pinned at the top of this file, which is what you are running
on right now. Implementation: `sonnet` at `medium`, pinned in `implementer.md`. Review: `sonnet`
at `high`, pinned in `reviewer.md`. Diagnosis, verification and plan amendment likewise, in
`debugger.md`, `verifier.md` and `planner.md`. Nothing in this command inherits an accidental
model, and the three phases that used to share one now do not.

**Delegation is what buys that, and the warm handoff is what makes it affordable.** The cost of
a per-batch spawn was never the model — it was the cold start: re-configuring a 500 MB build
tree, re-reading the docs, re-deriving the layout, once per batch and again per fix pass. The
handoff section moves all of that to once per run. What is left per spawn is reading the plan
and writing the batch, which is the work.

The rule that has not moved: **do not roll from this command into the next phase yourself.**
When the plan is done, this command stops and reports. What happens next — another plan,
a review of the whole change, a commit — is the human's to start.

## Related entry points

There are three commands in total. `/create-plan` produces the plan file this one consumes,
and `/debug` handles a failure on its own. Everything else that used to be a command is now
either a phase inside these two or a skill you can invoke by name.

Plan file: $ARGUMENTS
