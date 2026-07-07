---
name: executing-plans
description: Use when the human points you at a plan file in plans/ to implement. Loads one plan file, reviews it critically before starting, executes its tasks in small batches, and stops for human review between batches. Use whenever the human says "execute the plan", "start on plan NNN", or "implement plans/...".
---

# Executing Plans

Turn a plan file into working code, in reviewable batches, with a checkpoint
between each. Work on **one plan file at a time**.

## Before starting

1. Read the specified `plans/NNN-*.md` in full.
2. **Review it critically.** If a task is ambiguous, contradicts the codebase,
   or looks wrong, raise it before writing code — don't paper over it.
3. Confirm the batch boundaries: group tasks into batches small enough that the
   human can review each in one sitting. Propose the batching and proceed.

## The execute loop

For each batch:

1. Implement the tasks in the batch, in place, in the currently checked-out
   working tree.
2. Run each task's verification step and capture the actual output.
3. **Stop and report.** Summarize what changed (files + what/why), show the
   verification evidence, and list what's next. Then wait for the human to
   review before starting the next batch.

Do not silently roll from one batch into the next. The checkpoint is the point.

## Hard constraints

- **No git state changes, ever.** Do not branch, checkout, commit, merge, stash,
  or create worktrees. Read-only git (`status`, `diff`, `log`) is fine. When a
  commit or merge would be appropriate, say so and give the exact commands for
  the human to run — then stop. See CLAUDE.md.
- **No tests unless the plan or the human calls for them.** Testing is opt-in.
- If verification fails, do not claim success. Invoke `systematic-debugging`.
- Before claiming the whole plan is done, run `verification-before-completion`.

## Phase boundary

When the whole plan is executed and verified, stop and signal completion — do not
roll into code review, git operations, or the next plan on your own. The human
starts the next step by running the relevant command. The exception is the
in-plan batch checkpoints above, where you also stop and wait.

## Updating the plan

As tasks complete, you may mark them done in the plan file (checkboxes) so state
is visible — this is a content edit to a tracked file, not a git operation, and
is allowed. Do not commit that change; leave staging/committing to the human.
