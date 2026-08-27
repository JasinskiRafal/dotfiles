---
description: Brainstorm a rough idea into an agreed design, then write and review a numbered plan in plans/
argument-hint: <the idea, in your own words>
model: opus
effort: medium
---
Turn the idea at the end of this file into an agreed design, then into a reviewed plan file
under `plans/`. **You write the plan yourself, in this context.** What you delegate is
reading: the design inspection, and both review lenses — all read-only, all spawned
concurrently. You adjudicate their findings and you apply what you accept.

This is the middle of a pipeline. `/review-project` may precede it — a numbered report under
`reviews/` is one valid starting point, handled in §0 — and `/implement-plan` is the back half.
The plan file is the interface onward:

```
/review-project  scope → audit N lenses (concurrent) → verify each finding → reviews/NNN-*.md
/create-plan     brainstorm → plan → review + simplify (concurrent) → refine once → hand over
/implement-plan  implement  → review (≤2) → fix → next batch → closing gate
```

**The weight of this pipeline is deliberately on this end.** A defect caught in the plan costs
one refine round; the same defect caught in `/implement-plan` costs a batch, a review, a plan
amendment, and every batch built on it since. So this command reviews on two lenses at once —
but **at most twice**, because a plan that has not settled in two rounds needs my eyes rather
than a third agent's. Its sibling then runs unattended, and that only works if what it is
handed is right, which includes being honest about what is still open.

**Unlike `/implement-plan`, this command asks you questions.** That is deliberate and is
explained in §2 — it is not a gap to close.

## The split: you write, they read

**A phase that changes a file runs here. A phase that only reads runs as a spawned agent, and
its siblings go out in the same message.**

The plan is a file, so the plan is yours. Writing it inline is not a shortcut: you are the only
component that heard the human's answers in §2, that recorded which decisions were theirs and
which came from inspection (§3), and that will adjudicate the review findings (§8). Handing all
of that to a fresh `planner` means writing a brief to reconstruct a conversation you were in,
and then reconciling a file you did not write against a design only you hold.

**The reviews are never yours**, for the reason that has not changed: a reviewer that authored
the plan is not a second opinion. `plan-reviewer` and `plan-simplifier` get the design and the
file, not your reasoning about either — that is what makes their verdicts worth adjudicating.

**What this gives up.** A `planner` spawn could not see your intent, so the plan it produced
was a document its reviewers were reading cold, exactly as they would. Writing it yourself
means the plan carries what you meant rather than only what you wrote — and a reader may then
find it clearer than it is. §6's lenses are the control: both are read-only spawns with no
access to this context, and §8 requires you to re-run **both** every round rather than assuming
a refined plan inherits the last verdict.

## 0. When the idea comes from a review report

Where the request cites a `reviews/NNN-*.md` report — "improve X per review 003, findings A1,
A4" — **read the report first**, and read the findings it names in full before the brainstorm.

Two things change, and both matter:

- **The evidence is already gathered.** Findings carry verified paths, lines, and consequences.
  Do not re-derive them, and do not send a `brainstormer` to confirm what a verified finding
  already established. Spend the brainstorm on the *approach*, which the report deliberately
  does not contain.
- **A finding is not a design.** The report's `direction` lines are one sentence each and its
  `Suggested plan slices` are sizing notes, on purpose. **The approach is still an open
  question for the human** — §2 and §3 apply unchanged. A review that names a defect has not
  chosen the fix, and treating its direction as a settled decision is how a refactor nobody
  agreed to acquires the authority of a review.

Carry the finding ids into the plan's `## Context` and into each task that closes one, so the
plan stays traceable to its evidence. Where a finding turns out to be wrong — the code moved,
or it was mistaken — say so in the handover; do not edit the report, which is immutable once
written, and do not silently drop the finding.

Where the report's slice is larger than one plan, that is §9's "more than one plan file" halt:
let the human choose the split.

## 1. Short-circuit if the idea is already specified

If the request is already fully specified — a mechanical, settled change where the design
space is a single point — say so plainly, skip the brainstorm phase, and go to §4. A design
conversation over a settled change wastes the human's time and invites invented scope.

Be honest about which case you are in. Misjudging "already specified" is the more expensive
error of the two, so when the request names *what* but not *how*, brainstorm.

## 2. Phase 1 — brainstorm, interactively, and fan out where you can

Spawn a fresh `brainstormer` with the idea and the paths worth inspecting. It returns two
lists: what it **settled by inspection**, with evidence, and what is **genuinely open**.

**Where the idea spans several independent areas, spawn one `brainstormer` per area in a single
message.** They are read-only, so they cannot conflict, and a question about the build system
and a question about the driver layer are better answered by two agents each holding one than by
one agent holding both. Say what you split and why. Do not split a single coherent question
across two — you would get two half-answers and have to reconcile them yourself.

Then put the open list to the human — a few questions at a time, never a wall — each with
its alternatives and the tradeoff each makes, and your recommendation first.

**Answer anything the repository can answer by inspection instead of asking it.** Asking the
human what the code already says spends the one input only they can give.

**An answer may open new repo-answerable questions** — "if we change that default, what else
reads it?" — and when it does, spawn fresh `brainstormer`s scoped to exactly those questions,
**all in one message**, rather than answering from your own context or skipping the inspection.
Each `brainstormer` gets one turn, so a follow-up needs a new one; there is no reason for the
third follow-up to wait on the second.

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

If the repository has no `plans/` directory yet, this is plan `001` and you create the
directory with it.

If a file with your chosen number already exists, **halt.** Do not create a second file
sharing a number. This is strict because the looser "next unused number" rule reliably
produces collisions once two components both get to decide — a repository this workflow was
built in has five such pairs. Compute the number **once**, here, and use it.

## 5. Phase 2 — write the plan

You write it, at `plans/NNN-short-slug.md`, with the number from §4. The slug is yours: short,
hyphenated, and descriptive of the work rather than of the plan.

### Before writing, read the code the plan will touch

**A plan naming a file you have not opened is a guess.** Cite real paths, real symbols, real
build commands — the build and test invocations come from the repository's own documentation
(its `README.md`, `CONTRIBUTING.md`, or the section of `CLAUDE.md` that names them), not from
memory. Where the design has a hole, it goes under `## Open questions`; never fill it with an
invented decision.

### Required structure

Exactly these sections, in this order:

```markdown
## Goal
## Context
## Tasks
## Out of scope
## Open questions
```

**Tasks are `### Task N — <title>` headings under `## Tasks`.** This is not a style
preference: `/implement-plan` batches one batch per `###` heading inside that section, so a
plan whose tasks are formatted any other way cannot be driven.

### Task granularity

Each task covers **exactly one** independently verifiable outcome — one implement-and-verify
cycle. For every task give:

- the exact file path(s) and likely symbols to change;
- what to change, concretely, sketching the signature or shape where it helps;
- **how to verify it: the exact command and its expected result.**

**If you cannot state a task's verification command and its expected result, the task is too
vague — split it or sharpen it.** `/implement-plan` actually runs these commands, so a
hand-wave here becomes a mid-run plan amendment at best, after work has been done against it.

**Every task that changes behaviour names its test.** Testing is mandatory here, so a task's
verification is the test that proves the behaviour — the test file, what it asserts, and the
host command that runs it (`meson test -C <dir>`, `ctest --test-dir <dir>`, or the project's
own). Verification like "builds clean" or "the service answers on that port" is a useful
*additional* check and never the only one.

Write tasks so the test is possible: if a behaviour can only be checked on target hardware,
the task needs a **seam** — the logic behind a host-testable interface — and the seam is part
of the task, not an afterthought. Where no seam exists without changing the agreed design,
raise it as an open question rather than planning a task nobody can verify.

A check that genuinely needs hardware — a sensor reading, a peripheral, real timing — is a
deferred check named alongside the host test, never instead of it.

### Record the provenance of decisions

In `## Context`, distinguish **what the human decided** from **what was settled by
inspection**, with the evidence for the latter. A later reader must be able to tell an
agreed constraint from an inferred one, because only one of the two is safe to revisit
without asking. Carry any review finding ids from §0 here too.

### Never put a git operation in a plan

No branch, commit, merge, or PR task — version control is the human's.

**The plan is the only file this command creates.** No source file, no build file, no
documentation page. If the design implies such a change, that is a task in the plan.

## 6. Phase 3 — review the plan on two lenses, concurrently

Spawn **two** fresh agents with the agreed design and the plan file, **in a single message** so
they run at the same time. Both are read-only, so they cannot conflict, and the second costs
you no wall-clock:

- **`plan-reviewer`** — is the plan *correct and complete*?
- **`plan-simplifier`** — is the plan *minimal*?

They are deliberately different questions, and one agent asked both does neither well: a
reviewer hunting for missing coverage is primed to add, and a simplifier is primed to remove.
Asked together, those pressures cancel into a plan that is merely average on both. Asked
separately and adjudicated by you, they produce a plan that is complete *and* small.

Neither is `reviewer` — that agent is written for a diff, and at this point there is no diff,
no code, and nothing with a lifetime.

**Do not edit the plan while either is in flight.** They are reading the file you would be
changing, and a finding against a version that no longer exists costs you a refine round to
discover. Write, then spawn, then wait for both.

### `plan-reviewer` checks

- **design coverage** — is everything agreed in §3 actually in the plan, and nothing that
  was not agreed;
- **task ordering** — does any task depend on a later one;
- **verifiability** — every task states a command and an expected result, and none is a
  hand-wave. This is the check that pays for itself: `/implement-plan` runs those commands, so
  an unrunnable step costs a mid-run plan amendment at best, and work done against a step
  nobody could check at worst;
- **missing constraints** — target, dependencies, the project rules the work must satisfy;
- **tests** — every task that changes behaviour names the test that proves it, the host
  command that runs it, and (where the behaviour is hardware-coupled) the seam that makes it
  host-testable at all. Testing is mandatory on this project, so a task verified only by
  "builds clean" or "runs on target" is under-verified, and a plan that leans on an on-target
  check in place of a host test is a defect;
- **scope creep** — anything beyond the agreed design, and anything in `## Out of scope`
  contradicted by a task;
- **format** — tasks are `### Task N — …` headings under `## Tasks`, so `/implement-plan`
  can batch them, and the five required sections are present;
- **internal consistency** — a verify block that contradicts the prose it belongs to;
- **reality** — the paths, symbols and commands the plan names actually exist. **Give this
  lens weight**: you wrote this plan with the design in your head, and the failure mode of an
  inline author is a plan that reads correctly to the person who meant it.

It returns `APPROVED` or `CHANGES_REQUIRED`.

### `plan-simplifier` checks

- **tasks that could merge or be dropped** — without losing independent verifiability, which
  is the property `/implement-plan` batches on;
- **speculative abstraction** — an interface with one implementation, a factory for a single
  product, a config knob for something the design never varies;
- **reinvention** — a helper the repository already has, named with its symbol and file. The
  highest-value finding available here, and the one that most needs evidence;
- **over-specified verification** — five checks where one proves the behaviour. Every step is a
  command `/implement-plan` runs on every batch *and* every fix pass, so a redundant check is
  paid many times over;
- **premature generalization** and **layering that adds no boundary**.

It returns `ALREADY_MINIMAL` or `SIMPLIFICATIONS_FOUND`. **`ALREADY_MINIMAL` is a real
outcome** for a plan written against a tight design — treat it as success, not as an agent that
failed to find anything, and do not send it back looking harder.

Its findings are bounded on purpose: it may not drop or narrow an agreed requirement, propose a
different design, remove a test or a safety check, or touch `## Out of scope`. Where the only
simplification it sees needs the design changed, it says so as an **observation for the human**
rather than a finding — those observations go into §10's report verbatim, and a shape-changing
one is a §9 halt, not something you decide.

## 7. Skip the code reviewers — neither applies yet

`reviewer` is the diff reviewer: correctness, lifetimes, regressions — all of which need code
that does not exist yet. A conventions reviewer the project may define (a
`guidelines-reviewer` or similar) governs source files, and a plan document has no rule ID to
violate. Both belong to `/implement-plan`, after the plan is executed.

Record that they were skipped and why. Do not invent a rule citation for prose, and do not
hand a document to an agent that will look for off-by-one errors in it.

## 8. Adjudicate, then refine — and escalate rather than stop

Accept findings that are technically justified and inside the agreed design; reject the rest
with a one-line rationale that goes in the report. Adjudicate **both** finding sets in one
pass, then apply everything accepted yourself, in one edit pass carrying both — never one pass
per lens.

**Address exactly what you accepted.** Do not restructure the plan around a finding, do not
re-argue one you accepted, and do not take the opportunity to improve a task nobody raised.
A refine pass that rewrites more than the findings asked for is a new plan the lenses have not
seen, and the next round's verdict is then about work that appeared between rounds.

**Where the two lenses conflict, you decide, and coverage wins.** A `plan-simplifier` proposal
that would drop something `plan-reviewer` requires for coverage is rejected — the plan must
deliver the agreed design first and be small second. Say so explicitly in the report when it
happens; a rejected simplification with a stated reason is a useful record, and it stops the
next round proposing it again.

The reverse conflict is rarer and resolves the same way: where a coverage finding would add a
task the simplifier showed is already served by existing code, the simplifier is right about
the *mechanism* and the reviewer about the *requirement*. Accept both — the requirement is
covered by reusing what exists, which is a task, just a smaller one.

Do not average them. Picking a midpoint neither agent proposed is how a plan ends up
half-covered and half-simplified.

**The plan is reviewed at most twice: the paired review after writing, and one re-review after
one refine pass.** There is no third. Two lenses having failed to clear the same plan twice says
the *design record* is likely the problem rather than the prose, and a third pass would be the
same edit again with a longer bill.

**A round is clean when `plan-reviewer` returns `APPROVED`** — a `SIMPLIFICATIONS_FOUND` whose
every finding you rejected with a rationale does not hold the loop open. **Re-run both lenses
for the re-review, in one message**; a refined plan is a new plan, and a simplification applied
in round 1 can break coverage in a way only a fresh `plan-reviewer` will see. This matters more
now that you are the author: you cannot re-read your own edit as a stranger would, and the
paired spawn is the only thing in this command that can.

When review 2 is not clean, take these two moves in order. **Neither spends a review round.**

1. **Re-adjudicate, properly.** Read the surviving findings yourself, assuming this time that
   the reviewer may be wrong. A finding that has outlived a refine pass is often one the
   reviewer is mistaken about — reject it, with the rationale in the report. **If no coverage
   finding survives, the plan is done**: hand it over with the rejections stated, and let the
   human weigh them against the plan. That is what §10's report is for.

   If instead the two of you disagree about a *fact*, spawn a fresh `brainstormer` on that
   point — a plan review that will not settle is frequently a question the repository can answer
   that nobody asked it. Its answer decides move 1 or move 2; it does not buy another round.

2. **Tighten the design record, and stop.** If a real coverage finding survives, the ambiguity
   is almost always in §3's record rather than in the plan. Restate the agreed design
   explicitly, say in the handover which finding forced it, and **hand over** — with the
   restatement, the plan as it stands, and the open finding named. A design record that needed
   restating is exactly the thing I should read before anything is built, and rewriting the plan
   a third time against a record I have not seen is how a plan drifts from what was agreed.

   Where the restatement would decide something new rather than restate what was agreed, that is
   a §9 halt.

After every round, record whether it **made progress** — a finding resolved or rejected, the set
of open findings changed, the plan file actually edited, or a repository fact newly established.
A round with none of those is **unproductive**, and it ends the command immediately rather than
buying the second review: report every finding left standing.

## 9. Halt conditions — the ones only the human can resolve

- A **shape-changing decision** the human has not settled and inspection cannot.
- A **plan-number collision** at the number chosen in §4.
- The idea **needs a new third-party dependency**. Stop and ask, with a concrete usage
  example and an honest cost/benefit against the dependency-free alternative, before a plan
  is written around it.
- The idea turns out to need **more than one plan file**. Say so and let the human decide
  the split rather than writing a monolith.
- A **restatement of the design record** that would settle something new rather than restate
  what was agreed (§8 move 2).

**A plan that is merely not clean after two reviews is not on this list, and is not a halt
either.** §8's moves resolve it: the findings are adjudicated, what survives is named, and the
plan is handed over with both in the report. Reaching the two-review cap is a signal to hand
over with the open questions visible — not to grind, and not to stop with nothing delivered.

On any halt: report what was agreed so far, the halt reason, and precisely what is needed.
A halt is a successful outcome of this command, not a failure of it.

## 10. The handover report

- the plan path;
- the agreed design, in a few sentences;
- **which decisions were the human's and which came from inspection**;
- the out-of-scope boundaries;
- the review history and the refine-pass count, plus any of §8's moves taken and the progress
  ledger behind them — **both lenses per round**, with `plan-reviewer`'s verdict and
  `plan-simplifier`'s;
- **any finding still open at handover**, named, with why it was not resolved. A plan handed
  over with one stated open finding is more useful than a plan ground through a third review;
- **what the simplifier changed** — tasks merged or dropped, abstractions removed, existing code
  reused instead of rewritten. Give it its own line even when the answer is `ALREADY_MINIMAL`,
  because "a second lens looked and found nothing" is information about the plan's quality;
- **the simplifier's observations for the human** — verbatim. These are the things it was
  forbidden to act on: a requirement that looks expensive for its value, complexity the design
  forces, a simplification that would need the design changed. They are the most likely thing
  in this report to change your mind, and the only place they appear;
- findings **rejected**, each with its rationale — including every simplification rejected for
  conflicting with coverage (§8);
- the plan's own `## Open questions`, surfaced rather than buried in the file.

Finally, a **machine-readable metrics block**, last in the report, exactly this shape:

```
## Run metrics
plan: plans/NNN-<slug>.md
tasks: <n>
wall_clock_min: <n>
spawns_brainstormer: <n>
spawns_plan_reviewer: <n>
spawns_plan_simplifier: <n>
max_concurrent_spawns: <n>              # 1 means a paired step was serialized
brainstorm: full|short_circuited
reviewer_verdict_round1: APPROVED|CHANGES_REQUIRED
simplifier_verdict_round1: ALREADY_MINIMAL|SIMPLIFICATIONS_FOUND
findings_raised: <n>
findings_accepted: <n>
findings_rejected: <n>
simplifications_accepted: <n>
review_rounds_used: <n>                 # cap is 2
refine_passes_used: <n>                 # 0 means the plan reviewed clean first time
post_review_moves_taken: <n>            # §8's moves 1-2
findings_open_at_handover: <n>           # survived move 1; named in the report
```

Report the real numbers. `simplifications_accepted: 0` over several plans is the evidence for
changing that phase; `review_rounds_used: 2` on most plans says the first pass is too loose;
`max_concurrent_spawns: 1` when §6 ran means a paired step was serialized; a block tuned to look
healthy is worth nothing.

## 11. Then offer to continue — do not assume

Ask whether to run `/implement-plan` on the new file. **Default to stopping**: the human
should read the plan before anything is built against it, and a plan nobody has read is a
weak thing to implement.

Proceed only on an explicit yes. Note when offering that the plan has been reviewed by two
agents — one for coverage, one for simplicity — but not yet by them.

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
  `.claude/settings.json`. Do not look for a way around a blocked call — not by reordering
  arguments, not via `git -C`, not through a compound command. A blocked call means stop and
  report.
- **`git add` and `git commit -m` may be permitted by the tooling and are forbidden to you by
  this instruction.** A permission rule matches a command, not a caller, so nothing mechanical
  will stop you committing — which makes the rule yours to keep rather than the harness's to
  enforce. Report the commit-worthy moment; do not take it.
- **The only file this command creates is the plan**, and exactly one of them per invocation.
  If the work is too large for one file, that is §9's halt — write nothing extra and let the
  human choose the split.
- **Every agent you spawn is read-only.** They are `brainstormer`, `plan-reviewer` and
  `plan-simplifier`; none of them writes a file. Writing is inline, by you.
- Never read or print a secret or an API key.
- Do not edit the project's guideline or convention documents.
- Do not start executing the plan. §11 is the boundary.

## 13. Why running several phases unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each belongs on a
deliberately chosen model, and rolling forward inside one session would run the next phase on
whatever model the session happened to be on. **A slash command pins a model in its own
frontmatter exactly as a subagent does**, so an inline phase under this command is as
deliberately placed as a delegated one: planning and adjudication run on the `opus` at `medium`
effort pinned at the top of this file. The read-only phases run on the model their own agent
pins — `brainstormer`, `plan-reviewer` and `plan-simplifier` each state theirs. Nothing here
inherits an accidental model.

The effort is `medium` rather than `high` even though writing the plan is now this command's own
work rather than a delegate's. Two things pay for that: the plan is checked by **two**
independent read-only lenses before anyone builds against it (§6), and §11 stops for the human
before implementation. A plan is also the cheapest artifact in the pipeline to correct — one
refine pass, against the same defect that would cost a batch and an amendment downstream. Where
a plan is genuinely hard enough that `medium` shows, that shows up as `review_rounds_used: 2` in
the metrics across several plans, and it is the evidence for raising this back.

The offer in §11 is a separate, explicit consent point, taken after the human has seen the
plan. Nothing here licenses crossing a phase boundary in-session.

Idea: $ARGUMENTS
