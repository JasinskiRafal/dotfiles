---
description: Debug a failure by finding the root cause before fixing
argument-hint: <the bug / failure / wrong behavior>
model: sonnet
effort: high
---
Find the root cause of the problem below, prove it, then fix it. **You do this inline, in this
context** — debugging changes files, so it is not delegated. The only thing you may spawn is a
read-only `verifier`, and only per the last section.

**First, read `~/.claude/skills/systematic-debugging/SKILL.md` in full and follow its four
phases in order:** investigate, analyze the pattern, hypothesize and test, then implement.

## The discipline that matters

- **Reproduce first.** If you cannot reproduce it, your job this pass is to report exactly what
  you tried, what you observed instead, and what I need to run or capture (hardware attached,
  logs, target state) for the next attempt. That is a legitimate outcome — a guessed fix is not.
- **Instrument, do not guess.** Logging, asserts, a debugger, memory inspection. On embedded
  targets consider timing, memory layout, ISR interaction and hardware state — not just the
  line that crashed.
- **State the hypothesis before testing it**, in falsifiable form, including the result that
  would disprove it. "Change X and see" does not count.
- **No fix before the cause is proven.** If the check refutes the hypothesis, go back to
  investigating. If the cause is not proven, stop and say so plainly rather than shipping a
  speculative fix.
- **Minimal fix.** Address the proven cause and nothing else. If the same mistake appears
  elsewhere, list those sites rather than rewriting them all unasked.
- **Clean up your instrumentation** before reporting, unless it is genuinely worth keeping —
  and say which you did.

## Add the regression test — this is not optional

Testing is mandatory here, and **a bug is a missing test by definition.** Write the test that
reproduces it, show it **fail on the host for the right reason**, then fix, then show it pass.
It stays in the suite as the regression guard.

A throwaway reproduction script is not that test — it proves the bug, it does not prevent its
return. Tests run natively on this machine, by the project's own runner, in one command I can
re-run: never cross-compiled to a target, flashed to a device, or run in a container or
emulator. Where the bug genuinely cannot be reproduced by a host test, say what blocks it and
what seam would be needed — that is a design question for me, not a licence to skip it.

**Never make a test pass by weakening it.** If an existing test is wrong, say so and stop.

## Report back

1. **Symptom** — observed vs expected, and the exact repro.
2. **Root cause** — where the invalid state first appears, with the evidence that proves it:
   instrumentation output, not reasoning about the code.
3. **Hypothesis and test** — what you predicted, what would have refuted it, what the check
   actually showed.
4. **Fix** — the change made, file by file, and why it is minimal.
5. **Re-verification** — the regression test failing before and passing after, plus the whole
   host suite, with real output.
6. **Same-shape risks** — other places this class of bug may exist.

If the cause is not proven, stop at step 3.

## Where an independent check is worth the spawn

You wrote the fix, so you are not the one to confirm it. Where the fix is more than a line or
the evidence is contested, **spawn a fresh read-only `verifier`** with the repro command and
what the output should be, and put its verdict in the report. For an obvious one-line fix with
a green regression test, your own output is the evidence — say so rather than spawning.

Fix in place; leave git to me. Once fixed and re-verified, signal "Debugging complete" and
**stop.** Do not move on to other work unless I ask.

Problem: $ARGUMENTS
