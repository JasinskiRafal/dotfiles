---
description: Write a detailed implementation plan as a new numbered file in plans/
argument-hint: <feature/work item, or the design to plan>
model: opus
---
Use the `writing-plans` skill. Create a new numbered file `plans/NNN-slug.md`
(pick the next unused number by listing plans/). One work item per file — never
a monolithic plan. Include exact file paths and a verification step per task. Do
NOT add tests unless I explicitly asked. Do NOT put any git operations in the
plan.

When the plan file is written, STOP and signal "Planning complete" with the file
path. Tell me to run `/execute <that file>` next — do not start executing
yourself. If I ask you to refine the plan, keep going within this step.

Work item: $ARGUMENTS
