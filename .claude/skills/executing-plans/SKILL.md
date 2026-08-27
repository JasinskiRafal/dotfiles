---
name: executing-plans
description: The discipline for turning a plan file in plans/ into working code — batch boundaries, verification evidence, and reporting discrepancies rather than reconciling them. Invoke by name when you want that discipline on its own. For a full plan run, use the /implement-plan command instead, which orchestrates it end to end.
---

# Executing Plans

This skill is the **discipline**, not the loop. Orchestration — batching, spawning the
implementer, delegating review, adjudicating findings, escalating, amending the plan — lives in
the **`/implement-plan`** command, which pins its own model and effort for each phase.

**If the human wants a plan driven to done, point them at `/implement-plan <plan file>` rather
than improvising the loop here.** This file will not get the model pinning, the escalation
ladder, the progress ledger, or the plan-amendment path right, because those are the command's
and it is 400 lines of them.

What this file is for: the standards any plan execution is held to, whether that run is
orchestrated by the command, by a subagent, or by you working a single task by hand.

## Before touching code

1. Read the specified `plans/NNN-*.md` **in full** — Goal, Context, Constraints, Tasks, Out of
   scope, Open questions. Not just the task in front of you: the surrounding sections are where
   a plan states the thing that makes the obvious implementation wrong.
2. **Critique it.** If a task is ambiguous, contradicts the codebase, or looks wrong, raise it
   before writing code — do not paper over it.
3. **Settle by inspection what the repository can answer.** Do not ask about, or guess at, what
   `ls` and `grep` will tell you.

## Batch boundaries

One `###` heading under `## Tasks` is one batch. Match on **position, not wording** — plans use
`### Task 1 — …`, `### 1. …` and `### Phase A — …`, and a rule keyed to one convention silently
finds nothing in the others.

Merge two adjacent tasks only when one is meaningless without the other, and say so. Keep every
batch independently verifiable; that property is what makes a batch reviewable at all.

## Per batch

1. Implement the batch's tasks, in place, in the currently checked-out working tree.
2. **Run each task's verification step and capture the actual output.** Not a claim that it
   passed — the command and what it printed.
3. **Do not re-run project setup.** Where a build directory is already configured, reuse it and
   use the incremental command (`meson compile -C <dir>`, `cmake --build <dir>`). Never
   `--wipe`, `--reconfigure`, `--fresh`, `rm -rf <dir>`, or a second build directory under a new
   name; those discard a cache the rest of the run depends on and belong to the human.
4. **Record the changed-file list as you go** — every path created or edited, at the moment you
   touch it. It is the review scope, and reconstructing it afterwards from `git status` picks up
   the human's unrelated work and every earlier batch.
5. Report: files changed and why, the verification evidence, discrepancies, and what the next
   batch would be.

**This does not stop for the human between batches.** A plan is a specification to follow, and
a run that pauses at every boundary is a run the human has to babysit for no added safety —
the safety comes from the independent review of each batch and from the discrepancy rule below,
not from a checkpoint. Continue to the next batch.

## Discrepancies are reported, never reconciled

This is the most important rule here. A task that is ambiguous, that contradicts what the code
actually does, or whose work is **already present** means the plan may be stale — most often
because the human changed something after it was written.

**Say so and stop.** Do not implement around it, do not quietly reconcile the plan to the code,
and do not redo work already there. The correct fix is usually amending the plan, and that
decision is not yours: under `/implement-plan` a delegated `planner` in amend mode makes it,
inside a stated boundary, and every amendment is reported to the human.

An unattended run's safety rests entirely on this call being made honestly rather than pressing
on.

## Unexplained failures are reported, not guessed at

When a command fails for a reason you cannot explain, do not pile on fixes to see what sticks.
Report the command, its real output, and what you do and do not understand about it. Two
speculative fixes on an unexplained failure is how a small defect becomes an unreviewable diff.
Invoke `systematic-debugging`, or let the orchestrator route it to a `debugger`.

## Hard constraints

- **No git state changes, ever.** No branch, checkout, commit, merge, stash, or worktree.
  Read-only git (`status`, `diff`, `log`, `show`, `blame`) is fine. When a commit would be
  appropriate, give the exact command for the human and move on. The single exception in this
  workflow is `/implement-plan --commit`, which is the command's alone and never a subagent's.
- **No tests unless the plan or the human calls for them.** Testing is opt-in.
- **Never weaken, skip, or edit a test to obtain a pass.** If a test looks wrong, report the
  mismatch.
- **Smallest correct change.** No unrelated refactoring, no speculative abstraction, no "while I
  was in here". If the plan did not ask for it, it is not in this diff.
- Preserve unrelated changes already in the working tree — the human's in-progress work and
  earlier batches of this same plan.
- Before claiming the whole plan is done, run `verification-before-completion`.

## Plan file edits

Tick checkboxes as tasks complete, so state is visible. That is a content edit to a tracked
file, not a git operation, and is allowed. **Any substantive change to the plan is not yours** —
it goes through a delegated `planner` in amend mode. Do not commit either.

## Phase boundary

When the whole plan is executed and verified, **stop and signal completion.** Do not roll into
code review, git operations, or the next plan on your own — the human starts the next step by
running its command, which is what keeps each phase on the model chosen for it.
