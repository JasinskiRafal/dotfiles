---
name: brainstorming
description: Refine a rough feature, change, or problem into a concrete design before writing code or an implementation plan. Use for underspecified work; skip it for mechanical, fully specified tasks.
---

# Brainstorming

Turn a vague idea into a design solid enough to plan from. Produce a shared
understanding of what to build and why, not code or a task list.

1. Restate the goal and confirm the understanding.
2. Ask only the questions whose answers would change the design: constraints,
   interfaces, failure modes, dependencies, target environment, and definition
   of done. Ask a few at a time.
3. When there are real alternatives, offer two or three with their tradeoffs.
   Recommend one, but let the human choose.
4. Validate the design incrementally rather than presenting one large,
   unconfirmed proposal.
5. When the design is concrete enough to implement, summarize it briefly.

Do not write code, create a plan, add tests, or advance to another phase. End
with `Brainstorming complete` and suggest `$writing-plans` as the next step.
If the human asks to explore or refine the design, continue within this phase.
