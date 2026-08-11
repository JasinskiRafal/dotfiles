---
name: verification-before-completion
description: Verify work with real command output immediately before claiming it is complete, fixed, building, or passing. Use before any completion claim or before suggesting a commit or pull request.
---

# Verification before completion

Evidence comes before assertions. Before saying work is done, fixed, building,
or passing:

1. Identify the specific verification for the claim: a build, targeted command,
   run on target, or check named in the plan.
2. Run it and capture the material output.
3. State the result only after that evidence exists, and include the relevant
   evidence in the report.

Apply this to individual plan tasks, a complete plan, and bug fixes. A clean
diff or code inspection is not verification. If required hardware or access is
unavailable, say exactly what the human must run and what outcome to expect;
never substitute a success claim.

Do not commit or push. End with `Verification complete` plus the evidence and
stop.
