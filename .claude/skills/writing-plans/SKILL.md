---
name: writing-plans
description: Use once a design is agreed and you need a concrete implementation plan, before starting to write feature code. Produces a detailed, self-contained plan file in plans/ with exact file paths, per-task verification steps, and enough context that an engineer with little prior knowledge of the change could execute it. Use this whenever the human says "write a plan", "plan this out", or moves from design into implementation.
---

# Writing Plans

Produce a plan that someone could execute with minimal back-and-forth. Write it
as a **separate numbered file** in `plans/`, one file per feature or work item.
Never append to or create a single monolithic plan document.

## File convention

- Path: `plans/NNN-short-slug.md` (e.g. `plans/007-uart-dma-ringbuffer.md`).
- Pick the next unused number by listing `plans/`.
- One work item per file. If a feature is large, split into multiple numbered
  files and cross-reference them.

## Required structure

```markdown
# NNN — <title>

## Goal
One paragraph: what this change achieves and why.

## Context
Key facts an executor needs: relevant files, constraints (target, memory,
timing), dependencies allowed/forbidden, assumptions from brainstorming.

## Tasks
Ordered, each independently verifiable. For every task give:
- exact file path(s) to touch
- what to change (concrete — sketch the code or signature where it helps)
- how to verify it (the command to run and the expected result)

## Out of scope
What this plan deliberately does NOT do.

## Open questions
Anything unresolved that the human should decide before execution.
```

## Phase boundary

This is one phase of the loop. When the plan file is written, stop and signal
completion with the path — do not begin executing it. Advancing on your own would
run execution on the wrong model (see CLAUDE.md). The human starts execution by
running `/execute <plan file>`.

## Rules

- **Do not include tests unless the human asked for them.** Testing is opt-in
  on this project. If tests are wanted, they appear as explicit tasks; otherwise
  verification steps are things like "builds clean", "runs on target",
  "manual check of X".
- **Never write git operations into a plan.** No branch/commit/merge tasks —
  version control is the human's job (see CLAUDE.md).
- Keep tasks small enough to review in a batch. If a task can't be verified,
  it's too vague — refine it.
- End by telling the human the plan file path and asking whether to execute it.
