---
name: implement-plan
description: Drive one approved plan file through every implementation batch, independent review, bounded refinement, and a closing remediation gate. Use only when the human explicitly invokes $implement-plan with an optional --commit flag and a plan path; run unattended to completion or a genuine hard blocker.
---

# Implement plan

Orchestrate the back half of the development pipeline:

```text
implement -> verify -> review (at most twice) -> fix -> next batch -> closing remediation
```

**Write in the parent context; delegate only reading.** You write each batch's
tests, the production change, and every fix, inline, in this context. Every
review and verification is a fresh read-only spawn, and siblings go out
concurrently.

## The split, and why

A phase that changes a file runs here. A phase that only reads runs as a spawned
agent.

**Writing is inline** because a cold spawn's expensive half was never the code —
it was re-deriving the build directory, the layout, and the conventions, once per
spawn and again per fix pass. This context already read the plan, established the
baseline, and holds every earlier batch. Handing that to a fresh agent means
briefing it to reconstruct what is already known and then reconciling its summary
against the tree.

**Reading is spawned** because it cannot be done here: a reviewer that also wrote
the code is the author re-reading their own reasoning. The property this loop
rests on is that the reader never wrote what it reads and cannot see why it was
written that way. That survives the writing moving inline, and it is why review
is never inline at any size, on any round, however obvious a finding looks.

**What the split gives up, and what replaces it.** A separate `test-writer` could
not tune its test to code it never saw. With both inline that pressure is real: a
test authored beside its implementation drifts toward asserting what the code
does rather than what the behavior should be. Three controls replace it, none
optional — RED demonstrated and its output recorded verbatim before any
production edit exists; the reviewer explicitly briefed to audit the test as well
as the code, asking whether the assertion would pass without the production
change; and the RED-to-GREEN record per batch as a required report section, with
any test changed rather than added called out by itself.

## 1. Parse and preflight

Parse the invoking prompt as `[--commit] <plan-file>`. The flag is optional;
without it, never change Git state. Require exactly one readable plan path.

Read the complete plan: Goal, Context, Tasks, Out of scope, and Open questions.
Read it in full, not only the first task — Goal, Context, Constraints, and Out of
scope are where a plan states the thing that makes the obvious implementation
wrong. Critique it against the repository before editing. Resolve
repository-answerable questions by inspection. Halt rather than guess when an
ambiguity, stale path, contradiction, or Open question would change a task.

Read all applicable `AGENTS.md` files before applying workflow defaults. Treat
the most specific project instructions as authoritative for customizable
details such as naming, formatting, commands, commit messages, and review
conventions. Adapt and continue when they specialize or replace a default in
this skill; that difference alone is not a plan/repository discrepancy or halt
condition. Preserve higher-priority instructions, permission and safety
boundaries, the human's current request, and this skill's non-customizable role
separation and authorization constraints.

Record the initial working-tree paths so pre-existing human changes remain
distinguishable from this run.

When `--commit` is present, apply these preconditions once before batch 1:

1. If project instructions or permissions prohibit agent commits, report that
   the flag is unavailable and continue only in unflagged mode.
2. Require `git status --porcelain` to be empty. Otherwise report the dirty
   paths and halt.
3. Resolve the current branch and repository default branch with read-only Git
   metadata (`symbolic-ref`, falling back to an existing `main` or `master`).
   Halt on the default branch or detached HEAD and give the human an appropriate
   branch command as text only.
4. Capture the starting commit with `git rev-parse HEAD` for whole-plan review.

Never create or switch a branch or worktree.

## 2. Establish batches and review roles

Require a `## Tasks` section containing at least one `###` heading. Each `###`
heading under that section is one batch, regardless of its wording. Halt instead
of inventing batches when the structure is missing.

Merge adjacent tasks only when either would be meaningless alone. State the
merged headings and reason before starting. Print the complete batching.

Before batch 1, inspect project-scoped `.codex/agents/*.toml` files for an agent
whose name and description explicitly define a coding-guidelines or conventions
review. Do not infer one from a generic reviewer.

- If none exists, the correctness `reviewer` owns applicable repository
  conventions.
- If one exists, run it beside the correctness reviewer, in the same dispatch,
  only for changed files within its documented remit. Record every skip and
  reason.

## 2b. Establish the project brief — once, before batch 1

Everything about how this project builds and tests, establish once here and then
hold for the run. You are doing the work, so this is not a document to hand off —
it is the state you stop re-deriving. Read-only spawns receive the parts they
need, and the final report states it as finally used.

**There are exactly two clean points in a run, and both are yours:** once before
batch 1, to establish a trustworthy baseline, and once at the closing gate, so the
completion claim is not an artifact of incremental state. Everything in between is
strictly incremental and nothing re-configures, including you. Prefer the build
system's own clean mechanism (`meson setup --wipe <dir>`, `cmake --fresh -S . -B
<dir>`) and never `rm -rf`, which is unrecoverable on a mistyped path and stays the
human's.

**Find the existing build directory before considering a new one.** A configured
build tree is often hundreds of megabytes and minutes of cross-compilation, and it is
already on disk. But an inherited directory has unknown provenance — it may be
configured for another branch, option set, or cross-file, and every batch and the gate
would inherit that. Before batch 1: check its configuration matches what the plan needs
(`meson configure <dir>`, `cmake -LA -N -B <dir>` print it without building) and
clean-configure it once where it does not or where you cannot tell; then build and run
the host suite once. A baseline that does not build, or whose suite is already red, is a
halt — with a broken baseline no later failure can be attributed to a batch. Print
whether it was reused or clean-configured and the baseline suite result. Once it passes,
the directory is frozen for the run.

Look for it in this order:

- an existing configured directory — `<dir>/meson-info/`, `<dir>/CMakeCache.txt`,
  `<dir>/build.ninja`, or a `compile_commands.json` naming its own directory;
- the directory the repository's own docs use — `README.md`, `CONTRIBUTING.md`, or the
  build section of its `AGENTS.md`;
- only if neither exists, create it once with the exact command those docs prescribe.

Where several are configured — a native `build/` beside a cross `build-rpi5/` or a
sanitizer `build-tsan/` — name the one this plan's verification needs and say why in
the batching report. Where the plan needs two, name both and label which verification
belongs to which.

**State the incremental command, not the setup command:** `meson compile -C <dir>` and
`meson test -C <dir>`; `cmake --build <dir>` and `ctest --test-dir <dir>`. Repository
docs typically show the first build (`meson setup build && meson compile -C build`);
that first line is already paid. Name the **host test command** explicitly and
separately — it is what every RED and every GREEN is proven with, and picking the
cross-compiled target suite by accident invalidates both.

**Between the two clean points nothing cleans, including you:** no re-configuring a
configured directory (`meson setup` on an existing one, `--wipe`, `--reconfigure`, a
fresh `cmake` configure, `--fresh`); no deleting or recreating a build directory
(`rm -rf <dir>` is destructive and belongs to the human); no second directory under a
new name; no changing the configured options (`-D<option>`, `-DCMAKE_BUILD_TYPE`, a
different `--cross-file`), which reconfigures the tree for every later batch.

**No spawn ever cleans, in any mode.** Read-only spawns have no business configuring a
build tree, and the brief they receive says so without mentioning that you clean at two
scheduled points — telling a spawn about a sanctioned clean is how a spawn talks itself
into one.

Where the tree is genuinely unusable — a moved toolchain, a corrupt cache, options that
contradict the task — you have three moves in order: re-check the command; bring the
gate's clean rebuild forward once, saying so in the batch report and noting the gate
will still clean again; or halt with the exact command for the human.

Print the brief once when established, then print only what changed. When a batch
teaches a project fact worth having, add it; the brief only grows.

## 3. Run each batch

For each batch in order:

1. **Write the batch's tests yourself and prove RED.** Run the narrowest relevant
   host command and show the tests fail. Follow `$test-driven-development`. A
   successful RED fails for the expected missing behavior — not from a syntax
   error, a missing fixture, an environment or compilation problem, or an
   unrelated defect. Use the project's existing harness and conventions. Do not
   implement or alter production functionality while writing the test, and do not
   weaken, delete, or adjust an existing assertion. Then check what you got:
   - RED demonstrated: record the failing output verbatim and the test paths, and
     proceed.
   - The test passed before the code existed (`RED_NOT_DEMONSTRATED`): halt. Either
     the behavior is already implemented, which is a plan discrepancy, or the test
     does not test what it claims. Retrying settles neither, and never manufacture
     a failure to get past it.
   - Not testable on this host: do not accept that at face value. Hardware-coupled
     code is the normal case and the normal answer is a seam — the logic behind a
     host-testable interface, with the register-poking part left thin. Look for it
     and propose it. Only where none exists without a design change do you halt;
     the design is the human's. Never let an on-target or manual check stand in for
     the host test.
   - No harness exists at all: that is a new dependency, so halt.
2. **Make the smallest correct production change that turns RED into GREEN.** No
   unrelated refactoring, no scope expansion, no speculative abstraction. Never
   weaken, skip, or edit a test to obtain a pass — not the one you just wrote, not
   an existing one that now fails. A test edited to go green destroys the evidence
   that anything was wrong. If a test looks wrong, that is a discrepancy.
3. **Verify before you spawn a reviewer.** Run the new test on the host and show
   it GREEN with the same command that proved it RED; run the whole host suite,
   not only the new test; run the task's own verification step as the plan writes
   it; re-read the task text against what you actually changed, because a batch
   that builds clean and implements the wrong thing is the most expensive defect
   here; re-check Constraints and Out of scope now that the change exists; and
   capture the real output rather than "tests pass". Assemble the authoritative
   changed-file list — that is the review scope. Carry any deferred check forward,
   naming the command and the machine. Do not review a batch that does not build.
4. Halt on a plan/repository discrepancy, work already present, an unexplained
   verification failure, a RED that cannot be demonstrated, a behavior not
   testable on the host without a design change, a missing test harness, a new
   dependency, or an unresolved decision. Do not reinterpret any of them as
   completed work, and do not pile on speculative fixes: two of those on an
   unexplained failure is how a small defect becomes an unreviewable diff.
5. **Stop editing, then dispatch the readers concurrently** — a fresh correctness
   `reviewer` and any applicable conventions reviewer, in a single dispatch.

**Never edit a file while a spawn is in flight.** Spawns run while you keep
working, so nothing stops you starting the next batch, or a fix, over files a
reviewer is still reading. A reviewer that reads a file mid-edit reports findings
against a state that no longer exists, and you then spend a round on a phantom.
Finish writing, verify, assemble the changed-file list, dispatch — and touch
nothing until every reviewer of that batch has reported.

Scope reviewers precisely, and give each one four things: the task text, the
authoritative changed-file list, the pre-existing and earlier-batch paths that are
already reviewed and out of scope, and **the batch's test plus its RED output with
an explicit instruction to audit the test itself** — does it assert the behavior
the task describes, or whatever the implementation happens to do, and would the
assertion pass without the production change. That last item replaces the old
separation between test author and implementer; a reviewer not asked for it will
read only the production diff.

- Unflagged run: supply the task text, the reported paths, pre-existing paths, and
  earlier-batch changes that are already reviewed and out of scope.
- `--commit` run: previous approved batches are committed and the current batch
  is not. Review `git diff HEAD -- <reported paths>` together with the task and
  changed-file list. Do not use `HEAD~1..HEAD`, which identifies the previous
  committed batch before the current post-review commit exists.

Adjudicate every finding. Accept a blocking or should-fix finding only when it
is technically justified and inside the current batch. Reject invalid or
out-of-scope findings with a one-line rationale. A nit never starts a fix pass;
record it as non-gating with the rationale.

**For accepted findings, fix them yourself, then dispatch one fresh re-review —
that is review 2 of 2.** Never reuse a reviewer across iterations: one that has
already approved its own reasoning is not an independent second look.

## 3b. Two reviews per batch, and what happens instead of a third

**A batch is reviewed at most twice: the review after implementation, and one
re-review after one fix pass.** There is no third, on any batch, however close the
second looked to clean.

A second identical attempt is already weak evidence. Two passes failing on the
same findings says the assignment is likely wrong rather than the typing, and the
cheapest way to find that out is to re-read the findings — not to spend a third
reviewer on them and a fourth on the round after.

When review 2 is not clean, work these in order. **Neither spends a review round.**

1. **Re-adjudicate, assuming the reviewer may be wrong.** A finding that outlived a
   fix attempt is frequently one whose fix the task forbids, or one simply mistaken
   about the code. Reject it with a rationale that goes in the report. **If nothing
   blocking survives, the batch is done** — a batch closed on stated rejections is
   a legitimate outcome, and the report is where the human checks that reasoning.
2. **Diagnose, where the obstacle is a failure nobody has explained.** Follow
   `$systematic-debugging`: reproduce first, instrument rather than guess, state a
   falsifiable hypothesis before testing it, and never fix before the cause is
   proven. Where the unexplained thing is a command's output rather than a defect,
   dispatch a fresh read-only `verifier` with the exact command and the expected
   result. A diagnosis buys no further fix-and-review cycle; it tells you whether
   the finding was wrong (move 1) or the task is the defect (a halt, below).

If neither clears the batch, halt. A task that cannot be satisfied as written is a
plan change, and Section 5 has it.

## 4. Create an optional scratch commit

Only after the batch verifies and all independent reviews are clean, and only
with `--commit`:

1. Stage exactly the reported changed paths plus the plan file when its
   progress markers changed.
2. Inspect the staged path list and halt if it contains any other path.
3. Follow the most specific applicable repository instructions for the commit
   message. If none define a convention, use exactly
   `plan NNN batch M: <task heading>` with no body or trailer. A local
   commit-message convention replaces this fallback and must not halt the run.
4. Record the short commit ID for the final report.

These commits are provisional review checkpoints meant for the human to squash.
No subagent may stage or commit, and every subagent here is read-only.

Emit the batch result and continue without a human checkpoint.

## 5. Handle hard halts

Halt immediately for:

- a plan/repository discrepancy or work already present;
- an unexplained verification failure that Section 3b's diagnosis did not settle;
- a batch still not clean after its two reviews and Section 3b's two moves;
- a new third-party dependency;
- an unresolved shape-changing decision;
- a test the approved plan did not authorize;
- an accepted review finding that requires a plan change.

On halt, make no further change. Report completed batches, files, evidence,
review history, rejected findings, and exactly what the human must resolve. In
commit mode, explain that approved earlier batches are committed and the failing
batch remains uncommitted for inspection. Put any recovery command in the
report as text only.

A check requiring unavailable hardware, credentials, deployment, or another
machine is not a halt. Record it as deferred with the exact command and target
environment, then continue.

A test is never such a check. Tests are host-native and mandatory, so the suite
is always runnable from here: a "deferred test" is a contradiction — either it
runs on this host, or the code needs a seam so it can, which is a halt. Deferral
covers reading a real sensor, driving a peripheral, or measuring true timing, and
such a check is always additional to a host test of the same logic.

## 6. Run the closing gate

**First, clean-rebuild once — the run's second and last clean point.** Before
dispatching the gate, wipe and re-configure the build directory yourself (`meson setup
--wipe <dir>` or the project's documented equivalent, never `rm -rf`), rebuild, and run
the full host suite. Hand that output to both gate agents.

This is not ceremony. Every batch since the baseline was incremental, and incremental
state hides exactly the defects that matter at a completion claim: a header a
translation unit uses but never includes, compiling only because a stale object still
carries it; a file removed from the build definition but still linked from a previous
object; generated code never regenerated after its input changed; a test passing only
against a stale fixture or binary; an option changed mid-run whose effect was never
rebuilt into everything. Each makes a plan look finished and fails on the next clean
checkout — that is, on the human's machine, after the run reported success.

A clean rebuild that fails is a real finding, not an environment problem: route it like
any other, and never "resolve" it by returning to the incremental tree, which is exactly
what was hiding it.

After the last batch, **dispatch concurrently, in one message**:

- a fresh `verifier` with the complete plan and all authoritative verification
  commands;
- a fresh `reviewer` with whole-plan scope.

For an unflagged run, scope the reviewer with the union of reported paths and the
initial pre-existing-change note. For `--commit`, review the captured starting
commit through current HEAD and require a clean working tree for the initial
gate. During gate remediation, review that committed range together with the
working-tree diff limited to the accumulated reported remediation paths; do not
require a clean tree until the remediation commit is created.

Adjudicate findings as for a batch. Fix accepted findings yourself, rerun
accessible verification, and **re-run the gate once**. **The gate is run at most
twice**, on the same terms as a batch: its own two runs, counted separately, and
no third. Use the smallest coherent fix while findings are isolated and making
progress.

**Where a finding recurs, spans batch boundaries, or reveals a structural cause,
the gate escalates once into a refactor-and-improvement pass** rather than
grinding: address the root cause, with an explicit in-scope refactor goal and
stated non-goals, then re-run the gate. That escalation is available once, it does
not reset the two-run cap on the runs that follow it, and it must show material
progress — a finding eliminated or narrowed, better verification evidence, or a
reviewer-confirmed design improvement.

Where a remediation makes no material progress, dispatch a fresh `reviewer` in
diagnostic scope to identify the root cause before making further edits. The gate
halts when that diagnosis establishes a Section 5 hard halt, or when the two gate
runs and the single structural escalation are spent. Report the unresolved
findings, the evidence gathered, every batch that did pass, and the moves already
taken, and make no further change.

If closing-gate fixes or refactors occur under `--commit`, accumulate their
reported paths. After the gate is clean, stage only that union and create one
provisional commit using the most specific applicable repository commit-message
convention. If none exists, use `plan NNN gate: closing remediation`. Include it
in the commit list.

Claim completion only when the verifier's evidence supports the plan and the
whole-plan reviewer is clean. Deferred checks remain explicitly unverified.

## 7. Report

Report:

- plan path and batching;
- the project brief as finally used — build directory or directories, the
  incremental commands, and anything added mid-run;
- batches completed and files changed by each;
- commands and material verification evidence;
- **the RED-to-GREEN record per batch** — the test files added, the failing output
  that proved RED, and the passing output after. With the writing inline this is
  the primary evidence that the loop specified before it built, and the first
  thing to read when a batch looks wrong;
- **any batch where a test was changed rather than added**, with the reason. This
  should be empty; a non-empty entry most needs the human's eyes;
- review history per batch — which reviewers ran, the verdicts, and any of Section
  3b's moves taken — plus the gate's runs and any structural escalation;
- the spawn count, and any spawn that reported configuring a build directory,
  which must be zero;
- both clean points — baseline reused or clean-configured and its suite result,
  and the gate's clean-rebuild result;
- rejected or non-gating findings with rationale, including findings rejected
  under Section 3b move 1;
- deferred checks with exact commands and environments;
- halt reason and required human action, when halted;
- under `--commit`, each provisional commit ID and subject plus human-only
  squash guidance.

## Hard constraints

- Obey all applicable `AGENTS.md` files and the approved plan.
- **Every spawn is read-only.** This skill dispatches `reviewer`, `verifier`, and
  any project conventions reviewer — nothing that writes. Writing is inline.
- Never review your own batch, at any size, on any round.
- Never edit a file while a read-only spawn is in flight, and never run two
  writing operations concurrently.
- Never weaken, skip, disable, or delete a test to get a batch through, and never
  accept a fix that does. If a test is genuinely wrong, that is a plan
  discrepancy.
- Never inspect or print secrets or secret-bearing configuration.
- Never edit repository policy or guideline documents, or the plan beyond
  existing progress markers.
- No spawn re-runs project setup, and you do it at exactly the two scheduled
  points. Use the build system's clean mechanism, never `rm -rf`.
- Without `--commit`, perform read-only Git inspection only.
- With `--commit`, only the parent may run `git add` and `git commit`, only at
  the clean post-review checkpoints described above.
- Never stash, restore, clean, reset, merge, rebase, amend, fetch, pull, push,
  branch, switch, tag, or create/remove a worktree.
