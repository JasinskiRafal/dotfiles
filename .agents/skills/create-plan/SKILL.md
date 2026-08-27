---
name: create-plan
description: Interactively turn a rough feature or work-item idea into an agreed design, then delegate creation and independent review of one numbered plan under plans/. Use only when the human explicitly invokes $create-plan; stop after handing over the reviewed plan and never begin implementation without separate consent.
---

# Create plan

Orchestrate the front half of the development pipeline:

```text
brainstorm -> agree design -> write plan -> review + simplify (concurrent) -> refine once -> hand over
```

The weight of the pipeline is deliberately on this end. A defect caught in the plan
costs one refine round; the same defect caught during execution costs a batch, a
review, and every batch built on it since. So this reviews on two lenses at once —
but **at most twice**, because a plan that has not settled in two rounds needs the
human rather than a third agent.

**Write the plan in the parent context; delegate only reading.** A phase that
changes a file runs here. A phase that only reads runs as a spawned agent, and
siblings go out in a single dispatch.

The plan is a file, so the plan is yours. Writing it inline is not a shortcut: you
are the only component that heard the human's answers, recorded which decisions
were theirs and which came from inspection, and will adjudicate the review
findings. Delegating it means briefing a fresh agent to reconstruct a conversation
it was not in, then reconciling a file you did not write against a design only you
hold.

**The reviews are never yours**, for the reason that has not changed: a reviewer
that authored the plan is not a second opinion. `plan-reviewer` and
`plan-simplifier` receive the design and the file, not your reasoning about
either. Writing the plan yourself means it carries what you meant rather than only
what you wrote, and a reader may find it clearer than it is — the paired lenses,
re-run in full for the re-review, are the control for that.

Write no production file.

## 0. When the idea comes from a review report

Where the request cites a `reviews/NNN-*.md` report, read the report and the findings it names
in full before brainstorming. Two things change: the evidence is already gathered, so do not
re-derive verified findings or send a `brainstormer` to confirm them — spend the brainstorm on
the approach, which the report deliberately does not contain. And a finding is not a design:
the report's direction lines are one sentence each and its suggested slices are sizing notes,
on purpose, so the approach remains an open question for the human. Treating a direction as a
settled decision is how a refactor nobody agreed to acquires the authority of a review.

Carry the finding ids into the plan's `## Context` and into each task that closes one, so the
plan stays traceable to its evidence. Where a finding proves wrong — the code moved, or it was
mistaken — say so in the handover; never edit the report, which is immutable once written, and
never silently drop the finding. Where the slice is larger than one plan, that is the
more-than-one-plan-file halt: let the human choose the split.

## 1. Determine whether design is needed

If the request is fully specified and mechanical, say why the design space is
already settled and continue to plan numbering. When the request defines what
but leaves shape-changing implementation or behavior decisions open, continue
through brainstorming.

## 2. Inspect and agree the design

Spawn a fresh `brainstormer` with the idea and relevant repository paths. Require
it to return constraints settled by inspection separately from genuinely open
decisions.

Where the idea spans several independent areas, **dispatch one `brainstormer` per
area in a single message**. They are read-only and cannot conflict, and a question
about the build system and one about the driver layer are better answered by two
agents each holding one than by one agent holding both. Say what you split and
why; never split a single coherent question across two, which yields two
half-answers to reconcile.

Answer repository-discoverable questions by inspection. Put only genuine open
decisions to the human, a few at a time, with the recommended alternative first
and concrete tradeoffs. If an answer opens further repository questions, dispatch
fresh `brainstormer`s scoped to exactly those, **all in one message** — there is no
reason for the third follow-up to wait on the second.

Do not leave a decision open when resolving it differently would change what is
built. Record the agreed approach, constraints, compatibility requirements,
out-of-scope boundaries, and whether each decision came from the human or from
inspection.

Halt before planning when:

- a shape-changing decision remains unresolved;
- the design requires a new third-party dependency the human has not approved;
- the work requires more than one plan file and the human has not chosen a
  split.

Keep these halt conditions active through handover. If the writer or any
reviewer discovers one later, halt immediately rather than refining or handing
over a plan built on an unresolved decision, dependency, or split.

## 3. Choose one permanent plan number

Inspect `plans/*.md` and choose the highest numeric prefix plus one. Use `001`
when no numbered plan exists. Never fill the first gap or reuse a number.

Check the chosen number once more immediately before writing. Halt if any file
already uses it. Create `plans/` yourself if it does not exist. Compute the number
once, here: "next unused number" computed independently by two components reliably
produces collisions.

## 4. Write the plan

You write exactly one `plans/NNN-short-slug.md`, using the fixed number from
Section 3 and a short descriptive slug of your choosing.

**Before writing, inspect every repository path, symbol, convention, and
verification command the plan will name.** A plan naming a file you have not opened
is a guess. Put unresolved decisions under Open questions instead of inventing
answers.

Use exactly these sections, in order:

```text
## Goal
## Context
## Tasks
## Out of scope
## Open questions
```

Under `## Tasks`, format every batch as `### Task N — <title>`. `$implement-plan`
batches one batch per `###` heading under that section, so a plan formatted any
other way cannot be driven. Each task covers one independently verifiable outcome
and states exact paths and likely symbols, the concrete change, an exact
verification command or manual check, and its expected result. **If you cannot
state a task's verification command and its expected result, the task is too vague
— split it or sharpen it**, because `$implement-plan` actually runs those commands.

Testing is mandatory on this project and tests run natively on the host, so every
task that changes behavior names the test that proves it: the test file, what it
asserts, and the host command that runs it (`meson test -C <dir>`,
`ctest --test-dir <dir>`, or the project's own). Verification such as "builds
clean" or "runs on target" is an additional check, never the only one. Where a
behavior can only be observed on target hardware, the task needs a seam — the logic
behind a host-testable interface — and the seam is part of the task; where no seam
exists without changing the agreed design, raise it as an open question rather than
planning a task nobody can verify.

In `## Context`, distinguish decisions made by the human from constraints settled
by inspection, citing evidence for the inspected ones, and preserve the agreed
out-of-scope boundaries. Carry any review finding ids from Section 0 here too.

Never include a Git operation as a plan task; version control is the human's.

## 5. Review on two lenses, then refine once

Dispatch two fresh agents concurrently, in a single message, each with the complete
agreed design and the plan path. **Do not edit the plan while either is in flight**
— they are reading the file you would be changing, and a finding against a version
that no longer exists costs a round to discover. Both are read-only, so they cannot conflict and
the second costs no wall-clock:

- `plan-reviewer` — is the plan correct and complete? Returns `APPROVED` or
  `CHANGES_REQUIRED`.
- `plan-simplifier` — is the plan minimal? Returns `ALREADY_MINIMAL` or
  `SIMPLIFICATIONS_FOUND`.

They are deliberately different questions, and one agent asked both does neither
well: a reviewer hunting for missing coverage is primed to add, a simplifier is
primed to remove. Asked together those pressures cancel into a plan that is
average on both. Asked separately and adjudicated by the parent, they produce a
plan that is complete and small.

Do not substitute the code `reviewer` for either; no implementation exists yet.

`ALREADY_MINIMAL` is a real outcome for a plan written against a tight design.
Treat it as success, not as an agent that failed to find something, and do not
send it back looking harder.

Adjudicate both finding sets in one pass. Accept findings that are technically
justified and inside the agreed design. Reject other findings with a one-line
rationale for the handover report. A nit alone does not require refinement.

Where the two lenses conflict, the parent decides and coverage wins: a
simplification that would drop something the reviewer requires for coverage is
rejected, with the reason stated in the report so the next round does not propose
it again. The plan must deliver the agreed design first and be small second. Never
average the two into a midpoint neither agent proposed.

The simplifier's `observations for the human` are not findings and are never sent
to the writer. Carry them verbatim into the handover report; a shape-changing one
is a halt, not a parent decision.

When accepted findings exist, **apply them yourself in one edit pass carrying both
lenses' accepted findings** — never one pass per lens — then re-run both lenses in a
single dispatch. Address exactly what you accepted: do not restructure the plan
around a finding, re-argue one you accepted, or improve a task nobody raised. A
refine pass that rewrites more than the findings asked for is a new plan the lenses
have not seen.

Re-run **both** lenses for the re-review. A refined plan is a new plan: a
simplification applied in round 1 can break coverage in a way only a fresh
`plan-reviewer` will see. This matters more now that you are the author — you
cannot re-read your own edit as a stranger would, and the paired dispatch is the
only thing here that can.

Never reuse a reviewer across iterations. A round is clean when `plan-reviewer`
returns `APPROVED`; a `SIMPLIFICATIONS_FOUND` whose every finding was rejected with
a rationale does not hold the loop open.

**The plan is reviewed at most twice: the paired review after writing, and one
re-review after one refine pass.** There is no third. Two lenses failing to clear
the same plan twice says the design record is likely the problem rather than the
prose, and a third pass is the same edit again with a longer bill.

When review 2 is not clean, take these two moves in order. **Neither spends a
review round.**

1. **Re-adjudicate, assuming the reviewer may be wrong.** A finding that outlived a
   refine pass is often one the reviewer is mistaken about — reject it with the
   rationale in the report. **If no coverage finding survives, the plan is done:**
   hand it over with the rejections stated. Where instead the disagreement is about
   a fact, dispatch a fresh `brainstormer` on that point — a plan review that will
   not settle is frequently a repository question nobody asked. Its answer decides
   move 1 or move 2; it does not buy another round.
2. **Tighten the design record, then hand over.** Where a real coverage finding
   survives, the ambiguity is almost always in the recorded design rather than in
   the plan. Restate the agreed design explicitly, name the finding that forced it,
   and hand over with the plan as it stands and the open finding named. A design
   record that needed restating is exactly what the human should read before
   anything is built; rewriting the plan a third time against a record they have not
   seen is how a plan drifts from what was agreed. Where the restatement would
   settle something new rather than restate what was agreed, halt.

Reaching the two-review cap is a signal to hand over with the open questions
visible — not to grind, and not to stop with nothing delivered.

Skip code and conventions reviewers because there is no implementation diff.
Record that skip in the handover.

## 6. Hand over and stop

Report:

- the plan path and concise design;
- human decisions versus inspection-derived constraints;
- out-of-scope boundaries;
- review history and refine count, with both lenses' verdicts per round, plus any
  of Section 5's moves taken;
- **any finding still open at handover**, named, with why it was not resolved — a
  plan handed over with one stated open finding is more useful than a plan ground
  through a third review;
- what the simplifier changed — tasks merged or dropped, abstractions removed,
  existing code reused instead of rewritten — stated even when the verdict was
  `ALREADY_MINIMAL`, because a second lens finding nothing is information;
- the simplifier's observations for the human, verbatim;
- rejected findings and rationale, including every simplification rejected for
  conflicting with coverage;
- every Open question recorded in the plan.

Offer `$implement-plan-commit <plan-path>` for execution with provisional
commits, or `$implement-plan <plan-path>` for execution without Git mutation.
Then stop so the human can read the plan. Implementation may begin only from a
later explicit invocation of the chosen skill; generic consent inside the
`$create-plan` run does not cross that boundary.

Explain that `$implement-plan-commit` has a clean-tree precondition, so the human
must commit the new plan first. Give appropriate Git commands as text only;
never execute them.

## Hard constraints

- Read and obey all applicable `AGENTS.md` files.
- Create or edit only the one plan file; create `plans/` only when necessary for
  that file.
- **Every agent dispatched here is read-only** — `brainstormer`, `plan-reviewer`,
  `plan-simplifier`. None of them writes a file; the writing is yours.
- Never edit the plan while a read-only spawn is in flight.
- Never change Git state. Spawned agents are read-only with respect to Git.
- Never inspect or print secrets or secret-bearing configuration.
- Never edit repository policy, guideline, source, build, test, or documentation
  files.
- Every task that changes behavior names the test that proves it, the host
  command that runs it, and — where the behavior is hardware-coupled — the seam
  that makes it host-testable. Testing is mandatory; a task verified only by
  "builds clean" or "runs on target" is under-verified.
- On every halt, report what was agreed, the exact reason, and what the human
  must decide or change.
