---
description: Opt into test-driven development for a specific unit
argument-hint: <the unit/behavior to test>
model: sonnet
---
Use the `test-driven-development` skill for the unit below. First confirm this
unit is actually worth testing (pure logic / parser / state machine) rather than
hardware-coupled code where a rig would dwarf the code — if the latter, tell me
and suggest a manual check instead. Otherwise: write a failing test, watch it
fail, write minimal code to pass, refactor. Do not commit for me.

When the cycle is done and the suite passes, signal "TDD cycle complete" and
STOP. Do not continue to other units unless I ask.

Unit to test: $ARGUMENTS
