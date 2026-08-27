---
description: Critical review of the change against what was actually asked for.
argument-hint: <what to review> (optional — defaults to the working-tree diff)
model: sonnet
effort: high
---
Review the change below. If no argument is given, review the current
uncommitted diff (read git state only — never modify it).

Your job is to find problems. A review that finds nothing is a review that was
not performed. If the change is genuinely clean, say so in one line and spend
your effort on the risks that remain rather than on praise.

Review against intent first. Re-read the plan file or the original request,
then check:

- Does it do what was asked?
- Does it do anything that was *not* asked? Scope creep is a defect. Flag
  every line that is not traceable to the request.
- Was something in the request quietly dropped or stubbed?

Then review the code itself. Prioritise the failure modes that survive review
in this kind of codebase:

- Ownership and lifetime. Dangling references, objects outliving their buffer,
  unclear who frees what.
- Error paths. Return values ignored, exceptions swallowed, failure leaving
  partially-mutated state. Trace what happens when each call fails, not just
  when it succeeds.
- Resource handling. Leaks on the error path, acquisition without release,
  blocking or allocating calls on a hot or real-time path.
- Concurrency. Shared state without synchronisation, assumptions about which
  thread or callback context the code runs on.
- Boundaries. Off-by-one, integer width and signedness, unchecked casts,
  unvalidated external input.
- API misuse. Calling something in the wrong state or wrong order, ignoring a
  documented contract.

Report each finding as: severity (blocker / should-fix / nit), file and line,
what goes wrong, and the concrete scenario that triggers it. A finding without
a triggering scenario is a style opinion — mark it as a nit or drop it.

Do not fix anything. Do not rewrite the code. Do not touch git. Report,
then stop and wait for me to decide what to act on.

To review: $ARGUMENTS
