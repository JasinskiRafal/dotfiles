---
name: implement-plan-commit
description: Drive one approved plan through the complete implement-plan workflow with provisional per-batch commits enabled. Use only when the human explicitly invokes $implement-plan-commit with a plan path; use $implement-plan for runs that must not change Git state.
---

# Implement plan with commits

Accept exactly one argument: a readable plan path. Do not require or accept a
`--commit` flag.

Read [the canonical implement-plan skill](../implement-plan/SKILL.md) completely,
then follow it as though the human had invoked:

```text
$implement-plan --commit <plan-path>
```

The explicit `$implement-plan-commit` invocation supplies the same commit
authorization as the canonical `--commit` flag. Commit mode is mandatory for
this wrapper: if repository policy or preflight makes commits unavailable, halt
and report the condition instead of silently continuing in unflagged mode.

Treat the canonical skill as the sole source of orchestration, verification,
review, staging, commit, halt, and reporting rules. If this wrapper and the
canonical skill conflict, preserve this wrapper's mandatory-commit behavior and
otherwise follow the canonical skill.
