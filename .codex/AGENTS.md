# Working agreements

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
- the commit is a provisional scratch commit with the workflow's mechanical
  subject.

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

## Testing is opt-in

Do not introduce tests or use test-driven development unless the human asks for
it explicitly, invokes `$test-driven-development`, or an approved plan
explicitly requires a test. This workflow can cover embedded targets, where a
test harness may cost more than the code under test. Still run the explicit
verification appropriate to completed work before claiming it works.

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
the reviewed plan.

`$implement-plan` is the unattended back half. It delegates every implementation
and review assignment to a fresh specialized agent and proceeds until the plan
is complete or a hard halt condition occurs. It does not stop between batches.
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

Reusable skills live in `~/.agents/skills`. Invoke one explicitly in Codex with
`$skill-name`, or describe the task so Codex can select the matching guided
phase.
