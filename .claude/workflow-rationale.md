# Why the workflow is shaped this way

Design rationale for the loop described in `.claude/CLAUDE.md`. Nothing here is a
rule — the rules live in that file and in each command's own body. This is the
reasoning behind them, kept out of the always-loaded file because it is only
needed when changing the workflow itself.

## Effort is priced by how narrow the job is, not by how important it is

agent handed a scope it has not seen and asked what is worth reporting earns high
effort; one handed a path, a line and a claim to check usually settles it on the
first look, and it is the one that runs many times over. That is why `auditor`
sits at high and `auditor-verify` at medium, and why `verifier` — which runs a
command and reports what it printed — sits at low. There is no
`implementer`, `test-writer`, `planner` or `debugger` agent: implementing,
writing tests, writing and amending plans, and debugging are all things the
commands do themselves, on the model their own frontmatter pins.

## Why writing is inline, reading is spawned, and spawns go out together

**Why writing is inline.** A cold spawn's expensive half was never the code — it
was re-deriving the build directory, the layout and the conventions, once per
spawn and again per fix pass. The command already holds all of it: it read the
plan, it established the baseline, it has every earlier batch in view. Handing
that to a fresh agent means writing a brief to reconstruct what the context
already knows, waiting for it to re-read the plan, and reconciling a summary
against the tree. For work the orchestrator can simply do, that is pure overhead.

**Why reading is spawned.** Not cost — it *cannot* be done inline. A reviewer
that also wrote the code is not an independent second look, it is the author
re-reading their own reasoning. The property the loop rests on is that **the
reader never wrote what it reads and cannot see why it was written that way.**
That depends only on the reviewer being separate, so it survives the writing
moving inline — and it is why review is the one thing that is never inline, at
any size, on any round, however obvious the finding looks.

**Why spawns go out together.** Read-only agents cannot conflict with each other,
so a step needing two reviewers, five audit lenses, or one verify pass per
finding issues them in one message and pays one wall-clock. A parallel step that
was serialized is a defect, and the metrics blocks report
`max_concurrent_spawns` so it is visible.

## What the split gives up, and what replaces it

`implementer` could not tune the test to the code, because neither saw the
other's work. With both inline that pressure is real: a test authored beside its
implementation tends to assert what the code does rather than what the behavior
should be. Three things hold the line, and none is optional — RED demonstrated
*and recorded verbatim* before any production edit exists; the reviewer
explicitly briefed to audit the test as well as the code, asking whether the
assertion would pass without the production change; and the RED-to-GREEN record
per batch as a required report section, with any test *changed* rather than
added called out by itself.

## Why the step boundary is strict

Why this is strict: each command pins its own model and effort in its own
frontmatter — `/review-project`, `/create-plan` and `/implement-plan` on Opus,
`/debug` and all three assisting commands on Sonnet.
Skills that get auto-loaded mid-session do NOT switch the model; they run on
whatever model the session is already on. So if you rolled from one phase into
the next on your own, you'd run it on whatever model the session happened to be
on rather than the one chosen for that phase. Requiring the human to start each
step via its command is exactly what keeps the model correct. **Never cross a
phase boundary without the human.**

## A pinned model crosses a boundary safely; rolling forward does not

The rule protects the *model*, not the ceremony. Two things pin a model, and both
count: a subagent pins one in its own frontmatter, and **a slash command pins one
in its own frontmatter too**. Either way the phase runs on a model chosen for it
rather than on whatever the session happened to be on.

That is why `/create-plan` and `/implement-plan` may run several phases in one
invocation. Each writes its own artifact on the model its frontmatter pins —
`/create-plan` the plan, `/implement-plan` the tests and the code — and delegates
every *reading* phase, concurrently: `/create-plan` to brainstormer,
plan-reviewer and plan-simplifier, `/implement-plan` to reviewer and verifier.
Neither orchestrator reviews what it wrote.

What makes this affordable is that the orchestrator establishes the project
**once** — the build directory, the incremental build and test commands, the
layout and conventions — and then keeps it, because it is the thing doing the
work rather than briefing someone else to. Read-only spawns get the parts they
need. No spawn re-runs project setup: re-configuring or wiping a configured build
tree is forbidden to every spawned agent, always.

The orchestrator does it at exactly **two scheduled points**: once before the
first batch, to establish a baseline that actually builds and whose suite is
green — otherwise no later failure can be attributed to a batch — and once at the
closing gate, so the completion claim is not an artifact of incremental state.
Everything in between is strictly incremental. `rm -rf` on a build tree remains
mine; the build system's own `--wipe`/`--reconfigure`/`--fresh` is the
orchestrator's at those two points.

Every agent and every command in this workflow states both `model:` and `effort:`
explicitly. Neither is left to inherit the session's, and neither should be added
without setting both.

This licenses nothing in-session. Continuing into the next phase yourself, on the
current session's model, is still forbidden — and both orchestrators still stop
for the human at their own consent points (`/create-plan` asks its design
questions and stops before implementation; `/implement-plan` halts rather than
guessing).

## Why the per-phase commands and skills were removed

boundary I want to stand at. The per-phase loop commands that used to exist
(`/brainstorm`, `/plan`, `/execute`, `/tdd`) are gone, and so are the per-phase
skills that mirrored them — every loop phase now lives either in the command that
runs it, where it writes, or in the read-only agent it spawns, where it reads. Two skills remain because a
command depends on each: `systematic-debugging`, which is the substance of
`/debug`, and `test-driven-development`, which is the discipline the mandatory
testing rule above runs on.

that shadows one. What made the old per-phase skills a problem was that a skill
sits in every session's listing as a route the model can take *instead* of the
command, on whatever model the session happens to be on — so it drifted into
contradicting the command it was meant to support. A command with `model:` and
`effort:` in its own frontmatter does not have that defect; a bare skill does.
