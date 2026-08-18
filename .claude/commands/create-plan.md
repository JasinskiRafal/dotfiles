---
description: Brainstorm a rough idea into an agreed design, then write and review a numbered plan in plans/
argument-hint: <the idea, in your own words>
model: opus
---
Turn the idea at the end of this file into an agreed design, then into a reviewed plan file
under `plans/`. You orchestrate: you delegate the design, the writing, and the review, and
you adjudicate. You do not write the plan yourself.

This is the front half of a pipeline. `/implement-plan` is the back half, and the plan file
is the interface between them:

```
/create-plan     brainstorm → plan → review the plan → refine → hand over
/implement-plan  implement  → review → refine → next batch → verify
```

**Unlike `/implement-plan`, this command asks you questions.** That is deliberate and is
explained in §2 — it is not a gap to close.

## 1. Short-circuit if the idea is already specified

If the request is already fully specified — a mechanical, settled change where the design
space is a single point — say so plainly, skip the brainstorm phase, and go to §4. A design
conversation over a settled change wastes the human's time and invites invented scope.

Be honest about which case you are in. Misjudging "already specified" is the more expensive
error of the two, so when the request names *what* but not *how*, brainstorm.

## 2. Phase 1 — brainstorm, interactively

Spawn a fresh `brainstormer` with the idea and the paths worth inspecting. It returns two
lists: what it **settled by inspection**, with evidence, and what is **genuinely open**.

Then put the open list to the human — a few questions at a time, never a wall — each with
its alternatives and the tradeoff each makes, and your recommendation first.

**Answer anything the repository can answer by inspection instead of asking it.** Asking the
human what the code already says spends the one input only they can give.

**An answer may open a new repo-answerable question** — "if we change that default, what else
reads it?" — and when it does, spawn a further fresh `brainstormer` scoped to just that
question rather than answering from your own context or skipping the inspection. Each
`brainstormer` gets one turn, so a follow-up needs a new one.

Why this phase is interactive at all, since the sibling command is not: `/implement-plan`
runs unattended because a plan is a specification to follow. Brainstorming has no
specification — the human *is* the specification. An autonomous brainstorm does not skip the
conversation, it invents the answers, and everything downstream is then built on guesses.
What this command automates is the **handoff**: once the design is agreed, planning, review
and refinement all proceed without another command from the human.

## 3. Do not leave Phase 1 with a shape-changing decision open

If resolving a question the other way would change what gets built, it is not a default you
may pick. Ask, or halt.

When the design is agreed, record it: the approach, the constraints, and the explicit
out-of-scope boundaries — **attributing each decision to the human or to inspection.** That
distinction goes into the plan's `## Context`, because only one of the two is safe for a
later reader to revisit without asking.

## 4. Choose the plan number: `max + 1`

Take the highest number in `plans/*.md` and add one. **Never "the first gap"** — gaps stay
gaps, and a number is never reused, so that every citation of a number in a review note or a
commit message stays resolvable.

```sh
ls plans/*.md 2>/dev/null | sed 's#.*/##' | cut -d- -f1 | sort -n | tail -1
```

If the repository has no `plans/` directory yet, this is plan `001` and the `planner`
creates the directory with it.

If a file with your chosen number already exists, **halt.** Do not create a second file
sharing a number. This is strict because the looser "next unused number" rule reliably
produces collisions once two components both get to decide — a repository this workflow was
built in has five such pairs.

## 5. Phase 2 — write the plan

Spawn a fresh `planner` with the agreed design, the out-of-scope boundaries, the decision
provenance from §3, and **the number from §4**. It chooses the slug and writes the file.

You do not write or edit the plan yourself, at any point in this command.

## 6. Phase 3 — review the plan

Spawn a fresh **`plan-reviewer`** with the agreed design and the plan file. Not `reviewer` —
that agent is written for a diff, and at this point there is no diff, no code, and nothing
with a lifetime. `plan-reviewer` checks:

- **design coverage** — is everything agreed in §3 actually in the plan, and nothing that
  was not agreed;
- **task ordering** — does any task depend on a later one;
- **verifiability** — every task states a command and an expected result, and none is a
  hand-wave. This is the check that pays for itself: the implementer runs those commands, so
  an unrunnable step becomes a halt after work has been done against it;
- **missing constraints** — target, dependencies, the project rules the work must satisfy;
- **scope creep** — anything beyond the agreed design, and anything in `## Out of scope`
  contradicted by a task;
- **format** — tasks are `### Task N — …` headings under `## Tasks`, so `/implement-plan`
  can batch them, and the five required sections are present;
- **internal consistency** — a verify block that contradicts the prose it belongs to;
- **reality** — the paths, symbols and commands the plan names actually exist.

## 7. Skip the code reviewers — neither applies yet

`reviewer` is the diff reviewer: correctness, lifetimes, regressions — all of which need code
that does not exist yet. A conventions reviewer the project may define (a
`guidelines-reviewer` or similar) governs source files, and a plan document has no rule ID to
violate. Both belong to `/implement-plan`, after the plan is executed.

Record that they were skipped and why. Do not invent a rule citation for prose, and do not
hand a document to an agent that will look for off-by-one errors in it.

## 8. Adjudicate, then refine

Accept findings that are technically justified and inside the agreed design; reject the rest
with a one-line rationale that goes in the report. Send accepted findings to a **fresh
planner** in refine mode — never patch the plan yourself, and never reuse the `plan-reviewer`
that produced the findings.

**Bounded at 3 iterations.** Exhausting it is a halt reporting the unresolved findings.

## 9. Halt conditions

- A **shape-changing decision** the human has not settled and inspection cannot.
- A **plan-number collision** at the number chosen in §4.
- The plan review **not clean after 3 refine iterations**.
- The idea **needs a new third-party dependency**. Stop and ask, with a concrete usage
  example and an honest cost/benefit against the dependency-free alternative, before a plan
  is written around it.
- The idea turns out to need **more than one plan file**. Say so and let the human decide
  the split rather than writing a monolith.

On any halt: report what was agreed so far, the halt reason, and precisely what is needed.
A halt is a successful outcome of this command, not a failure of it.

## 10. The handover report

- the plan path;
- the agreed design, in a few sentences;
- **which decisions were the human's and which came from inspection**;
- the out-of-scope boundaries;
- the review history and the refine-iteration count;
- findings **rejected**, each with its rationale;
- the plan's own `## Open questions`, surfaced rather than buried in the file.

## 11. Then offer to continue — do not assume

Ask whether to run `/implement-plan` on the new file. **Default to stopping**: the human
should read the plan before anything is built against it, and a plan nobody has read is a
weak thing to implement.

Proceed only on an explicit yes. Note when offering that the plan has been reviewed by an
agent but not yet by them.

**If they want `--commit`, the plan file must be committed first.** That flag's first
precondition is an empty `git status --porcelain`, and you have just created an untracked plan
file — so the flagged run would halt immediately, naming your own output as the obstruction.
You cannot clear it yourself; committing is denied to this command. Give them the commands and
let them decide:

```sh
git add plans/NNN-<slug>.md
git commit -m "Add plan NNN"
```

The unflagged `/implement-plan <plan file>` has no such precondition and can be accepted
straight away.

## 12. Hard constraints

- **Read-only git only**, for you and every agent you spawn: `status`, `diff`, `log`,
  `show`, `blame`. No commit, add, tag, or branch — this command creates a plan, not a
  commit. Destructive git is the human's alone, and some projects deny it mechanically in
  `.claude/settings.json`.
- **The only file this command creates is the plan.** No source file, no build file, no
  documentation page. If the design implies such a change, that is a task in the plan.
- Never read or print a secret or an API key.
- Do not edit the project's guideline or convention documents.

## 13. Why running several phases unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each belongs on a
different model, and rolling forward inside one session would run the next phase on the
current session's model. Delegation does not have that problem: `brainstormer`, `planner`
and `plan-reviewer` each pin their own model in their own frontmatter, so every phase runs
on the right one whatever this session is.

The offer in §11 is a separate, explicit consent point, taken after the human has seen the
plan. Nothing here licenses crossing a phase boundary in-session without delegating.

Idea: $ARGUMENTS
