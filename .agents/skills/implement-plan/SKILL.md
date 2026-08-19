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

## 3. Run each batch

For each batch in order:

1. Spawn a fresh `batch-implementer` in batch mode with the full plan path,
   exact task text, pre-existing-change note, and earlier-batch file note.
2. Require its commands and material output plus an authoritative changed-file
   list. If the list is missing, request only that report detail; halt if it
   remains unavailable.
3. Halt on a reported plan/repository discrepancy, work already present,
   unexplained verification failure, unauthorized test, new dependency, or
   unresolved decision. Do not reinterpret it as completed work.
4. After accessible verification passes, spawn a fresh correctness `reviewer`
   and any applicable conventions reviewer concurrently.

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
3. Commit with exactly `plan NNN batch M: <task heading>` and no body or trailer.
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

Closing-gate retry exhaustion or the need for an in-scope structural refactor
is not itself a hard halt. Handle it through closing remediation below.

## 6. Run the closing gate

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
create one provisional `plan NNN gate: closing remediation` commit. Include it
in the commit list.

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
- Never add tests unless the approved plan explicitly requires them.
- Never inspect or print secrets or secret-bearing configuration.
- Never edit repository policy or guideline documents, or the plan beyond
  existing progress markers.
- Without `--commit`, perform read-only Git inspection only.
- With `--commit`, only the parent may run `git add` and `git commit`, only at
  the clean post-review checkpoints described above.
- Never stash, restore, clean, reset, merge, rebase, amend, fetch, pull, push,
  branch, switch, tag, or create/remove a worktree.
