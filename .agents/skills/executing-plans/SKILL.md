---
name: executing-plans
description: Implement one plan file from plans/ in small, reviewable batches with verification evidence and a human checkpoint between batches. Use when the human asks to execute or implement a specific plan.
---

# Executing plans

Implement one specified plan file, in place and in reviewable batches.

## Before starting

1. Read the entire plan.
2. Review it critically. If it is ambiguous, conflicts with the codebase, or
   looks wrong, raise that before changing code.
3. Propose small batch boundaries that a human can review in one sitting.

## For each batch

1. Implement only that batch in the existing working tree.
2. Run every verification step named for the batch and retain the material
   output. Do not add tests unless the plan or human explicitly calls for them.
3. Perform an independent verification pass. When independent subagents are
   available and appropriate, use one; otherwise inspect and verify the result
   separately from the implementation pass.
4. Stop and report: changed files, what and why, verification evidence,
   discrepancies from the plan, and the proposed next batch. Wait for the human
   to approve before continuing.

Never change Git state. If verification fails, do not claim success; use
`$systematic-debugging` to establish the cause. You may tick completed plan
tasks if the human has authorized plan-file updates, but do not perform any Git
operation.

After the final batch, run the relevant completion verification. End with
`Execution complete` and suggest `$verification-before-completion` or
`$requesting-code-review`; do not start either automatically.
