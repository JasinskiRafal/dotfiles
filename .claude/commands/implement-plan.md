---
description: Drive one plan file to done — implement, review at most twice, fix, next batch, closing gate — stopping at the end, or only where it needs you
argument-hint: [--commit] <plan file, e.g. plans/007-uart-dma.md>
model: opus
effort: medium
---
Drive the plan file below from its first task to its last. **You do the writing yourself, in
this context.** You write each batch's tests, you write the production change, you fix what
review finds, you debug what fails, you amend the plan when it drifts — all inline, on the
model this file pins. What you **delegate is reading**: every review, every verification, every
audit is a fresh read-only spawn, and they go out concurrently.

## The split: writers inline, readers spawned

**One rule decides where work runs.** A phase that *changes files* runs here, in the main
context. A phase that only *reads* runs as a spawned agent, in parallel with its siblings.

**Why writing is inline.** A cold spawn's expensive half was never the code — it was
re-deriving the build directory, the layout, and the conventions, once per test-writer, once
per implementer, and again per fix pass. This context already holds all of it: you read the
plan in §1, you established the baseline yourself before batch 1, and you have every earlier
batch's diff in view. Handing that to a fresh agent means writing a brief to reconstruct what
you already know, waiting for it to re-read the plan, and getting back a summary you then have
to reconcile against the tree. For work you can simply do, that is pure overhead.

**Why reading is spawned.** Not cost — you *cannot* do it. A reviewer that also wrote the code
is not an independent second look, it is the author re-reading their own reasoning. The
independence this loop rests on is precisely that **the reader never wrote what it reads, and
cannot see why you wrote it that way.** A fresh `reviewer` gets the diff and the task text, not
your intent, which is what makes its verdict worth having. That property is unaffected by who
holds the pen — it depends only on the reviewer being separate, and it is why review is the one
thing here that is never inline.

**What this gives up, and what replaces it.** Previously a `test-writer` specified the batch
and a separate `implementer` satisfied it, so neither could tune the test to the code. Now both
are yours, and that pressure is real: a test authored beside its implementation tends to assert
what the code does rather than what the behaviour should be. Three things hold the line in its
place, and none is optional:

1. **RED is demonstrated and recorded before any production edit exists** (§3). The failing
   output goes in the batch report verbatim. A test that never failed is not evidence, and the
   record is what makes that checkable after the fact.
2. **The reviewer is told to audit the test, not just the code** (§7) — does this test assert
   the behaviour the task describes, or does it assert the implementation that happens to be
   there? That is now one of its named jobs.
3. **The RED-to-GREEN record per batch is a required section of the final report** (§16), and
   any batch where a test was *changed* rather than added is called out by itself.

**Testing is mandatory here and tests run natively on this host.** The RED-before-GREEN order
is a hard rule, not a preference — see §3 and the halts in §10. A batch without a demonstrated
failing test is not a batch this loop will implement.

**Cost shape, so it is not a surprise.** Everything you write runs here on opus at medium
effort — more expensive per token than the sonnet spawns it replaces, and with no cold start,
no brief to assemble, and no round-trip per batch. Each batch costs **one or two `reviewer`
spawns** on sonnet at high effort, issued in a single message. **A batch is reviewed at most
twice** — the review after implementation, and one re-review after one fix pass (§12). A
twelve-task plan needing no refinement is roughly 12–24 reviewer spawns plus the closing gate; a
plan needing a fix pass per batch adds one reviewer spawn per batch, and a fix pass re-uses the
batch's existing RED rather than re-writing the test.

The RED step is what makes this affordable rather than merely thorough: a test proven to fail is
a specification you cannot satisfy by accident, which is what stops the refine loop being where
correctness gets discovered.

This does **not** stop for the human between batches. It runs to the end of the plan, or to a
halt only the human can clear. A review that will not come clean escalates (§12) rather than
stopping, and a plan that no longer matches the repository is amended (§14) rather than
abandoned. That autonomy is the reason the rules below are strict rather than advisory.

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
**Read it in full, not just the first task.** The Goal, Context, Constraints and Out of scope
sections are what tell you whether a task still makes sense, and they are where a plan states
the thing that makes the obvious implementation wrong.

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
invent a batching from prose — and do not stop either. Take it to §14 for a structural
amendment: reshape the work **already written in the file** into `### Task N` headings and
change nothing else. If the file cannot be divided without inventing work that is not in it,
that is a **halt**: the split is a design decision, and it is the human's.

Print the batching. Then read the proportionality table below and **state the tier**, because
it decides how many reviewers each batch gets. Then establish the project brief.

## Proportionality — review depth scales with the plan, the safety floor does not

A one-task plan and a twenty-task plan do not carry the same risk per batch, and charging them
the same review depth is wrong in both directions: it makes small work slow and leaves large
work under-reviewed. **Tier on the task count from §2** — mechanical, printed with the batching,
never a judgement call mid-run.

| Tier | Tasks | Reviewers per batch | Closing gate (§15) |
|---|---|---|---|
| **XS** | 1–2 | 1 correctness `reviewer` | clean rebuild + `verifier`; **no whole-plan `reviewer`** |
| **S** | 3–6 | 1 correctness `reviewer` + conventions reviewer where the batch falls in its remit | clean rebuild + `verifier` + whole-plan `reviewer` |
| **M** | 7–12 | as S, and the conventions reviewer runs on every batch that touches source | as S |
| **L** | 13+ | as M, **plus a second `reviewer` on an interaction lens** | as S, and the whole-plan `reviewer` is told to look for cross-batch interaction first |

Every reviewer a tier grants for the same batch goes out **in one message** (§5). The tier sets
how many opinions the batch gets, not how long it waits for them.

**Why the gate loses its whole-plan reviewer at XS.** With one or two batches, "whole-plan
scope" is the same diff the batch reviewer just read, with the same lens. That is not a second
opinion, it is the same opinion twice. The `verifier` and the clean rebuild stay at every tier:
they answer a different question — does the evidence exist, and does it survive a clean tree —
and neither is redundant with a review.

**Why L adds a lens rather than a round.** In a long plan the risk is not that a batch is wrong
in isolation — the batch reviewer catches that at every tier — it is that batch 9 quietly breaks
what batch 3 built. Give the second `reviewer` exactly that brief: the current batch against
the *already-reviewed* work of earlier batches, using the earlier-batch file note from §7. Do
not give it the same correctness brief as the first; two agents with one brief produce one
opinion and two bills.

**What never scales, at any tier.** These are not depth, they are correctness, and a small task
does not get a cheaper version of them:

- RED before GREEN, and tests on the host. A one-line change still needs the test that specifies
  it — that is what the test *is for*, and it is the cheapest check in the run.
- One independent `reviewer` per batch. Independence is the property the whole loop rests on;
  one is the floor, not a tier setting.
- The discrepancy rule, the plan-amendment path, and every §10 halt.
- The baseline before batch 1 and the clean rebuild at the gate.
- Read-only git, and the `--commit` carve-out's conditions.

**Do not confuse a bound with a check.** The two-review cap, §12's post-review moves, and the
progress ledger are **lazy** — they cost nothing on a batch whose review comes back clean, and
they are not overhead to be tuned away for small tasks. Tightening them would only make failing
batches fail sooner, not passing batches finish faster. What costs on the happy path is the
eager set: the reviewer spawns above and the two builds. Tier those; leave the bounds alone.

**State the tier and what it bought.** Print it with the batching, and record in §16 which
reviewers ran per batch. A tier chosen silently is a tier nobody can evaluate.

## The project brief — established once, before batch 1

Everything about how this project builds and tests, you establish **once**, here, and then hold
for the rest of the run. You are the one doing the work, so this is not a document you hand
off — it is the state you stop re-deriving. Two things still consume it as a written brief:
**every read-only spawn** gets the parts it needs (§5), and §16 reports it as finally stated.

### Exactly two clean points in a run

Clean rebuilds are not banned; they are **scheduled**, and both of them are yours:

| When | What |
|---|---|
| **Once, before batch 1** | establish a trustworthy baseline (below) |
| **Once, at the closing gate** | rebuild from scratch and re-run the suite (§15) |
| **Everything in between** | strictly incremental, never re-configured |

The reason the middle is incremental is cost. The reason the ends are not is **trust**: a run
that never cleans cannot tell you whether the code is correct or whether the cache is lying to
it, and a run that cleans per batch pays minutes a batch for an answer it already had.

**Prefer the build system's own clean mechanism, never `rm -rf`.** `meson setup --wipe <dir>`,
`meson setup --reconfigure <dir>`, `cmake --fresh -S . -B <dir>`, or the project's documented
equivalent. `rm -rf` on a mistyped path is unrecoverable and stays the human's; a scoped
`--wipe` is not the same command and is yours at these two points.

### The baseline, before batch 1

**Find the existing build directory before considering a new one.** A configured build tree is
often hundreds of megabytes and minutes of cross-compilation, and it is already on disk. Look
for it, in this order:

- an existing configured directory — `<dir>/meson-info/`, `<dir>/CMakeCache.txt`,
  `<dir>/build.ninja`, or a `compile_commands.json` naming its own directory;
- the directory the repository's own docs use — `README.md`, `CONTRIBUTING.md`, or the build
  section of its `CLAUDE.md`;
- only if neither exists: create it, once, with the exact command those docs prescribe.

But do not trust an inherited one blindly — **it has unknown provenance.** It may be configured
for a different branch, a different option set, or a different cross-file. Before batch 1:

1. **Check its configuration matches what this plan needs** — the options, the generator, the
   cross-file. `meson configure <dir>` and `cmake -LA -N -B <dir>` print it without building.
   Where it does not match, or where you cannot tell, **clean-configure it once, now.**
2. **Build and run the host suite once.** A baseline that does not build, or whose suite is
   already red, is a **halt** (§10): with a broken baseline you cannot attribute any later
   failure to a batch, and the whole run's evidence becomes uninterpretable.
3. **Print the result** — reused as-is, or clean-configured and why, plus the baseline suite
   result. That line is what every later failure is measured against.

Once that baseline passes, the directory is **frozen for the run**: from here to the closing
gate nothing re-configures it.

Where several are configured — a native `build/` beside a cross `build-rpi5/` or a sanitizer
`build-tsan/` — **name the one this plan's verification needs**, and say why in the batching
report. Where the plan's tasks need two, name both explicitly and label which verification
belongs to which.

### State the incremental command, not the setup command

| build system | build | test |
|---|---|---|
| Meson | `meson compile -C <dir>` | `meson test -C <dir>` |
| CMake | `cmake --build <dir>` | `ctest --test-dir <dir>` |
| Cargo / npm / go | the project's own command — these cache in place, no directory to name | likewise |

A repository's README typically documents the **first** build — `meson setup build && meson
compile -C build`. That first line is a one-time cost that has already been paid. Name the
**host test command** explicitly and separately (`meson test -C <dir>`,
`ctest --test-dir <dir>`, or the project's own): it is the command every RED and every GREEN is
proven with, and picking the cross-compiled target suite by accident invalidates both.

### Between the two clean points, nothing cleans — including you

Re-running project setup mid-run is not a fix for a confusing build state — it is the most
expensive thing in the run, and it discards a cache the rest of the plan depends on. Once the
baseline has passed and until the closing gate:

- **no re-configuring a configured directory** — no `meson setup` on an existing one, no
  `--wipe`, no `--reconfigure`, no `cmake` fresh configure, no `--fresh`;
- **no deleting or recreating a build directory** — `rm -rf <dir>` is unrecoverable on a
  mistyped path and stays the human's under §17, whichever of the two clean points you are at;
- **no second directory** under a new name because the first looked wrong;
- **no changing the configured options** (`-Daxelera=`, `-DCMAKE_BUILD_TYPE=`, a different
  `--cross-file`) — that reconfigures the tree for every later batch. A task that genuinely
  needs different options needs a *second named directory*, decided at the baseline, not
  improvised mid-batch.

**No spawn ever cleans, in any mode.** Read-only spawns have no business configuring a build
tree, and the brief they get says so without mentioning that you clean at two scheduled points
— telling a spawn about a sanctioned clean is how a spawn talks itself into one.

Where the build directory turns out to be genuinely unusable — a toolchain change, a corrupt
cache, options that contradict the task — you have three moves, in this order:

1. **Re-check the command**, where you simply used the wrong directory or invocation.
2. **Bring the closing gate's clean rebuild forward**, where the tree really is corrupt. This
   spends the run's second clean point early: do it once, say so in the batch report, and note
   that the gate will clean again — the two are separately justified, and skipping the gate's
   clean because you cleaned mid-run would leave every batch after this one unproven.
3. **Halt**, where cleaning would not help — a moved toolchain, an option set the plan and the
   repository disagree about. Put the exact command in the report for the human.

**Print the brief once, when you establish it**, so the human can see the directory, the
commands, and the project facts the run will use. Then print only what changed. When a batch
teaches you a fact worth having — a slow target, a test needing a flag, a directory the plan
misnames — add it. The brief only grows.

## 3. The per-batch loop

```
YOU write the batch's tests, then run them and show them FAIL
  ├─ RED not demonstrated (test passes already) ───────► HALT (§10) — test or task is wrong
  └─ record the failing output verbatim — it goes in the batch report
YOU make the smallest production change that turns RED into GREEN
YOU run the task's verification, the new test, and the whole host suite
  ├─ a plan/repository discrepancy ────────────────────► AMEND the plan (§14), re-run the batch
  ├─ an unexplained verification failure ──────────────► ESCALATE (§12)
  ├─ the build directory is unusable ──────────────────► the three moves above, or halt
  └─ assemble the changed-file list — that is the review scope (§7)
STOP EDITING, then spawn the readers in ONE message (§5)
  fresh reviewer      ┐
  conventions reviewer┘  (only where the project defines one, and it applies — §6)
adjudicate every finding (§8)
  ├─ accepted findings? → YOU fix them → ONE fresh re-review (review 2 of 2)
  │    └─ still not clean ─────────────────────────────► §12 — and there is no review 3
  │         ├─ the task is the defect ──► AMEND (§14), re-run the batch — once only
  │         └─ nothing clears it ───────► STOP and report (§13)
commit the batch  (only with --commit; never before review passes; yours alone)
emit batch report, continue without waiting
```

### RED first, and it is not a formality

**Every batch starts with a demonstrated RED.** Write the test for exactly one behaviour of
this batch, run the narrowest relevant host command, and show it fail. Follow
`~/.claude/skills/test-driven-development/SKILL.md` — it is the discipline this project runs
on, not background reading.

A successful RED **fails for the expected missing behaviour** — not because of a syntax error,
a missing fixture, an environment or compilation problem, or an unrelated defect. Read the
failure and say why it is the right one.

- **Use the project's existing harness and conventions** — read them rather than guessing.
- **Do not implement or alter production functionality while writing the test.** The order is
  the point.
- **Do not weaken, delete, or "adjust" an existing assertion**, and preserve existing tests.
- **The test runs natively on this host** — the project's own runner, in one command a human
  can re-run. Never cross-compiled to a target, flashed to a device, or run inside a
  container, emulator, or simulator.

Then check what you got:

- **RED demonstrated** — record the failing output and the test paths, and proceed to GREEN;
- **the test passed before the code existed** — that is `RED_NOT_DEMONSTRATED`, and it is a
  **halt** (§10). Either the behaviour is already implemented, which is a plan discrepancy for
  §14, or the test does not test what it claims. Both need a decision, and neither is cleared
  by trying again. **Do not manufacture a failure** to get past it;
- **the behaviour looks untestable on this host** — do not accept that at face value.
  Hardware-coupled code is the normal case here, and the normal answer is a **seam**: the logic
  behind an interface you can test natively, with the register-poking part left thin enough
  that its correctness is obvious. Look for that seam and propose it. Only when none exists
  without a design change do you stop — that is a §10 halt, because changing the design is the
  human's. Never let an on-target or manual check stand in for the host test;
- **no harness exists at all** — introducing a test framework is a new dependency, so §10.

### GREEN, and nothing more

Make the **smallest correct production change** that turns that RED into GREEN. No unrelated
refactoring, no scope expansion, no speculative abstraction, no "while I was in here". If the
plan did not ask for it, it is not in this diff.

**Never weaken, skip, or edit a test to obtain a pass** — not the one you just wrote, not an
existing one that now fails. A test edited to go green is worse than no test, because it also
destroys the evidence that anything was wrong. If a test looks wrong, that is a §14 discrepancy.

### Then verify before you spawn a reviewer

Running the verification is part of the batch, not a courtesy. For **every** task in the batch:

1. **Run the new test on the host and show it GREEN** — the same host command that proved it
   RED. If RED was proven on the host, GREEN is proven the same way or it is not the same test.
2. **Run the whole host suite, not only the new test.** A change that turns one test green
   while breaking another is not done. Never "fix" a newly failing test by editing it.
3. **Run the task's own verification step**, as the plan writes it. Where the plan's step
   cannot run as written, that is a §14 discrepancy, not a step to skip.
4. **Re-read the task text against what you actually changed.** Does the diff deliver the
   behaviour the task describes — all of it, and nothing beyond it? This catches the most
   expensive class of defect: a batch that builds clean and implements the wrong thing. A green
   build is not evidence of a correct one.
5. **Check the Constraints and Out of scope sections** again, now that the change exists. A
   constraint is easiest to violate while satisfying the task.
6. **Capture the real output** — the command and what it printed. Not "tests pass".

**Where verification fails and you can explain it, fix it and re-run** — that is inside the
batch. Where it fails for a reason you cannot explain, do not pile on fixes to see what sticks:
two speculative fixes on an unexplained failure is how a small defect becomes an unreviewable
diff. Take it to §12. Where a check needs a resource you cannot reach — target hardware, a
device, credentials you do not hold — name the exact command and the machine, mark it a
**deferred check** (§11), and carry it forward.

**Do not review a batch that does not build.** Reviewing an unverified batch spends a reviewer
on findings a build would have caught, and the review that matters — is this code right? — gets
buried under them.

### Discrepancies are reported and amended, never quietly reconciled

A task that is ambiguous, that contradicts what the code actually does, or whose work is
**already present** means the plan may be stale — most often because the human changed
something after it was written. Do not implement around it and do not redo work that is already
there. Take it to §14, amend inside that section's boundary, and report the amendment loudly.
An unattended loop's safety rests on this call being made honestly rather than pressed through.

This is also why the loop does not need a human checkpoint between batches: every batch is
specified by a test that was proven to fail, verified against its own task before review, and
then judged by a reviewer that did not write it and cannot see why you wrote it that way. That
is strictly more than a glance from you at a checkpoint would give it.

## 4. What is yours, and what is never yours

**Yours, inline:** the batch's tests, the production change, every fix pass, diagnosis when a
failure needs it (§12), plan amendments inside §14's boundary, the plan file's checkboxes, and
`git add`/`git commit` under `--commit` (§9).

**Never yours:** the review. Not a quick self-check in place of it, not "the diff is small
enough", not on the third refine round when the finding looks like a typo. The moment you judge
your own batch, the independence the whole loop rests on is gone — quietly, with nothing in the
report to show it. Spawn the reviewer.

**Do not stand a general-purpose agent in for a reviewer.** `reviewer`, `verifier` and any
project conventions reviewer each pin the model, the effort and the lens their phase needs; a
general-purpose agent pins none of them.

## 5. Spawn the readers in one message — and stop editing first

Every read-only spawn a step needs goes out **in a single message**, so they run concurrently.
They cannot conflict with each other, and the second costs no wall-clock. This applies to the
batch reviewers (§3), to the closing gate's `verifier` and whole-plan `reviewer` (§15), and to
any diagnostic reader in §12.

**Never edit a file while a read-only spawn is in flight.** This is the one hazard inlining the
writers introduces, and it is easy to trip: spawns run while you keep working, so nothing stops
you starting the next batch — or a fix — over files a reviewer is still reading. A reviewer that
reads a file mid-edit reports findings against a state that no longer exists, and you then spend
a refine round on a phantom.

So the sequence is strict: **finish writing, verify, assemble the changed-file list, then
spawn — and touch nothing until every reviewer of that batch has reported.** One writer at a
time, and never a writer beside a reader.

## 6. The second review angle is conditional

Some repositories define their own conventions reviewer — a project-level
`.claude/agents/guidelines-reviewer.md` or similar — that audits a diff against that
project's written coding rules. Check whether one exists before batch 1 and say what you
found.

- **No such agent** — spawn the correctness `reviewer` alone, every batch, and say so once.
- **It exists** — spawn it beside `reviewer` in the same message, but only when the batch's
  changed-file list actually falls under its remit (typically source files, not markdown,
  compose files, or shell scripts). When it does not apply, record in the batch report that the
  pass was skipped and why. Inventing a rule ID for a file the rules do not govern is a defect,
  not thoroughness.

## 7. Scope each review explicitly — and give it the test to audit

`git diff` shows the whole working tree against `HEAD`, so by the third batch it contains
the first two. Narrowing it with git is forbidden. Give every reviewer **four** things instead:

1. **the batch's task text**, verbatim from the plan;
2. **the changed-file list** you assembled in §3 — production changes listed separately from
   plan-file checkbox edits;
3. **a note naming the files earlier batches already touched** whose changes are reviewed and
   out of scope. A finding against an already-reviewed file is answered with that note, not a
   fix;
4. **the batch's test, the RED output, and this instruction: audit the test itself.** Does it
   assert the behaviour the task describes, or does it assert whatever the implementation
   happens to do? Is the assertion vacuous — would it pass without the production change? This
   is the check that replaces the old separation between test-writer and implementer, and it is
   the reviewer's job now. Say so explicitly in the prompt; a reviewer not asked this will
   default to reading only the production diff.

Do not reconstruct the changed-file list from `git status`: that picks up anything the human
left in the tree and anything an earlier batch touched, and a review scoped to it will spend
its findings outside the batch. Carry the list forward across fix passes — a fix adds to the
batch's list, it does not replace it.

**With `--commit` active this gets simpler.** Every approved batch is already a commit, so
from batch 2 onward the scope is exactly `HEAD~1..HEAD`, and you tell the reviewer so. The
prose scope above remains the fallback for two cases: the whole no-flag path, and batch 1,
where no commit from this run exists yet. Say which of the two you are using.

## 8. Adjudicate every finding — do not obey blindly

Accept a `blocking` or `should-fix` finding when it is technically justified and inside the
batch's scope. Reject the rest, each with a one-line rationale that goes into the report.
A `nit` never starts a refine iteration. An accepted finding that turns out to require a plan
change goes to §14 for an amendment — not to a halt, and not to a fix that quietly
contradicts the task it was working from.

**A finding you accept, you fix yourself, then you spawn a *fresh* re-review** — never the
reviewer that produced the findings. One that has already approved its own reasoning is not an
independent second look either. **That re-review is review 2 of 2; there is no review 3** (§12).

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
  Report the seam you would need. Never resolve this by skipping the test or by substituting
  an on-target check.
- **No test harness exists** and the batch would need one introduced — that is a new
  dependency, and the bullet above applies.
- A decision the plan left in **Open questions**, or a discrepancy whose resolution would
  change what gets built, that inspection cannot settle. This is §14's line: reconciling the
  plan with reality is yours, choosing a different shape is theirs.
- **A broken baseline** before batch 1 — it does not build, or its suite is already red.
- The loop has **run out of moves** — §12's three moves exhausted on a batch, or §13's ledger
  unproductive twice running. Because the first unproductive round already forces the next of
  §12's moves, a second one means the approach changed and still moved nothing. This is the only
  loop-exhaustion stop that remains, and it reports what the loop tried, not merely that it
  stopped.
- **A second plan amendment on the same batch** — §12 move 3 is available once. A task that
  needed reconciling with the repository twice is a task whose intent needs your eyes.

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
logic, never a replacement for one. Where the project batches such checks into one pass at the
end of a plan series, follow that.

## 12. Two reviews per batch — and what happens instead of a third

**A batch is reviewed at most twice: the review after implementation, and one re-review after
one fix pass.** There is no third, at any tier, on any batch, however close the second looked
to clean.

Why two and not more: a second identical attempt is already weak evidence. Two passes having
failed on the same findings says the *assignment* is likely wrong rather than the typing, and
the cheapest way to find that out is to re-read the findings — not to spend a third reviewer on
them and a fourth on the round after. A loop that fixes-and-re-reviews until it converges is a
loop that grinds hardest exactly where it is least likely to succeed.

When review 2 does not come back clean, work the three moves below in order. **None of them
spends a review round**, and the batch report names which ones you took and what each changed.

1. **Re-adjudicate, properly this time.** Read the surviving findings yourself, as in §8, but
   now assume the reviewer may be wrong. A finding that has outlived a fix attempt is
   frequently one whose fix the task forbids, or one that is simply mistaken about the code.
   Reject it with a rationale that goes in the report.

   **If nothing blocking survives, the batch is done.** A batch closed on rejections with stated
   reasons is a legitimate outcome, not a batch that got away with something — the report is
   where I check that reasoning, and a rejection I disagree with is cheap for me to spot and
   expensive for the loop to have argued with.

2. **Diagnose, where the obstacle is a failure nobody has explained.** Read
   `~/.claude/skills/systematic-debugging/SKILL.md` and follow its four phases in order:
   investigate, analyze the pattern, hypothesize and test, then implement. The discipline that
   matters here:

   - **Reproduce first.** If you cannot reproduce it, say exactly what you tried, what you
     observed instead, and what the human would need to run or capture. That is a legitimate
     outcome; a guessed fix is not.
   - **Instrument, do not guess.** Logging, asserts, a debugger, memory inspection. On embedded
     targets consider timing, memory layout, ISR interaction and hardware state — not just the
     line that crashed.
   - **State the hypothesis before testing it**, in falsifiable form, including the result that
     would disprove it. "Change X and see" does not count.
   - **No fix before the cause is proven.** If the check refutes the hypothesis, go back to
     investigating.
   - **Clean up your instrumentation** before moving on, unless it is genuinely worth keeping —
     and say which you did.
   - Where the trigger was a `RED_NOT_DEMONSTRATED`, say explicitly which is true: the behaviour
     already exists, the test is wrong, the plan assumption is invalid, or there is a real
     defect. Never make a test pass by weakening it.

   Where the unexplained thing is a command's *output* rather than a defect, **spawn a fresh
   read-only `verifier`** with the exact command and what the output should be — it is the
   cheaper of the two moves.

   **A diagnosis does not entitle the batch to another fix-and-review cycle.** It tells you
   which of move 1 and move 3 is the right one: where it proves the code was right and the
   finding wrong, that is move 1; where it proves the task cannot be satisfied as written, that
   is move 3.

3. **Amend the plan, where the task itself is the defect.** If the task as written cannot be
   satisfied, no further attempt will discover otherwise — amend it through §14, inside that
   section's boundary, and run the batch again against the amended task.

   **The amended batch is a new batch with its own two reviews.** This is the one path to a
   third review of the same code, and it is deliberately expensive: it costs a plan amendment
   reported loudly in its own section, and it is available **once per batch**. A second
   amendment on the same batch is not a move — it is a §10 halt, because a task that needed
   reconciling twice is a task whose intent I should be looking at.

If none of the three clears the batch, **stop and report** (§13).

## 13. The progress ledger — how the loop knows it is still getting somewhere

Removing the iteration cap needs something in its place, and a bigger number is not it. After
every round — a fix pass, a §12 move, or a gate run — record whether it **made progress**. It
did when at least one of these is true:

- an open finding was resolved, or rejected with a rationale;
- the set of open findings *changed* — one appeared, one disappeared, one turned out to be a
  different defect. The same set restated in new words is not a change;
- the batch's changed-file list (§7) grew — something was actually edited;
- a verification command produced output it had not produced before, **including a new
  failure** — a different failure is information;
- the plan was amended (§14).

A round where none of these holds is **unproductive**. One unproductive round moves straight to
the next of §12's three moves rather than retrying. **Two consecutive unproductive rounds end
the run**: report and stop.

With a hard cap of two reviews and at most one amendment, a batch that never converges costs
**at most four reviewer spawns** before it reaches you — two, and two more only if the plan
itself turned out to be wrong. That is the intended shape: this loop clears the batches that are
merely fiddly and hands you the ones that are actually wrong, *quickly*, rather than grinding on
them. A batch that needs a third opinion needs mine, not a fourth agent's.

Keep the ledger in the batch report, one line per round naming which signal fired. It is the
evidence that the loop was converging rather than circling, and when the loop does stop it is
the account of everything that was tried.

## 14. Amending the plan — inline, bounded, and reported loudly

When the repository and the plan disagree, the plan is often the thing to fix: the human may
have changed the code since it was written, and a discrepancy is a signal about the plan, not
only about the code. Amend it. Do not guess, and do not stop.

**Triggers.** Work a task describes is already present. A path, symbol or command a task names
has moved or been renamed. A verification step cannot run as written. A task that cannot be
satisfied as written (§12 move 3). A structural defect that leaves the file unbatchable
(§2).

**How.** You edit the plan file yourself, inside this boundary, stated here and not widened:
**reconcile the plan with the repository; change no design decision and add no scope.** An
amendment exists because the code moved after the plan was written, not because the plan turned
out to be inconvenient.

The plan's structure is not yours to restyle: tasks stay `### Task N — <title>` headings under
`## Tasks`, and the five sections stay in order — `## Goal`, `## Context`, `## Tasks`,
`## Out of scope`, `## Open questions`. §2 batches on those headings, so a plan reformatted any
other way cannot be driven. Where an amendment changes a task's verification, it still states
**the exact command and its expected result**; a hand-wave here becomes a second amendment
later. Where the design has a hole, it goes under `## Open questions` — never filled with an
invented decision.

**Report every amendment loudly** — in the batch report and again in the final one, task by
task, with what changed and the evidence that prompted it. Give it its own section. The human
approved the plan they read; an amended task is a task they have not read. Burying that in a
summary is how an unattended loop quietly builds something else.

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
other: a failure you can explain you fix, one nobody can explain goes to §12. Never "resolve"
it by going back to the incremental tree — that tree is exactly what was hiding it.

**Then spawn the gate: a fresh `verifier` and a fresh whole-plan `reviewer`, in one message**,
both handed the clean-rebuild output and the project brief — the brief now says the tree was
just cleaned, so no gate spawn cleans it again. At the XS tier the `verifier` goes alone. Claim
completion only when every gate spawn comes back clean.

If a gate spawn does not come back clean, adjudicate its findings as in §8, fix them yourself,
and re-run the gate **once**. **The gate is run at most twice**, on exactly the terms a batch
is: its own two runs, counted separately from any batch's, and no third. Not clean after the
second → §12's three moves, none of which buys a third gate run, and then §13.

By the time the gate runs, nearly all of the run's work is already spent — which is the argument
for taking §12's moves here rather than stopping on the first unclean verdict, and equally the
argument for stopping *honestly* rather than circling on the most expensive part of the run.
Report the unresolved findings, the evidence gathered, every batch that did pass, and the moves
already taken, and make no further change.

## 16. The final report

- the plan path, and the batching used;
- **the project brief as finally stated** — the build directory or directories, the incremental
  commands, and anything added to it mid-run. It is what the run and every spawn worked from,
  so it is the first thing to check when a batch went wrong;
- batches completed, and the files changed by each;
- **the spawn count** — reviewers, verifiers, and any diagnostic reader — plus any spawn that
  reported configuring or re-configuring a build directory. That last one must be **zero**,
  always: cleaning is yours at two scheduled points and no spawn's ever;
- **the two clean points** — whether the baseline was reused or clean-configured and why, the
  baseline suite result, and the clean-rebuild result at the gate. A run whose incremental
  batches passed but whose clean rebuild failed is the single most important line in this
  report;
- verification evidence — real command output, not claims;
- **the RED-to-GREEN record per batch** — the test files added, the failing output that proved
  RED, and the passing output after. This is the evidence that the loop specified before it
  built, and with the writing inline it is the primary check that it did. It is the first thing
  to read when a batch looks wrong;
- **any batch where a test was changed rather than added**, with the reason. This should be
  empty; a non-empty entry is the one thing in this report that most needs your eyes;
- review history per batch, with the **progress ledger**, §12's moves taken, and
  **which reviewers ran** — the tier promises a composition, and this is where it is checked;
- every **plan amendment**: the task, what changed, and the evidence that prompted it. Give
  this its own section — it is the part of the run the human has not read;
- findings **rejected**, and the rationale for each;
- deferred checks, with the exact commands and the machine to run them on;
- **with `--commit`: the commit list**, one line per batch with its short SHA, plus the
  reminder that they are provisional and the `git rebase -i <base>` command for squashing
  them;
- the git commands the human may choose to run.

Finally, a **machine-readable metrics block**, last in the report, exactly this shape and these
keys, one per line, so runs are comparable across weeks and a script can read them:

```
## Run metrics
plan: plans/NNN-<slug>.md
tier: XS|S|M|L
tasks: <n>
batches: <n>
wall_clock_min: <n>
spawns_reviewer: <n>
spawns_verifier: <n>
spawns_diagnostic: <n>
spawns_reconfigured_build: <n>          # must be 0
max_concurrent_spawns: <n>              # 1 means a parallel step was serialized
baseline: reused|clean_configured
baseline_suite: pass|fail
gate_clean_rebuild: pass|fail
findings_raised: <n>
findings_accepted: <n>
findings_rejected: <n>
findings_on_the_test: <n>               # findings against the batch's test, not its code
reviews_max_on_one_batch: <n>           # cap is 2, or 4 where an amendment re-ran a batch
fix_passes_used: <n>                    # 0 means every batch reviewed clean first time
post_review_moves_taken: <n>            # §12's moves 1-3, across the run
red_not_demonstrated: <n>
plan_amendments: <n>
deferred_checks: <n>
```

**Report the real numbers, including the embarrassing ones.** `findings_accepted: 0` across a
whole run is a fact worth knowing — it says that tier's review depth caught nothing on this
plan, and several such runs are the evidence for tiering it down. `reviews_max_on_one_batch: 4`
says an amendment re-ran a batch, and the amendment section is where to read why.
`max_concurrent_spawns: 1` on
a tier that grants two reviewers says a parallel step was serialized. `findings_on_the_test: 0`
across many runs is how you find out whether §7's test audit is actually being asked for. A
metrics block massaged to look healthy destroys the only cheap way to tell whether this loop's
cost is buying anything.

## 17. Hard constraints

- **Git is tiered by reversibility.** Read-only (`status`, `diff`, `log`, `show`,
  `blame`) is always allowed. The **additive** tier — `git add` and `git commit` — is
  available to *you only*, only with `--commit`, and only at the post-review checkpoint in
  §9; this is the single carve-out in `~/.claude/CLAUDE.md`'s version-control policy, and it
  does not widen. No agent you spawn may commit — and every agent you spawn is read-only, so
  none can. The **destructive** tier — all of `git stash` and `git checkout`, plus `restore`,
  `clean`, `rm`, `reset --hard`, `rebase`, `commit --amend`, `push`, `branch -D`, `tag -d`,
  `worktree add`/`remove` and the rest — is the human's alone, and some projects deny it
  mechanically in `.claude/settings.json`. Never branch, switch, or create a worktree. Put any
  command you may not run in the report for the human.
- **A project that forbids agent commits outright wins.** If the repository's own
  `CLAUDE.md` or settings deny `add`/`commit`, `--commit` is unavailable there: say so and
  run the unflagged loop instead of working around it.
- Never read or print a secret or an API key. If you encounter one, say that you did and
  where, without reproducing the value.
- Do not edit the project's guideline or convention documents. The loop is held to those
  rules; it does not rewrite them.
- **Every spawn is read-only.** The agents this command spawns are `reviewer`, `verifier`, and
  any project conventions reviewer — nothing that writes. Writing is inline, by you, per §4.
- **Never weaken, skip, disable, or delete a test to get a batch through.** Not yours to do
  and not a fix to accept from a finding: a review finding whose fix is "loosen the assertion"
  is rejected. If a test is genuinely wrong, it is a plan discrepancy for §14.
- **You edit the plan file only inside §14's boundary, plus its checkboxes.** No design
  decision, no new scope, no restyled structure.
- **No spawn ever re-runs project setup — and you do it at exactly two points.** Re-configuring,
  wiping, deleting or duplicating the build directory is yours alone, and only at the baseline
  before batch 1 and the clean rebuild at the closing gate (§15). Between those two points
  nothing cleans, including you.
- **Use the build system's clean mechanism, not `rm -rf`.** `meson setup --wipe`,
  `meson setup --reconfigure`, `cmake --fresh` are scoped and yours at those two points.
  `rm -rf <build dir>` is not the same command — a mistyped path is unrecoverable — and stays
  the human's: put it in the report rather than running it.

## Why running every phase unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because **each phase belongs on a
deliberately chosen model**, and rolling forward inside one session would run the next phase
on whatever model the session happened to be on. That is the property the boundary protects —
not the ceremony of a subagent.

Every phase here runs on a model chosen for it. The phases that write — implementation, fixes,
diagnosis, plan amendment — run on the `opus` at `medium` effort pinned at the top of *this
file*, which is what you are running on right now. **A slash command pins a model exactly as a
subagent does**, so an inline phase under this command is as deliberately placed as a delegated
one. The phases that read run on the model their own agent pins: `reviewer` at `sonnet`/`high`,
`verifier` at `sonnet`/`low`. Nothing in this command inherits an accidental model.

**What changed, and why it is not a weakening.** Writing used to be delegated to `sonnet`
spawns; it is now inline on `opus`. That trades a cheaper model for a stronger one and removes
the cold start entirely — no brief to reconstruct what this context already knows, no
round-trip per batch, no fix pass re-reading the plan from scratch. What delegation was actually
buying was **independence of the reader**, and that is untouched: the reviewer still never wrote
what it reads, and now it also audits the test (§7).

The rule that has not moved: **do not roll from this command into the next phase yourself.**
When the plan is done, this command stops and reports. What happens next — another plan,
a review of the whole change, a commit — is the human's to start.

## Related entry points

`/create-plan` produces the plan file this one consumes; `/review-project` may precede that;
and `/debug` handles a failure on its own. `/review` and `/verify` are the human-invoked
counterparts of the `reviewer` and `verifier` agents — inside this run, the agents are the only
route.

Plan file: $ARGUMENTS
