---
description: Critically review the current changes against the plan/requirements
argument-hint: [optional plan file to review against]
model: sonnet
---
Use the `requesting-code-review` skill. Review the current diff (git diff is
read-only, allowed) against the plan/requirements below. Report findings grouped
by severity (blocking / should-fix / nit). Be direct about real problems; if
it's clean, say so. Do not commit or merge — if it's ready, give me the exact
git commands to run.

When done, signal "Review complete" and STOP. Do not fix, commit, or continue
unless I ask.

Review against: $ARGUMENTS
