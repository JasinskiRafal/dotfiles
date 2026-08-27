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
- **Number is `max + 1`** — the highest number in `plans/*.md`, plus one. Never the
  first gap, and never a reused number: gaps stay gaps so that every citation of a
  number, in a review note or a commit message, stays resolvable.

  ```sh
  ls plans/*.md 2>/dev/null | sed 's#.*/##' | cut -d- -f1 | sort -n | tail -1
  ```

  If a file with that number already exists, **halt** rather than creating a second
  file sharing it. The looser "next unused number" rule reliably produces collisions
  once two components both get to decide.
- One work item per file. If a feature is large, split into multiple numbered
  files and cross-reference them — and say so, because splitting is the human's
  call, not a way to fit more into one run.

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
running `/implement-plan <plan file>`.

## Rules

- **Do not include tests unless the human asked for them.** Testing is opt-in
  on this project. If tests are wanted, they appear as explicit tasks; otherwise
  verification steps are things like "builds clean", "runs on target",
  "manual check of X".
- **Never write git operations into a plan.** No branch/commit/merge tasks —
  version control is the human's job (see CLAUDE.md).
- Keep tasks small enough to review in a batch. If a task can't be verified,
  it's too vague — refine it.
- **Write the minimum plan that delivers the design.** No interface with one
  implementation, no factory for a single product, no config knob for something the
  design never varies, no "so we can later…" — later is not in this plan. Reuse what
  the repository already has rather than planning a new helper beside it.
- **One verification step that proves a behavior beats five that circle it.** Every
  step is a command an implementer runs on every batch and every fix pass, so a
  redundant check is paid many times over.
- End by telling the human the plan file path and asking whether to execute it.
