---
name: systematic-debugging
description: Debug a bug, failure, unexpected behavior, or build error by proving the root cause before applying a minimal fix. Use whenever the cause is not already established.
---

# Systematic debugging

Understand before changing code. Do not propose a fix until the cause is
demonstrated.

1. **Investigate.** Reproduce the failure reliably. Compare observed and
   expected behavior, then trace where the invalid state first appears. Use
   logging, assertions, a debugger, or targeted inspection rather than guesses.
   On embedded targets, consider timing, memory layout, ISRs, and hardware
   state.
2. **Analyze.** Look for the broader pattern and related instances of the same
   defect.
3. **Hypothesize and test.** State one specific, falsifiable cause. Run the
   smallest check that confirms or refutes it. If it is refuted, return to
   investigation.
4. **Implement.** Make the minimal change that addresses the proven cause, then
   rerun the reproduction and show the result.

Never change Git state. When verification has passed, end with `Debugging
complete` and stop; suggest `$verification-before-completion` only as the next
human-chosen phase.
