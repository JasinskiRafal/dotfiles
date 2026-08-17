---
name: feature-development
description: Orchestrate repository feature development through design discussion, planning, strict TDD, independent per-step review, bounded fix loops, and final verification. Use when the human explicitly invokes $feature-development or asks to use the repository's full feature-development workflow.
---

# Feature development

Act primarily as the parent orchestrator. Delegate detailed investigation, test
writing, implementation, and review to the matching project agents. Keep the agreed
design, current plan, current step, commands run, and review status in the parent
context.

Follow all applicable `CLAUDE.md` / `AGENTS.md` instructions. In particular, never
change Git state or inspect secrets. Explicit invocation of this skill authorizes the
tests required by its strict-TDD workflow — that is the one standing exception to this
project's opt-in testing rule, and it applies only to the behaviors in the approved
plan.

Use guided checkpoints: stop for the human when design agreement is needed, after
presenting the plan for approval, and after every approved implementation step. Resume
the next phase or step only when the human continues. This skill is **not** a one-shot
autonomous workflow — do not treat it as one unless the human separately and explicitly
asks for that.

This is the Claude-side counterpart of `.agents/skills/feature-development/SKILL.md`;
keep the two in step when you change either.

## Agent boundaries

- Spawn the named agent for each responsibility: `brainstormer`, `planner`,
  `test-writer`, `implementer`, `reviewer`, plus `debugger` and `verifier` where noted
  below. Each carries its own pinned model and tool restrictions.
- Use a **fresh agent for every RED, GREEN, and REVIEW assignment.** Never reuse an
  implementer as a reviewer.
- Never run agents that may modify the same files concurrently. Parallelize only
  independent read-only investigation, and only when it materially helps.
- Give each agent only what it needs: the agreed design, the current plan step, relevant
  paths, and the evidence in hand. Require concise summaries, not raw logs.
- Evaluate findings against the design, plan, repository conventions, and test evidence.
  Do not accept agent feedback blindly.
- Treat one completed, independently approved plan step as one reviewable batch.

## Phase 1: Brainstorm

1. Spawn a fresh `brainstormer` to inspect the relevant code and analyze the requested
   feature without modifying files.
2. Synthesize its proposal for the human. Discuss only significant decisions — those
   affecting architecture, behavior, risk, compatibility, or scope.
3. Answer repository-discoverable questions by inspection rather than asking the human.
4. Record the agreed design and the explicit out-of-scope boundaries in your own context.
5. Do not plan or implement until important decisions are resolved. Stop at the design
   checkpoint whenever human input or confirmation is required.

## Phase 2: Plan

1. After design agreement, spawn a fresh `planner` with the agreed design.
2. Require small, sequential steps, each covering exactly one independently testable
   behavior and one RED → GREEN → REVIEW cycle.
3. Require every step to name the expected behavior, the test to add, likely files, the
   focused test command, and relevant regression checks.
4. Check the returned plan for complete design coverage, correct ordering, and realistic
   batch size. Resolve discrepancies before execution. Send it back to a fresh `planner`
   rather than patching a bad plan yourself.
5. The `planner` writes the durable plan file as `plans/NNN-slug.md`, one work item per
   file, as CLAUDE.md requires. Keep that path and the approved plan in your context for
   the whole workflow.
6. Present the plan and **stop for human approval** before Phase 3.

## Phase 3: Strict TDD loop

Execute every approved plan step in order. Never start a later step while the current one
lacks test evidence or reviewer approval.

### RED

1. Spawn a fresh `test-writer` for exactly one planned behavior.
2. Require it to add only the test, run the focused test, and return the command, the
   material failure, and why that failure is expected.
3. Proceed only when the evidence demonstrates RED **for the intended missing behavior** —
   not a syntax, fixture, environment, compilation, or unrelated failure.
4. If it returns `RED_NOT_DEMONSTRATED` or the test passes before implementation, stop the
   cycle and investigate: does the behavior already exist, is the test wrong, or is the
   plan assumption invalid? Route it to a fresh `debugger` when the answer is not obvious
   from the report. If the answer changes scope, get human agreement and update the design
   or plan. Never manufacture a failure.

### GREEN

1. Give the demonstrated failing test and the current plan step to a fresh `implementer`.
2. Require the smallest correct production change that turns RED into GREEN — no unrelated
   refactoring, no scope expansion, no weakened tests.
3. Require the focused test plus the relevant regression tests. Do not proceed without
   material GREEN evidence.
4. If a check fails for an unexplained reason, send it to a fresh `debugger` for a proven
   root cause before letting any implementer touch it again.

### REVIEW

1. Spawn a fresh `reviewer` with the agreed design and the current plan step.
2. Accept only its specified response shape: `APPROVED` or `CHANGES_REQUIRED` with the
   four-bullet findings.
3. Validate every finding technically. Reject invalid or out-of-scope feedback with a
   concise rationale recorded in your context.
4. For valid missing behavior or insufficient coverage, send the issue first to a fresh
   `test-writer`, require a meaningful RED, then use a fresh `implementer` to restore
   GREEN. For a production defect already exposed by an adequate failing test, route it
   directly to a fresh `implementer`.
5. Spawn a fresh `reviewer` after each fix. Count each review response as one iteration
   and **stop after five reviews for the step.** If it is still not approved, report the
   unresolved findings and wait for human direction.
6. When the reviewer returns `APPROVED`, report the changed files, focused and regression
   test evidence, the review result, and any plan discrepancy. **Stop for human approval
   before starting the next plan step.**

## Phase 4: Final verification

After every plan step has been approved:

1. Run the complete relevant test suite and retain the material result. Spawn a
   `verifier` for the completion evidence gate — including any build or on-target check
   the plan named that the test suite does not cover.
2. Inspect the complete scoped diff against the agreed design and the full plan.
3. Spawn a fresh `reviewer` for an independent final review of the entire feature.
4. Validate any `CHANGES_REQUIRED` findings. Fix legitimate ones through the same
   RED → GREEN discipline with fresh agents, then rerun the full relevant suite, a fresh
   `verifier`, and a fresh final `reviewer`. **Limit final review/fix attempts to five**;
   report unresolved findings instead of looping indefinitely.
5. Declare completion only when the relevant suite passes, the `verifier` confirms the
   evidence, the final `reviewer` returns `APPROVED`, and the implementation matches both
   the agreed design and the approved plan.

If tests require unavailable hardware or access, report the exact remaining verification
and do not claim completion.

## Finish

Report the plan path, the steps completed, changed files, the verification evidence, the
review history per step, decisions you resolved without the human, and any remaining
manual or on-target checks. Never change Git state — give the human the exact commands
they may choose to run.
