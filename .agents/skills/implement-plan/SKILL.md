---
name: implement-plan
description: Drive one approved plan file through every implementation batch, independent review, bounded refinement, and a closing remediation gate. Use only when the human explicitly invokes $implement-plan with an optional --commit flag and a plan path; run unattended to completion or a genuine hard blocker.
---

# Implement plan

Orchestrate the back half of the development pipeline:

```text
implement -> verify -> review -> refine -> next batch -> closing remediation
```

Read, delegate, adjudicate, and report. Never write production code in the
parent context. Use a fresh custom agent for every implementation, fix, review,
and verification assignment.

## 1. Parse and preflight

Parse the invoking prompt as `[--commit] <plan-file>`. The flag is optional;
without it, never change Git state. Require exactly one readable plan path.

Read the complete plan: Goal, Context, Tasks, Out of scope, and Open questions.
Critique it against the repository before editing. Resolve repository-answerable
questions by inspection. Halt rather than guess when an ambiguity, stale path,
contradiction, or Open question would change a task.

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
- If one exists, run it beside the correctness reviewer only for changed files
  within its documented remit. Record every skip and reason.

## 2b. Assemble the warm handoff brief — once, before batch 1

Everything a spawn would otherwise rediscover, establish once here and pass verbatim
in every `batch-implementer` prompt for the rest of the run. This is what makes
per-batch delegation affordable; skipping it turns each batch into a cold project
setup.

**There are exactly two clean points in a run, and both are the parent's:** once
before batch 1, to establish a trustworthy baseline, and once at the closing gate, so
the completion claim is not an artifact of incremental state. Everything in between is
strictly incremental and nothing re-configures. Prefer the build system's own clean
mechanism (`meson setup --wipe <dir>`, `cmake --fresh -S . -B <dir>`) and never
`rm -rf`, which is unrecoverable on a mistyped path and stays the human's.

**Find the existing build directory before considering a new one.** A configured
build tree is often hundreds of megabytes and minutes of cross-compilation, and it is
already on disk. But an inherited directory has unknown provenance — it may be
configured for another branch, option set, or cross-file, and every batch and the gate
would inherit that. Before batch 1: check its configuration matches what the plan needs
(`meson configure <dir>`, `cmake -LA -N -B <dir>` print it without building) and
clean-configure it once where it does not or where you cannot tell; then build and run
the host suite once, before any spawn. A baseline that does not build, or whose suite is
already red, is a halt — with a broken baseline no later failure can be attributed to a
batch. Print whether it was reused or clean-configured and the baseline suite result.
Once it passes, the directory is frozen for the run.

Look for it in this order:

- an existing configured directory — `<dir>/meson-info/`, `<dir>/CMakeCache.txt`,
  `<dir>/build.ninja`, or a `compile_commands.json` naming its own directory;
- the directory the repository's own docs use — `README.md`, `CONTRIBUTING.md`, or the
  build section of its `AGENTS.md`;
- only if neither exists, create it once with the exact command those docs prescribe.

Where several are configured — a native `build/` beside a cross `build-rpi5/` or a
sanitizer `build-tsan/` — name the one this plan's verification needs and say why in
the batching report. Where the plan needs two, name both and label which verification
belongs to which. Never leave a spawn to infer it: a spawn that guesses configures a
third one.

**State the incremental command, not the setup command:** `meson compile -C <dir>` and
`meson test -C <dir>`; `cmake --build <dir>` and `ctest --test-dir <dir>`. Repository
docs typically show the first build (`meson setup build && meson compile -C build`);
that first line is already paid, and a spawn that copies the recipe verbatim pays it
again. The brief exists so the spawn never reads that line as an instruction.

**Forbidden to every spawn always, and to the parent between the two clean points**
— put the prohibition in the brief without the exception, because a spawn never needs
to know the parent cleans at two points, only that it never does:
re-configuring a configured directory
(`meson setup` on an existing one, `--wipe`, `--reconfigure`, a fresh `cmake`
configure, `--fresh`); deleting or recreating a build directory (`rm -rf <dir>` is
destructive and belongs to the human); a second directory under a new name; changing
the configured options (`-D<option>`, `-DCMAKE_BUILD_TYPE`, a different
`--cross-file`), which reconfigures the tree for every later batch. A spawn reporting
the directory unusable does not repair it — it reports and stops, and the parent
amends the brief or halts with the exact command for the human.

The brief carries, verbatim, in every spawn prompt:

1. the plan path, and the tasks or accepted findings that spawn owns;
2. the build directory or directories, and the incremental build and test commands;
3. the project facts already established — where source lives, which docs are
   authoritative for conventions, the guideline pages that apply;
4. the files earlier batches already touched, so it leaves them alone;
5. the setup prohibitions above, stated rather than referenced — the spawn does not
   have this file.

Re-derive nothing per batch. When a batch teaches a project fact worth having, add it
to the brief so the next spawn starts with it; the brief only grows. Print the brief
once when assembled, then print only what changed.

## 3. Run each batch

For each batch in order:

1. Spawn a fresh `test-writer` with the brief, the plan path, and the batch's
   behaviors. Require the tests it wrote, the **host** command it ran, and the
   real failing output proving RED. Then check its verdict:
   - RED demonstrated: pass the failing output and test paths to step 2.
   - The test passed before the code existed (`RED_NOT_DEMONSTRATED`): halt. Either
     the behavior is already implemented, which is a plan discrepancy, or the test
     does not test what it claims. Retrying settles neither.
   - Not testable on this host: do not accept it at face value — the `test-writer`
     must look for a seam first. If it reports none exists without a design change,
     halt; the design is the human's. Never let an on-target or manual check stand
     in for the host test.
   - No harness exists at all: that is a new dependency, so halt.
2. Spawn a fresh `batch-implementer` in GREEN mode with the full plan path, exact
   task text, the demonstrated RED, pre-existing-change note, and earlier-batch
   file note.
3. Require its commands and material output plus an authoritative changed-file
   list. The batch is self-verified before it is reviewed: the implementer runs each
   task's verification step, re-reads the task against what it changed, and returns
   real output. If the changed-file list is missing, request only that report detail;
   halt if it remains unavailable. If the verification evidence is missing or is a
   bare claim that it passed, re-spawn for it rather than reviewing on trust, and say
   so in the batch report — reviewing an unverified batch spends a reviewer on
   findings a build would have caught. Carry any deferred check forward, naming the
   command and the machine.
4. Halt on a reported plan/repository discrepancy, work already present,
   unexplained verification failure, a RED that cannot be demonstrated, a
   behavior not testable on the host without a design change, a missing test
   harness, a new dependency, or an unresolved decision. Do not reinterpret any
   of them as completed work.
5. After accessible verification passes, spawn a fresh correctness `reviewer`
   and any applicable conventions reviewer concurrently.

Every spawn — test-writer, implementer, fix, reviewer, and any diagnostic — carries the same warm
handoff brief from §2b, plus what earlier rounds already tried. A diagnosis spawn that
begins by re-configuring the build directory has spent the escalation on the thing the
brief was written to prevent.

Scope reviewers precisely:

- Unflagged run: supply the task text, implementer-reported paths, pre-existing
  paths, and earlier-batch changes that are already reviewed and out of scope.
- `--commit` run: previous approved batches are committed and the current batch
  is not. Review `git diff HEAD -- <reported paths>` together with the task and
  changed-file list. Do not use `HEAD~1..HEAD`, which identifies the previous
  committed batch before the current post-review commit exists.

Adjudicate every finding. Accept a blocking or should-fix finding only when it
is technically justified and inside the current batch. Reject invalid or
out-of-scope findings with a one-line rationale. A nit never starts a fix pass;
record it as non-gating with the rationale.

For accepted findings, spawn a fresh `batch-implementer` in fix mode with only
the adjudicated findings, rerun the affected verification, then use fresh
reviewers. Never reuse an implementer as a reviewer or reuse a reviewer across
iterations. Halt when the batch is not clean after three fix-and-review
iterations. An accepted finding that requires changing the plan is a halt.

## 4. Create an optional scratch commit

Only after the batch verifies and all independent reviews are clean, and only
with `--commit`:

1. Stage exactly the implementer-reported paths plus the plan file when its
   progress markers changed.
2. Inspect the staged path list and halt if it contains any other path.
3. Follow the most specific applicable repository instructions for the commit
   message. If none define a convention, use exactly
   `plan NNN batch M: <task heading>` with no body or trailer. A local
   commit-message convention replaces this fallback and must not halt the run.
4. Record the short commit ID for the final report.

These commits are provisional review checkpoints meant for the human to squash.
No subagent may stage or commit.

Emit the batch result and continue without a human checkpoint.

## 5. Handle hard halts

Halt immediately for:

- a plan/repository discrepancy or work already present;
- an unexplained verification failure;
- a batch not clean after three refinement iterations;
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

Closing-gate retry exhaustion or the need for an in-scope structural refactor
is not itself a hard halt. Handle it through closing remediation below.

## 6. Run the closing gate

**First, clean-rebuild once — the run's second and last clean point.** Before spawning
the gate, wipe and re-configure the build directory yourself (`meson setup --wipe <dir>`
or the project's documented equivalent, never `rm -rf`), rebuild, and run the full host
suite. Hand that output to both gate agents.

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

After the last batch, spawn concurrently:

- a fresh `verifier` with the complete plan and all authoritative verification
  commands;
- a fresh `reviewer` with whole-plan scope.

For an unflagged run, scope the reviewer with the union of implementer-reported
paths and the initial pre-existing-change note. For `--commit`, review the
captured starting commit through current HEAD and require a clean working tree
for the initial gate. During gate remediation, review that committed range
together with the working-tree diff limited to the accumulated, authoritatively
reported remediation paths; do not require a clean tree until the remediation
commit is created.

Adjudicate findings as for a batch. Route accepted findings to a fresh
`batch-implementer` in fix mode, then rerun accessible verification with a fresh
verifier and repeat whole-plan review with a fresh reviewer. Use the smallest
coherent fix while findings are isolated and making progress.

Escalate the gate into a refactor-and-improvement batch when a finding recurs,
spans batch boundaries, reveals a structural cause, or remains after three
direct fix-and-gate iterations. Do not halt because the direct-fix allowance was
exhausted. Give a fresh `batch-implementer`:

- the failed evidence and adjudicated findings across all gate iterations;
- the plan outcomes that are still unsupported;
- an explicit in-scope refactor goal and non-goals;
- the authoritative changed-path history and verification commands.

Require the implementer to address the root cause, improve the affected design,
and report its changed files and evidence. Then run a fresh verifier and fresh
whole-plan reviewer. Continue alternating direct remediation and structural
remediation until the gate is clean.

Every structural remediation must show material progress: eliminate or narrow a
finding, improve verification evidence, or produce reviewer-confirmed design
improvement. When a remediation makes no material progress, use a fresh reviewer
in diagnostic scope to identify the root cause before assigning more edits. The
gate may halt only when that diagnosis establishes a Section 5 hard halt, such
as a required plan change, new dependency, or unresolved shape-changing
decision. Never halt solely because of an iteration count or because an
in-scope refactor is needed.

If closing-gate fixes or refactors occur under `--commit`, accumulate their
authoritative reported paths. After the gate is clean, stage only that union and
create one provisional commit using the most specific applicable repository
commit-message convention. If none exists, use
`plan NNN gate: closing remediation`. Include it in the commit list.

Claim completion only when the verifier's evidence supports the plan and the
whole-plan reviewer is clean. Deferred checks remain explicitly unverified.

## 7. Report

Report:

- plan path and batching;
- batches completed and files changed by each;
- commands and material verification evidence;
- review history and refinement count per batch, plus direct-fix and structural
  remediation history for the gate;
- rejected or non-gating findings with rationale;
- deferred checks with exact commands and environments;
- halt reason and required human action, when halted;
- under `--commit`, each provisional commit ID and subject plus human-only
  squash guidance.

## Hard constraints

- Obey all applicable `AGENTS.md` files and the approved plan.
- Never implement or fix code in the parent context.
- Never run mutating agents concurrently; only read-only reviewers may run in
  parallel.
- Never write tests or production code in the parent context; every batch is a
  fresh `test-writer` that proves RED, then a fresh `batch-implementer` that
  turns it green.
- Never weaken, skip, disable, or delete a test to get a batch through, and never
  accept a fix that does. If a test is genuinely wrong, that is a plan
  discrepancy.
- Never inspect or print secrets or secret-bearing configuration.
- Never edit repository policy or guideline documents, or the plan beyond
  existing progress markers.
- Without `--commit`, perform read-only Git inspection only.
- With `--commit`, only the parent may run `git add` and `git commit`, only at
  the clean post-review checkpoints described above.
- Never stash, restore, clean, reset, merge, rebase, amend, fetch, pull, push,
  branch, switch, tag, or create/remove a worktree.
