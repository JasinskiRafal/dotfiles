---
name: test-driven-development
description: The write-failing-test-first discipline this workflow runs on. Testing is mandatory and tests run natively on the host, so this is the default cycle for any behavior change, not an opt-in mode. Hardware-coupled code gets a host-testable seam rather than an exemption.
---

# Test-driven development

This is the default cycle, not an opt-in mode. Tests are part of the code: every
behavior arrives with a test that proves it, and the test comes first.

Tests run on this host, directly — natively compiled and executed by the
project's own test runner, in one command the human can re-run. Never
cross-compiled to a target, flashed to a device, or run in a container, emulator,
simulator, or over a network. Reuse the already-configured build directory and
its incremental command (`meson test -C <dir>`, `ctest --test-dir <dir>`); never
re-configure it, `--wipe` it, or create a second one.

Hardware-coupled code is the normal case here, and the normal answer is a seam:
the logic behind an interface you can test natively, with the register-poking
part left thin enough that its correctness is obvious. Look for that seam before
concluding anything is untestable. Only when no seam exists without changing the
agreed design do you stop — say what blocks the host test, name the seam needed,
and let the human decide. An on-target or manual check is an addition to a host
test, never a substitute.

For each desired behavior:

1. **Red:** write one test, run it, and observe it fail.
2. **Green:** implement the smallest production change that makes it pass, then
   run it again.
3. **Refactor:** improve the code while the test remains green.

Avoid testing mocks instead of behavior, production code paths that exist only
for tests, and mocks of dependencies you do not understand. Do not change Git
state. When the requested cycle and suite pass, show the evidence, end with
`TDD cycle complete`, and stop.
