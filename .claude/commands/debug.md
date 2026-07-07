---
description: Debug a failure by finding the root cause before fixing
argument-hint: <the bug / failure / wrong behavior>
model: sonnet
---
Use the `systematic-debugging` skill on the problem below. Reproduce it, trace to
the root cause with instrumentation, state and test a hypothesis, and only then
apply a minimal fix. Do not propose a fix until the cause is proven. Re-run the
reproduction afterward and show it now passes. Fix in place; leave git to me.

Once fixed and re-verified, signal "Debugging complete" and STOP. Do not move on
to other work unless I ask.

Problem: $ARGUMENTS
