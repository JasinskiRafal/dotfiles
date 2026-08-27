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
- the batch has completed its verification and independent reviews cleanly, with
  every accepted finding fixed and independently re-reviewed, or rejected with a
  stated rationale;
- the parent stages only the paths on the batch's own authoritative changed-file
  list, plus the plan file when its progress markers changed;
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

Four explicit skills provide orchestration around the same phases — each writing
its own artifact inline and dispatching its reading concurrently:

```text
$review-project         scope -> audit N lenses -> refute each finding -> reviews/NNN-*.md
$create-plan            brainstorm -> plan -> review + simplify -> refine once -> hand over
$implement-plan         implement -> review (at most twice) -> fix -> next batch -> closing gate
$implement-plan-commit  same as $implement-plan --commit; commits are mandatory
```

`$review-project` starts from no request at all: it asks what the code *is*, on
several lenses concurrently, adversarially verifies every finding, and writes an
evidenced report under `reviews/`. It changes nothing and never flows into
`$create-plan` on its own — choosing which findings become work is the human's.
Review reports are numbered `max(existing) + 1`, cited as "review NNN, finding
A4", and never edited once written: a superseded review stays as it was and a new
audit takes a new number.

`$create-plan` is the interactive front half. It delegates repository inspection
and plan review to fresh read-only agents, **writes the plan itself**, asks the
human only for decisions inspection cannot settle, and stops after handing over
the reviewed plan. It reviews on **two concurrent lenses** — `plan-reviewer` for
correctness and coverage, `plan-simplifier` for minimality — and adjudicates
both in one pass. Where they conflict, coverage wins. The weight of the pipeline
is deliberately on this end: a defect caught in the plan costs one refine round,
the same defect caught during execution costs a batch, a review, an amendment,
and every batch built on it since.

`$implement-plan` is the unattended back half. It **writes each batch's tests and
production change itself** and dispatches every review and verification to a
fresh read-only agent, proceeding until the plan is complete or a hard halt
condition occurs. It does not stop between batches: each batch is specified by a
test proven to fail, verified against its own task before review, and then judged
by a reviewer that did not write it and cannot see why it was written that way —
strictly more than a human glance at a checkpoint would give it.

What makes this affordable is that the orchestrator establishes the project
**once** — the build directory, the incremental build and test commands, the
layout and conventions — and then keeps it, because it is the thing doing the work
rather than briefing someone else to. Read-only spawns receive the parts they
need. No spawn re-runs project setup: re-configuring, wiping, deleting, or
duplicating a configured build tree is forbidden to every spawned agent, always.

The orchestrator does it at exactly two scheduled points: once before the first
batch, to establish a baseline that builds and whose suite is green — otherwise no
later failure can be attributed to a batch — and once at the closing gate, so the
completion claim is not an artifact of incremental state. Everything in between is
strictly incremental. `rm -rf` on a build tree remains the human's; the build
system's own `--wipe`/`--reconfigure`/`--fresh` is the orchestrator's at those two
points.
`$implement-plan-commit` is its commit-on wrapper for invocations where the
human does not want to remember the optional flag. Only an explicit invocation
selects an orchestrator; ordinary planning and implementation requests continue
to use the guided workflow.

Naming an individual phase skill still selects only that phase. A request to
continue or refine work within the current phase may proceed, but it does not
authorize rolling into another phase in the current agent context.

### Writers run inline; readers are dispatched, and dispatched together

**One rule decides where a phase runs. A phase that changes a file runs inline, in
the orchestrator's own context. A phase that only reads runs as a spawned agent,
and every spawn a step needs goes out in a single dispatch.**

`~/.codex/agents` therefore holds **read-only agents only** — `auditor`,
`auditor-verify`, `brainstormer`, `plan-reviewer`, `plan-simplifier`, `reviewer`,
and `verifier`, whose `workspace-write` sandbox exists solely so build and
verification commands may emit ordinary artifacts and which may never edit source.
There is no `implementer`, `batch-implementer`, `test-writer`, `plan-writer`, or
`planner` agent: implementing, writing tests, and writing plans are things the
orchestrators do themselves.

**Writing is inline** because a cold spawn's expensive half was never the code —
it was re-deriving the build directory, the layout, and the conventions, once per
spawn and again per fix pass. The orchestrator already read the plan, established
the baseline, and holds every earlier batch.

**Reading is dispatched** because it cannot be done inline: a reviewer that also
wrote the code is the author re-reading their own reasoning. The property the
workflow rests on is that **the reader never wrote what it reads and cannot see
why it was written that way.** That depends only on the reviewer being separate,
so it survives the writing moving inline — and it is why review is never inline, at
any size, on any round, however obvious a finding looks.

**Dispatch together.** Read-only agents cannot conflict, so a step needing two
reviewers, five audit lenses, or one refutation per finding issues them in one
message and pays one wall-clock. A parallel step that was serialized is a defect.

**Never edit a file while a spawn is in flight.** Spawns keep running while the
orchestrator works, so nothing mechanically stops it starting the next batch, or a
fix, over files a reviewer is still reading. A reviewer that reads a file mid-edit
reports findings against a state that no longer exists. Finish writing, verify,
assemble the changed-file list, dispatch — then touch nothing until every reader of
that scope has reported.

**What the split gives up, and what replaces it.** A separate `test-writer` could
not tune its test to code it never saw. With both inline that pressure is real: a
test authored beside its implementation drifts toward asserting what the code does
rather than what the behavior should be. Three controls replace it, none optional —
RED demonstrated and recorded verbatim before any production edit exists; the
reviewer explicitly briefed to audit the test as well as the code, asking whether
the assertion would pass without the production change; and the RED-to-GREEN record
per batch as a required report section, with any test changed rather than added
called out by itself.

Phase boundaries still protect role and model separation, and a dispatched subagent
still starts a fresh context with its own role, model, and sandbox. This does not
authorize the orchestrator to review its own work.

**Effort is priced by how narrow the job is, not by how important it is.** An agent
handed a scope it has not seen and asked what is worth reporting earns `xhigh`; one
handed a path, a line, and a claim to check usually settles it on the first look,
and it is the one that runs many times over. That is why `auditor` sits at `xhigh`
and `auditor-verify` at `high`.

### Two reviews, never three

Any review-fix-rereview cycle is capped at **two rounds**: the review, one fix
pass, one re-review. That holds per batch in `$implement-plan`, for its closing
gate, and for the plan review in `$create-plan`. Checking a third time is overkill —
two passes failing on the same findings says the *assignment* is wrong rather than
the execution, and another reviewer will not discover that.

What happens instead of a third review is adjudication, not another spawn: re-read
the surviving findings assuming the reviewer may be wrong and reject what is
mistaken, with the rationale in the report; and diagnose where a failure is
unexplained. **A batch closed on stated rejections, or a plan handed over with one
named open finding, is a legitimate outcome** — better than one ground through a
third round. The human's eyes are cheaper than a fourth agent's, and the report is
where they use them. Where neither move clears it, halt.

## Plans and batches

Plans live as separate numbered files under `plans/`, one work item per file.
Plan numbers are `max(existing number) + 1`; never reuse a gap. Tasks appear as
`###` headings under `## Tasks`, and each heading is one default implementation
batch.

After every batch, dispatch a fresh independent read-only reviewer to verify that
the batch matches the approved plan and repository requirements — never judge your
own batch, at any size. When a project defines
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
Four are orchestrators — `$review-project`, `$create-plan`, `$implement-plan`,
`$implement-plan-commit` — and two are disciplines a run depends on:
`$systematic-debugging` and `$test-driven-development`. The orchestrators now
depend on those two directly, because the phases that used to carry that
discipline in a spawn's own instructions run inline.

The per-phase skills that used to mirror each step are gone. Every phase now lives
either in the orchestrator that runs it, where it writes, or in the read-only agent
it dispatches, where it reads. Do not recreate a phase as a skill: a skill is a
route that can be taken *instead* of the orchestrator, which is how the old
per-phase skills drifted into contradicting the workflow they were meant to
support.
