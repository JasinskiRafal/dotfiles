---
name: requesting-code-review
description: Use after completing a plan or a significant feature, before telling the human it's ready to merge, to check the implementation against its plan and requirements. Reviews the diff for correctness, scope creep, and missed requirements, and reports findings honestly. Use whenever the human asks for a review or you've finished something substantial.
---

# Requesting Code Review

Before declaring a body of work ready, review it against what it was supposed to
do — critically, not as a rubber stamp.

## What to review against

- The plan file it came from (does every task's intent actually appear in the
  diff?).
- The stated requirements and constraints (target, memory, timing, allowed
  dependencies).
- Scope: did the change do only what was asked, or did it drift?

## How to do it

1. Get the diff of what changed (`git diff` — read-only, allowed).
2. Walk it against the plan/requirements. For each finding, note severity:
   blocking (wrong behavior, violated constraint), should-fix (fragile,
   unclear), or nit (style, optional).
3. Check specifically for: off-by-one and boundary handling, error/failure
   paths, resource lifetimes (buffers, handles, interrupts on embedded), and
   anything the plan marked out-of-scope sneaking in.
4. Report findings grouped by severity. Be direct — surface real problems even
   if the human seemed happy. Do not invent problems to look thorough; if it's
   clean, say so.

## After review

- If there are blocking findings, propose fixes (via `systematic-debugging` if a
  cause needs investigating) before calling it ready.
- Do not commit, merge, or open a PR yourself. When it's genuinely ready, tell
  the human it's ready and give the exact git commands they might run.
