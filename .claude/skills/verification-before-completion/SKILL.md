---
name: verification-before-completion
description: Use right before claiming any work is complete, fixed, building, or passing — and before suggesting the human commit or open a PR. Requires running the actual verification commands and showing their real output before making any success claim. Evidence before assertions, always. Use whenever you're about to say "done", "fixed", "it works", or "ready".
---

# Verification Before Completion

Never assert success you haven't observed. "It should work" is not evidence;
the command's output is.

## The rule

Before saying a task is done / fixed / passing:

1. Identify the verification for the claim (build command, run on target, the
   specific check the plan named).
2. **Run it.** Capture the actual output.
3. Only then make the claim — and show the evidence alongside it.

If you cannot run the verification (e.g. it needs hardware you don't have), say
so explicitly and describe exactly what the human needs to run, rather than
claiming success. Do not guess.

## Applies to

- Individual plan tasks (each has its own verification step).
- A full plan before you report it complete.
- Any bug you claim to have fixed — reproduce, fix, then re-run the repro and
  show it now passes.

## What counts as evidence

- Build output showing zero errors (paste the relevant lines, not "it built").
- Program output matching the expected result.
- For embedded targets you can't flash yourself: the compile/link succeeding
  plus a clear statement of what on-target check the human still needs to do.

## What is not verification

- Re-reading your own diff and reasoning that it looks right.
- Assuming a change is correct because the previous one was.
- Marking a plan task done without running its check.

Remember: do not commit or push as part of "finishing". Report the evidence and
let the human decide what to do with version control.
