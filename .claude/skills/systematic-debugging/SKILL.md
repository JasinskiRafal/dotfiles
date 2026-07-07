---
name: systematic-debugging
description: Use on encountering any bug, unexpected behavior, build failure, or wrong output, before proposing or applying a fix. Enforces understanding the root cause before changing code, via a four-phase loop: investigate, analyze patterns, test a hypothesis, then implement. Use whenever something doesn't work and the cause isn't already proven.
---

# Systematic Debugging

Understand before you fix. Most bad fixes come from pattern-matching a symptom
and changing code before knowing why it broke — which often adds a second bug.

## Four phases

### 1. Investigate — find the root cause
Reproduce the problem reliably first. Then trace the failure back to its origin:
what is the actual observed behavior vs expected, and where does the invalid
state first appear? Add instrumentation (logging, asserts, a debugger, memory
inspection) rather than guessing. On embedded targets, consider that the cause
may be timing, memory layout, ISR interaction, or hardware state — not just the
line where it crashed.

### 2. Analyze — look for the pattern
Is this an instance of a broader class of bug? Does the same mistake appear
elsewhere? Understanding the shape of the bug prevents fixing one case and
leaving three.

### 3. Hypothesize and test
State a specific, falsifiable hypothesis about the cause. Devise the smallest
check that would confirm or refute it, and run that check. If refuted, return
to phase 1 — do not proceed on a hunch.

### 4. Implement
Only once the cause is proven, make the minimal change that addresses it. Then
re-run the reproduction and show it now behaves correctly (see
`verification-before-completion`).

## Guardrails

- Do not propose a fix before phase 3 has confirmed the cause.
- "Try changing X and see" is not a hypothesis test unless you can state what
  result would prove or disprove the cause.
- Keep version control out of it — investigate and fix in place; leave commits
  to the human.
