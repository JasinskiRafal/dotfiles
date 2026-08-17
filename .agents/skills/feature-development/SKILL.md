---
name: feature-development
description: Orchestrate repository feature development through design discussion, planning, strict TDD, independent per-step review, bounded fix loops, and final verification. Use when the human explicitly invokes $feature-development or asks to use the repository's full feature-development workflow.
---

# Feature development

Act primarily as the parent orchestrator. Delegate detailed investigation,
test writing, implementation, and review to the matching project agents. Keep
the agreed design, current plan, current step, commands run, and review status
in the parent context.

Follow all applicable `AGENTS.md` instructions. In particular, never change Git
state or inspect secrets. Explicit invocation of this skill authorizes the
tests required by its strict-TDD workflow.

Use guided checkpoints: stop for the human after design agreement is needed,
after presenting the plan for approval, and after every approved implementation
step. Resume the next phase or step only when the human continues. Do not treat
this skill as the repository's one-shot workflow unless the human separately
and explicitly requests that workflow.

## Agent boundaries

- Spawn the named custom agent for each responsibility: `brainstormer`,
  `planner`, `test-writer`, `implementer`, or `reviewer`.
- Use a fresh agent for every RED, GREEN, and REVIEW assignment. Never reuse an
  implementer as a reviewer.
- Do not run agents that may modify the same files concurrently. Parallelize
  only independent read-only investigation when it materially helps.
- Give each agent only the agreed design, current plan step, relevant paths,
  and evidence it needs. Require concise summaries instead of raw logs.
- Evaluate reviewer findings against the design, plan, repository conventions,
  and test evidence. Do not accept feedback blindly.
- Treat one completed, independently approved plan step as one reviewable batch.

## Phase 1: Brainstorm

1. Spawn a fresh `brainstormer` to inspect the relevant repository code and
   analyze the requested feature without modifying files.
2. Synthesize its proposal for the human. Discuss only significant decisions
   that affect architecture, behavior, risk, compatibility, or scope.
3. Answer repository-discoverable questions through inspection rather than
   asking the human.
4. Record the agreed design and explicit out-of-scope boundaries in the parent
   context.
5. Present the resulting design and stop for explicit human agreement. Do not
   spawn the planner or begin implementation until important decisions are
   resolved and the human approves the design.

## Phase 2: Plan

1. After design agreement, spawn a fresh `planner` with the agreed design.
2. Require small, sequential steps, each covering exactly one independently
   testable behavior and one RED -> GREEN -> REVIEW cycle.
3. Require every step to name expected behavior, the test to add, likely files,
   the focused test command, and relevant regression checks.
4. Check the returned plan for complete design coverage, correct ordering, and
   realistic batch size. Resolve discrepancies before execution.
5. Keep the approved plan in the parent context for the entire workflow. If
   repository instructions require durable plan files, have the parent store
   each work item as a separate numbered file under `plans/`; the read-only
   planner still returns its plan rather than editing files.
6. Present the plan and stop for human approval before Phase 3.

## Phase 3: Strict TDD loop

Execute every approved plan step in order. Never start a later step while the
current step lacks test evidence or reviewer approval.

### RED

1. Spawn a fresh `test-writer` for exactly one planned behavior.
2. Require it to add only the test, run the focused test, and return the command,
   material failure, and why that failure is expected.
3. Proceed only when the evidence demonstrates RED for the intended missing
   behavior, rather than a syntax, fixture, environment, or unrelated failure.
4. If the test passes before implementation, stop the cycle and investigate
   whether the behavior already exists, the test is wrong, or the plan
   assumption is invalid. Update the design or plan with human agreement when
   that changes scope; do not manufacture a failure.

### GREEN

1. Give the demonstrated failing test and current plan step to a fresh
   `implementer`.
2. Require the smallest correct production change that turns RED into GREEN,
   with no unrelated refactoring or weakened tests.
3. Require the focused test plus the relevant regression tests. Do not proceed
   without material GREEN evidence.

### REVIEW

1. Spawn a fresh `reviewer` with the agreed design and current plan step.
2. Accept only the reviewer's specified `APPROVED` or `CHANGES_REQUIRED`
   response shape.
3. Validate every finding technically. Reject invalid or out-of-scope feedback
   with a concise rationale in the parent context.
4. For valid missing behavior or insufficient coverage, send the issue first
   to a fresh `test-writer`. Missing behavior must produce meaningful RED
   before a fresh `implementer` restores GREEN. A coverage-only test may
   already be GREEN when production behavior is correct; in that case, run the
   relevant regressions and return directly to review without manufacturing a
   production change. For a production defect already exposed by an adequate
   failing test, route it directly to a fresh `implementer`.
5. Spawn a fresh `reviewer` after each fix. Count each review response as one
   iteration and stop after five reviews for the step. If it is still not
   approved, report the unresolved findings and wait for human direction.
6. When the reviewer returns `APPROVED`, report the changed files, focused and
   regression test evidence, review result, and any plan discrepancy. Stop for
   human approval before starting the next plan step.

## Phase 4: Final verification

After every plan step has been approved:

1. Run the complete relevant test suite and retain the material result.
2. Inspect the complete scoped diff against the agreed design and full plan.
3. Spawn a fresh `reviewer` for an independent final review of the entire
   feature.
4. Validate any `CHANGES_REQUIRED` findings. Fix legitimate findings through
   the same RED -> GREEN discipline, using fresh agents, then rerun the full
   relevant suite and a fresh final reviewer. Limit final review/fix attempts
   to five; report unresolved findings instead of looping indefinitely.
5. Declare completion only when the relevant suite passes, the final reviewer
   returns `APPROVED`, and the implementation matches both the agreed design
   and the approved plan.

If tests require unavailable hardware or access, report the exact remaining
verification and do not claim completion.
