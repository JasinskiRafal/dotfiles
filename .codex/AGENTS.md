# Working agreements

## Local instructions specialize general defaults

Treat the most specific applicable project instructions as the source of truth
for that project. Repository-level and more deeply scoped `AGENTS.md` files may
replace general preferences and skill defaults such as naming, formatting,
commands, commit-message structure, and review conventions. Adapt the workflow
to those local instructions and continue; a local customization is not by
itself a discrepancy or halt condition.

This precedence applies among otherwise compatible user-owned instructions. It
does not let project instructions override system or developer instructions,
the human's current request, permission boundaries, safety rules, or an
explicitly non-customizable workflow invariant. When a genuine higher-priority
conflict remains, report that conflict precisely instead of treating every
difference from a general default as blocking.

## Version control is tiered by reversibility

Read-only Git inspection is always allowed: `git status`, `git diff`, `git log`,
`git show`, `git blame`, `git rev-parse`, `git symbolic-ref`, and `git
show-ref`. Use these commands only to understand repository state and review
work already present.

The additive tier, `git add` and `git commit`, is reserved for two explicit
invocations of the same workflow: the parent orchestrator running
`$implement-plan --commit` or `$implement-plan-commit`. That carve-out applies
only when all of these conditions hold:

- the human supplied `--commit`, or explicitly invoked
  `$implement-plan-commit`;
- the working tree was clean before the first batch and HEAD was not the
  repository's default branch;
- the batch has completed its verification and independent reviews cleanly,
  with every accepted finding fixed and independently re-reviewed;
- the parent stages only paths reported by the batch implementer, plus the plan
  file when its progress markers changed;
- the commit follows the most specific applicable repository convention for
  commit-message structure, falling back to the workflow's mechanical subject
  when no local convention exists.

Spawned agents may run read-only Git inspection only. They may never execute a
Git command that changes repository, index, configuration, refs, or worktree
state, including staging or committing. Without `--commit`, the parent may not
stage or commit either, unless the human explicitly invoked
`$implement-plan-commit`. A repository-level `AGENTS.md`, policy, or permission
rule that forbids agent commits overrides this global carve-out.

All destructive, history-rewriting, remote, branch, and worktree operations
remain the human's job. Never run `git checkout`, `switch`, `branch`, `worktree`,
`stash`, `restore`, `clean`, `rm`, `reset`, `merge`, `rebase`, `cherry-pick`,
`commit --amend`, `tag`, `fetch`, `pull`, or `push`. Never create, move, or
delete directories outside the working tree the human already opened. When one
of these operations would be appropriate, stop and give the human the exact
command they may choose to run.

## Keep secrets private

Never deliberately read secrets, credentials, API keys, private keys, tokens,
or secret-bearing configuration. If a secret is exposed accidentally, tell the
human that it was exposed, do not repeat or print it, and continue without
using it.

## Tests are mandatory, written first, and run on the host

Tests are part of the code, not an add-on to it. Every behavior an agent
implements arrives with a test that proves it. There is no opt-in flag, no
"unless the plan requires it", and no task too small — a change without a test is
an unfinished change.

Test-first, and prove RED. The order is not negotiable: write the test for one
behavior, run it and show it fail with real output, then make the smallest
production change that turns it green, then re-run and show it pass. A test that
has never failed has not been shown to test anything.

RED that cannot be demonstrated is a hard halt. If the test passes before the
code exists, either the behavior is already implemented — a plan discrepancy — or
the test is not testing what it claims. Both need the human.

Tests run on this host, directly: natively compiled and executed by the project's
test runner on this machine, in one command the human can re-run. Never
cross-compiled to a target, flashed to a device, or run inside a container,
emulator, simulator, or over a network.

This is why tests are affordable here rather than a reason they are not. Embedded
targets are exactly what makes on-target testing expensive, so logic belongs
behind a host-testable seam and the target-only part stays thin. Where code
cannot be tested on the host, the design is the defect: say so and treat it as a
design question for the human.

A test is never a deferred check. Deferral is for what this machine genuinely
cannot do — reading a sensor, driving a peripheral, measuring real timing — and
such a check is always additional to a host test of the same logic, never a
replacement for one.

## Workflow selection

Use the guided workflow by default: design -> plan -> execute in reviewable
batches -> verify -> review. Each phase skill performs exactly one phase. At
the end of a phase, stop, clearly signal completion, suggest the next skill,
and wait for the human to invoke it. During guided execution, stop after every
reviewable batch so the human can inspect and commit it.

Three explicit skills provide delegated orchestration around the same phases:

```text
$create-plan            brainstorm -> plan -> review the plan -> refine -> hand over
$implement-plan         implement -> review -> refine -> next batch -> closing gate
$implement-plan-commit  same as $implement-plan --commit; commits are mandatory
```

`$create-plan` is the interactive front half. It delegates repository
inspection, plan writing, and plan review to fresh specialized agents, asks the
human only for decisions inspection cannot settle, and stops after handing over
the reviewed plan. It reviews on **two concurrent lenses** — `plan-reviewer` for
correctness and coverage, `plan-simplifier` for minimality — and adjudicates
both in one pass. Where they conflict, coverage wins. The weight of the pipeline
is deliberately on this end: a defect caught in the plan costs one refine round,
the same defect caught during execution costs a batch, a review, an amendment,
and every batch built on it since.

`$implement-plan` is the unattended back half. It delegates every implementation
and review assignment to a fresh specialized agent and proceeds until the plan
is complete or a hard halt condition occurs. It does not stop between batches:
each batch is verified by the agent that implemented it and reviewed by one that
did not, which is strictly more than a human glance at a checkpoint would give
it.

What makes per-batch delegation affordable is that the orchestrator establishes
the project **once** — the build directory, the incremental build and test
commands, the layout and conventions — and hands the same brief to every spawn.
A spawn that re-runs project setup costs more than it saves; re-configuring,
wiping, deleting, or duplicating a configured build tree is forbidden to every
agent and reserved to the human.
`$implement-plan-commit` is its commit-on wrapper for invocations where the
human does not want to remember the optional flag. Only an explicit invocation
selects an orchestrator; ordinary planning and implementation requests continue
to use the guided workflow.

Naming an individual phase skill still selects only that phase. A request to
continue or refine work within the current phase may proceed, but it does not
authorize rolling into another phase in the current agent context.

### Delegation crosses phase boundaries safely

Phase boundaries protect role and model separation. A delegated subagent starts
a fresh context with its own role, model, and sandbox, so `$create-plan`,
`$implement-plan`, and `$implement-plan-commit` may cross boundaries by
delegation. This does not authorize the parent to perform a delegated phase
itself or let an implementer review its own work.

## Plans and batches

Plans live as separate numbered files under `plans/`, one work item per file.
Plan numbers are `max(existing number) + 1`; never reuse a gap. Tasks appear as
`###` headings under `## Tasks`, and each heading is one default implementation
batch.

After every batch, spawn a fresh independent reviewer to verify that the batch
matches the approved plan and repository requirements. When a project defines
an applicable conventions reviewer, run it beside the correctness reviewer.
Treat every discrepancy as significant: the human may have changed the
repository after the plan was written, so the correct response may be to amend
the plan rather than overwrite their work.

## Evidence before success claims

Before saying work is complete, fixed, building, or passing, run the relevant
verification and show the material result. If verification requires unavailable
hardware, credentials, or access, state the remaining check precisely instead
of claiming success.

Skills live in `~/.agents/skills` and are invoked explicitly with `$skill-name`.
Three are orchestrators — `$create-plan`, `$implement-plan`,
`$implement-plan-commit` — and two are disciplines a run depends on:
`$systematic-debugging` and `$test-driven-development`.

The per-phase skills that used to mirror each step are gone. Every phase now
lives in the agent that runs it, under `~/.codex/agents`, pinned to its own
model and reasoning effort, and reached through an orchestrator. Do not recreate
a phase as a skill: a skill is a route that can be taken *instead* of the
orchestrator, which is how the old per-phase skills drifted into contradicting
the workflow they were meant to support.
