---
name: test-driven-development
description: Use ONLY when the human explicitly asks for test-driven development or invokes /tdd, or when a plan task explicitly calls for a test. This skill is opt-in and off by default because this project includes embedded targets where a test harness can cost more than the code under test. When invoked, it enforces the write-failing-test-first discipline. Do NOT trigger this on your own initiative.
---

# Test-Driven Development (opt-in)

This project does **not** test by default. Only use this skill when the human
has explicitly asked for it, because on embedded targets the toolchain to make a
piece of code testable can be larger and more expensive than the code itself.
When the human decides a given piece is worth testing, this is how to do it well.

## Before writing a test, confirm it's worth it

Briefly check with the human (or with the plan) that this unit is one they want
tested — e.g. pure logic, a protocol parser, a state machine — rather than
hardware-coupled code where a test rig would dwarf the code. If it's the latter,
say so and suggest a manual/on-target check instead.

## The cycle

1. **Red** — write one test that expresses the desired behavior. Run it and
   watch it *fail*. A test that has never failed proves nothing.
2. **Green** — write the minimum code to make it pass. Run it; confirm it passes.
3. **Refactor** — clean up while keeping the test green.

Repeat one behavior at a time.

## Avoid the common traps

- Don't test the behavior of a mock — test the code that uses it.
- Don't add production code paths that exist only for tests.
- Don't mock a dependency you don't understand; understand it first.
- Keep the test's failure meaningful — if you can't make it fail by breaking the
  code, the test isn't checking what you think.

## Boundaries

- Version control stays with the human — do not commit tests for them.
- When done, run the suite and show the passing output
  (`verification-before-completion`).
