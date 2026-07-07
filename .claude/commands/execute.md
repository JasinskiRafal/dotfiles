---
description: Execute a plan file in reviewable batches with checkpoints
argument-hint: <plan file, e.g. plans/007-uart-dma.md>
model: sonnet
---
Use the `executing-plans` skill on the plan file below. Read it fully, review it
critically first, then execute its tasks in small batches. Stop and report with
verification evidence between each batch and wait for my review. Work in place —
do NOT run any git state-changing command (no branch/commit/merge/worktree).
Read-only git is fine.

When the whole plan is executed and verified, STOP and signal "Execution
complete". Tell me the next command I might run (e.g. `/review` or `/verify`) —
do not move on to review, commits, or another plan yourself. If I ask for more
within this plan, keep going.

Plan file: $ARGUMENTS
