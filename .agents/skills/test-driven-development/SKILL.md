---
name: test-driven-development
description: Run test-driven development only when the human explicitly asks for it or an approved plan explicitly requires a test. Use for pure logic, parsers, and state machines; avoid hardware-coupled work where the harness outweighs the code.
---

# Test-driven development (opt-in)

This workflow does not add tests by default. First confirm that the selected
unit is worth testing: pure logic, a protocol parser, or a state machine are
good candidates. For hardware-coupled code where a rig would dwarf the unit,
explain that and suggest a manual or on-target check instead.

For each desired behavior:

1. **Red:** write one test, run it, and observe it fail.
2. **Green:** implement the smallest production change that makes it pass, then
   run it again.
3. **Refactor:** improve the code while the test remains green.

Avoid testing mocks instead of behavior, production code paths that exist only
for tests, and mocks of dependencies you do not understand. Do not change Git
state. When the requested cycle and suite pass, show the evidence, end with
`TDD cycle complete`, and stop.
