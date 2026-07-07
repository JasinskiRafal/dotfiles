---
name: brainstorming
description: Use before writing any code or implementation plan, whenever the human describes a feature, change, or problem that isn't yet fully specified. Refines a rough idea into a concrete design through questioning, surfacing alternatives, and validating assumptions incrementally. Do NOT use for mechanical, already-specified tasks (e.g. "rename this variable", "bump this dependency").
---

# Brainstorming

Turn a vague idea into a design solid enough to plan from. The goal is a shared,
written understanding of *what* to build and *why* — not code, and not yet a
task list.

## Why this matters

Most bad implementations trace back to a fuzzy starting point. A few minutes of
questioning up front prevents building the wrong thing correctly.

## How to run it

1. **Restate the goal** in your own words and confirm you've understood it.
2. **Ask about the parts that are underspecified.** Prioritize questions whose
   answers would change the design: constraints (memory, timing, target
   hardware, dependencies you're allowed to add), interfaces, failure modes,
   what "done" looks like. Ask a few at a time, not a wall of them.
3. **Offer 2–3 alternative approaches** when they exist, with the tradeoff each
   makes. Recommend one, but let the human choose.
4. **Validate incrementally** — reflect the emerging design back in small pieces
   and check each before moving on, rather than presenting one big design at the
   end.
5. **Stop when the design is concrete enough to write a plan from.** Summarize
   the agreed design in a few sentences and ask whether to proceed to
   `writing-plans`.

## Phase boundary

This is one phase of the loop. When the design is settled, stop and signal
completion — do not roll into planning or coding on your own. Advancing without
the human would run the next phase on the wrong model (see CLAUDE.md). The human
starts the next step by running `/plan`.

## Guardrails

- Do not start writing code during brainstorming.
- Do not assume tests are wanted — testing is opt-in on this project.
- If the human already handed you a fully-specified task, skip this and go
  straight to planning or execution.
