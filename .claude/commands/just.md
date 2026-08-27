---
description: Small, well-understood change. Skip the planning phases.
argument-hint: <the change to make>
model: sonnet
effort: medium
---
Make the change below directly. No plan file, no phase skills, no design
discussion. I already know what I want; you are here to type it.

Rules:

- Read only the files you actually need to touch, plus their immediate
  callers. Do not survey the codebase.
- Make the smallest change that does the job. No adjacent cleanup, no
  renaming, no "while I was in there" refactors, no added abstraction for
  hypothetical future cases.
- Follow the project's existing conventions (CLAUDE.md, surrounding code
  style). Do not introduce a new pattern for a small change.
- Show me the resulting diff and stop. Do not build, deploy, or run anything
  unless I asked for it in the request.
- Leave git alone. No staging, no committing, no branching.

Bail upward if the assumption is wrong. If it turns out this touches more
than two or three files, requires an interface or ownership decision, needs a
new dependency, or you find yourself guessing at intent, stop immediately.
Say what you found and tell me to run /create-plan instead. Do not
plan it yourself and do not proceed on a guess. A wrong small change is more
expensive than the thirty seconds it costs me to re-scope it.

When you are done, say "Done (unverified) — <one-line summary>" and wait. The
change is untested by construction; say so plainly and never imply it works. If
proving it matters, tell me to run /verify — but do not run it yourself, and do
not suggest any other next command.

Change: $ARGUMENTS
