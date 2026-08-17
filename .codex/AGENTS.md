# Working agreements

## Version control is the human's job

Do not run commands that change Git state. Never create or switch branches,
create worktrees, stage files, commit, merge, rebase, reset, cherry-pick,
stash, fetch, pull, or push. Do not create, move, or delete directories outside
the working tree the human already opened.

Read-only Git inspection is allowed: `git status`, `git diff`, `git log`, and
`git show`. Work in place. When a Git operation would be appropriate, stop and
tell the human why, including the exact command they can run.

## Keep secrets private

Never deliberately read secrets, credentials, API keys, private keys, tokens,
or secret-bearing configuration. If a secret is exposed accidentally, tell the
human that it was exposed, do not repeat or print it, and continue without using
it.

## Testing is opt-in

Do not introduce tests or use test-driven development unless the human asks for
it explicitly, invokes `$test-driven-development`, or a plan explicitly
requires a test. This workflow can cover embedded targets, where a test harness
may cost more than the code under test. Still run the explicit verification
appropriate to a completed task before claiming it works.

## Workflow selection

Use the guided workflow by default. The human may select it explicitly, but
ordinary requests that do not name a workflow also use it. The guided workflow
is design -> plan -> execute -> verify -> review. Each named skill performs
exactly one phase. At the end of a phase, stop, clearly signal completion,
state the suggested next skill, and wait for the human to start it. Do not
advance to another phase automatically.

The exception is `$one-shot-workflow`. Select it only when the human explicitly
invokes that skill or says to use the one-shot workflow; never infer it from a
request to work quickly, autonomously, or end to end. In one-shot mode, proceed
through design -> plan -> execute -> verify -> review without phase or batch
checkpoints. Fix in-scope review findings, re-verify, and re-review until the
work is clean. Stop only for a genuine blocker, a material decision that would
change the requested scope, or verification that requires unavailable access
or hardware.

The version-control, secret-handling, testing, and evidence agreements apply in
both workflows. Naming an individual phase skill selects only that phase, even
if the request also asks to continue afterward.

The exception to guided checkpoints is when the human asks to continue or
refine work within the current phase. During guided execution, stop after every
reviewable batch and wait for approval before starting the next batch so the
human can verify and commit it.

Reusable skills live in `~/.agents/skills`. Invoke one explicitly in Codex with
`$skill-name`, or describe the task so Codex can select the matching skill.

## Evidence before success claims

Before saying work is complete, fixed, building, or passing, run the relevant
verification and show the material result. If verification requires unavailable
hardware or access, state the remaining check precisely instead of claiming
success.

## The loop

Design → plan → execute in reviewable batches → verify with evidence. The
skills in `.claude/skills/` encode each step. Prefer them over improvising.
Plans live as separate numbered files in `plans/`, one file per feature or
work item — never one monolithic plan document.

After every batch spawn an agent that is meant to verify if the step
is correctly implemented based on the requirements described.
Every discrepancy should be signalled, as something might have been changed by me,
thus the correct action might be altering the plan.
