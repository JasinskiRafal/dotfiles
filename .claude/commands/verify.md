---
description: Prove the work actually does what it claims. Evidence, not assertion.
argument-hint: <what should be true> (optional — defaults to the last change)
model: sonnet
effort: low
---
Verify the work below. If no argument is given, verify the change made in this
session against what I asked for.

Reading the code is not verification. Neither is "this should work." A claim
counts as verified only when a command was run and its real output supports it.

Do this:

1. Restate what is supposed to be true, as a list of separate checkable
   claims. If the work came from a plan file, take the claims from the plan,
   not from what got built.
2. For each claim, name the command that would prove it, then run it.
3. Paste the actual output. Not a summary of the output, not "tests passed" —
   the real text, trimmed to the relevant lines.
4. Mark each claim PASS, FAIL, or UNVERIFIED.

Use UNVERIFIED honestly and often. It is the correct answer for anything that
needs hardware, a target device, a deploy, or a human looking at something.
For each UNVERIFIED claim, give me the exact command to run myself and tell me
what output would count as a pass. Never upgrade UNVERIFIED to PASS by
reasoning about the code.

Distinguish these levels explicitly, because they are routinely conflated:

- it compiles
- it links and starts
- it runs without erroring
- it produces the correct result

A clean build proves the first only. Say which level you actually reached.

Do not fix anything you find here. Verification and repair are separate steps —
mixing them means the failure never gets recorded and the fix never gets
verified. Report the failures and stop.

Finish with a one-line verdict, then wait. If something failed, tell me to run
/debug. Do not run it yourself. Leave git alone throughout.

To verify: $ARGUMENTS
