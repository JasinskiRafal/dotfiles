---
name: requesting-code-review
description: Critically review current changes against a plan or requirements, reporting real findings by severity without modifying or committing code. Use when the human asks for a review or after substantial completed work.
---

# Requesting code review

Review the current diff critically, not as a rubber stamp. Do not modify files
while reviewing.

1. Inspect the read-only diff with `git diff` and read the relevant plan or
   requirements.
2. Check every intended task, stated constraint, and out-of-scope boundary.
3. Look specifically for boundary and off-by-one errors, failures and error
   paths, resource lifetimes, concurrency or interrupt interactions, and
   scope creep.
4. Report findings grouped as `blocking`, `should-fix`, and `nit`. For each,
   name the affected location and explain the impact. Do not invent findings;
   say plainly when the diff is clean.

Do not commit, merge, open a pull request, or fix issues during this phase. If
the work is ready, give the human the exact Git commands they might choose to
run. End with `Review complete` and stop.
