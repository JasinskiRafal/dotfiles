---
name: test-driven-development
description: The write-failing-test-first discipline this project runs on. Testing is mandatory here and tests run natively on the host, so this is the default cycle for any behaviour change, not an opt-in mode. Read it whenever writing a test or turning one green; /implement-plan enforces it per batch via test-writer then implementer.
---

# Test-Driven Development

**This is the default cycle, not an opt-in mode.** Tests are part of the code on
this project: every behaviour arrives with a test that proves it, and the test
comes first. There is no task too small and no "unless the plan asks".

## Tests run on this host, directly

Natively compiled, executed by the project's own test runner on this machine, in
one command a human can re-run. Never cross-compiled to a target, flashed to a
device, or run inside a container, emulator, simulator, or over a network.

Reuse the already-configured build directory and its incremental command
(`meson test -C <dir>`, `ctest --test-dir <dir>`). Never re-configure it, never
`--wipe`, never create a second one.

## Untestable on the host means the design is wrong — find the seam

Hardware-coupled code is the normal case here, and the normal answer is a
**seam**: the logic behind an interface you can test natively, with the
register-poking part left thin enough that its correctness is obvious. Look for
that seam before concluding anything is untestable.

Only when no seam exists without changing the agreed design do you stop: say what
blocks the host test, name the seam you would need, and let the human decide. An
on-target or manual check is an **addition** to a host test, never a substitute —
"it needs the target" is a claim to check, not one to accept.

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
- When done, run the suite and **show the real passing output**. Evidence before
  assertions — a claim that the tests pass is not the same as the output that
  proves it.
