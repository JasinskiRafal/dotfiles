---
name: executing-plans
description: The discipline for implementing a plan file from plans/ — batch boundaries, verification evidence, reusing the configured build directory, and reporting discrepancies rather than reconciling them. Invoke by name for that discipline alone. For a full plan run use $implement-plan, which orchestrates it end to end.
---

# Executing plans

This skill is the **discipline**, not the loop. Orchestration — batching, spawning the
implementer, delegating review, adjudicating findings, escalating, amending the plan — lives in
**`$implement-plan`** (or `$implement-plan-commit`), which pins its own agents and effort per
phase.

When the human wants a plan driven to done, point them at `$implement-plan <plan-path>` rather
than improvising the loop here. This file will not get the escalation ladder, the progress
ledger, or the plan-amendment path right; those belong to that skill.

What this file is for: the standards any plan execution is held to, whether orchestrated by
that skill, by a subagent, or by you working a single task by hand.

## Before touching code

1. Read the **entire** plan — Goal, Context, Constraints, Tasks, Out of scope, Open questions.
   The surrounding sections are where a plan states the thing that makes the obvious
   implementation wrong.
2. Review it critically. If it is ambiguous, conflicts with the codebase, or looks wrong, raise
   that before changing code.
3. Settle by inspection whatever the repository can answer. Do not ask or guess at what `ls`
   and `grep` will tell you.

## Batch boundaries

One `###` heading under `## Tasks` is one batch. Match on **position, not wording** — plans use
`### Task 1 — ...`, `### 1. ...` and `### Phase A — ...`, and a rule keyed to one convention
silently finds nothing in the others.

Merge two adjacent tasks only when one is meaningless without the other, and say so. Keep every
batch independently verifiable; that property is what makes a batch reviewable.

## The project is already set up — do not set it up again

Where a build directory is already configured, **reuse it**. Detect one by
`<dir>/meson-info/`, `<dir>/CMakeCache.txt`, `<dir>/build.ninja`, or a
`compile_commands.json`, and use the incremental command — `meson compile -C <dir>`,
`cmake --build <dir>` — not the setup command.

Repository documentation typically shows the **first** build (`meson setup build && meson
compile -C build`). That first line is a one-time cost already paid; copying the recipe verbatim
pays it again, on a tree that is often hundreds of megabytes of cross-compiled output.

Never `meson setup` an existing directory, `--wipe`, `--reconfigure`, `--fresh`, `rm -rf <dir>`,
a second build directory under a new name, or a change to the configured options
(`-D<option>`, `-DCMAKE_BUILD_TYPE`, a different `--cross-file`) — that last one reconfigures
the tree for every later batch too. Where the build directory is genuinely unusable, that is a
discrepancy to **report, not repair**; the wipe command belongs to the human.

## For each batch

1. Implement only that batch, in place, in the existing working tree.
2. **Run every verification step the batch names and retain the material output** — the command
   and what it printed, not a claim that it passed. Do not add tests unless the plan or the
   human explicitly calls for them.
3. **Re-read the task text against what you actually changed.** A green build is not evidence of
   a correct one; the most expensive defect is a batch that builds clean and implements the
   wrong thing. Check Constraints and Out of scope once more now that the change exists.
4. Where a check needs a resource you cannot reach — target hardware, a device, credentials you
   do not hold — record it as a **deferred check**, naming the exact command and the machine,
   and continue. Do not omit it silently and do not claim it passed.
5. Report: changed files with what and why, the verification evidence, discrepancies, and the
   proposed next batch. **Then continue to the next batch.**

**This does not stop for the human between batches.** A plan is a specification to follow, and a
run that pauses at every boundary is one the human must babysit for no added safety. The safety
comes from the batch being verified by whoever implemented it and reviewed independently by
someone who did not — which is strictly more than a glance at a checkpoint — plus the
discrepancy rule below.

Where independent review is available, use a fresh reviewer per batch and never reuse one across
a refine iteration. Self-verification does not replace it: you check that the task is satisfied,
the reviewer checks whether the code is right.

## Discrepancies are reported, never reconciled

A task that is ambiguous, that contradicts what the code does, or whose work is **already
present** means the plan may be stale — most often because the human changed something after it
was written.

Say so and stop. Do not implement around it, do not quietly reconcile the plan to the code, and
do not redo work already there. The correct fix is usually amending the plan, and that decision
belongs to the orchestrator, which routes it to a fresh plan writer inside a stated boundary and
reports every amendment to the human.

An unattended run's safety rests entirely on this call being made honestly rather than pressing
on.

## Unexplained failures

If verification fails for a reason you cannot explain, do not stack speculative fixes. Report
the command, its real output, and what you do and do not understand. Use
`$systematic-debugging` to establish the cause.

## Hard constraints

- **Never change Git state** — no branch, checkout, commit, merge, stash, or worktree.
  Read-only Git is fine. Where a commit would be appropriate, give the exact command as text.
  The single exception in this workflow is `$implement-plan-commit`, which is that skill's alone
  and never a subagent's.
- **Testing is opt-in.** Never weaken, skip, or edit a test to obtain a pass; report the
  mismatch instead.
- **Smallest correct change.** No unrelated refactoring, no speculative abstraction, no "while I
  was in here".
- Preserve unrelated working-tree changes — the human's in-progress work and earlier batches.
- You may tick completed plan tasks where plan-file updates are authorized. Any substantive plan
  change goes through a delegated writer, not you, and never a Git operation.
- Never inspect or print secrets or secret-bearing configuration.

## Completion

After the final batch, run the relevant completion verification. End with `Execution complete`
and suggest `$verification-before-completion` or `$requesting-code-review`; do not start either
automatically, and do not roll into the next plan.
