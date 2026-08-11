---
name: writing-plans
description: Write a detailed, self-contained implementation plan in plans/ after a design is agreed and before feature code is written. Use when the human asks to plan a feature or work item.
---

# Writing plans

Create one detailed plan that another engineer could execute with minimal
back-and-forth. Do not implement the plan in this phase.

1. List `plans/` and choose the next unused number.
2. Create `plans/NNN-short-slug.md`; one work item per file. Split large work
   into multiple plans and cross-reference them.
3. Use this structure:

```markdown
# NNN — <title>

## Goal
What the change achieves and why.

## Context
Relevant files, constraints, allowed or forbidden dependencies, and assumptions.

## Tasks
Ordered tasks. For each: exact paths, a concrete change description, and a
verification command or manual check with its expected result.

## Out of scope
What this plan deliberately does not cover.

## Open questions
Anything the human must decide before execution.
```

Tests are opt-in: include test tasks only when the human explicitly requested
them. Never include Git operations. Keep tasks small enough to review in
batches, and refine any task that lacks a verifiable outcome.

When the file is written, stop. End with `Planning complete — <path>` and
suggest `$executing-plans <path>`. Do not start implementation unless the human
explicitly asks to execute it.
