---
description: Brainstorm a rough idea into an agreed design, then write and review a numbered plan in plans/
argument-hint: <the idea, in your own words>
model: opus
effort: medium
---
Turn the idea at the end of this file into an agreed design, then into a reviewed plan file
under `plans/`. You orchestrate: you delegate the design, the writing, and the review, and
you adjudicate. You do not write the plan yourself.

This is the middle of a pipeline. `/review-project` may precede it — a numbered report under
`reviews/` is one valid starting point, handled in §0 — and `/implement-plan` is the back half.
The plan file is the interface onward:

```
/create-plan     brainstorm → plan → review + simplify (concurrent) → refine → hand over
/implement-plan  implement  → review → refine → next batch → closing gate
```

**The weight of this pipeline is deliberately on this end.** A defect caught in the plan costs
one refine round; the same defect caught in `/implement-plan` costs a batch, a review, a plan
amendment, and every batch built on it since. So this command reviews on two lenses at once and
refines until both settle, and its sibling then runs unattended — that only works if what it is
handed is right.

**Unlike `/implement-plan`, this command asks you questions.** That is deliberate and is
explained in §2 — it is not a gap to close.

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

### `plan-reviewer` checks

- **design coverage** — is everything agreed in §3 actually in the plan, and nothing that
  was not agreed;
- **task ordering** — does any task depend on a later one;
- **verifiability** — every task states a command and an expected result, and none is a
  hand-wave. This is the check that pays for itself: the implementer runs those commands, so
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
- **reality** — the paths, symbols and commands the plan names actually exist.

It returns `APPROVED` or `CHANGES_REQUIRED`.

### `plan-simplifier` checks

- **tasks that could merge or be dropped** — without losing independent verifiability, which
  is the property `/implement-plan` batches on;
- **speculative abstraction** — an interface with one implementation, a factory for a single
  product, a config knob for something the design never varies;
- **reinvention** — a helper the repository already has, named with its symbol and file. The
  highest-value finding available here, and the one that most needs evidence;
- **over-specified verification** — five checks where one proves the behavior. Every step is a
  command the implementer runs on every batch *and* every fix pass, so a redundant check is
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
pass, then send everything accepted to a **fresh planner** in refine mode — one refine spawn
carrying both, never one per lens. Never patch the plan yourself, and never reuse an agent that
produced findings you are acting on.

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

The refine loop gets **2 rounds** of exactly that shape. Reaching the second without a clean
review ends *that approach*, not this command. Take the next unused rung below, then continue
with a fresh budget of 2:

**A round is clean when `plan-reviewer` returns `APPROVED`** — a `SIMPLIFICATIONS_FOUND` whose
every finding you rejected with a rationale does not hold the loop open. Re-run both lenses each
round; a refined plan is a new plan, and a simplification applied in round 1 can break coverage
in a way only a fresh `plan-reviewer` will see.

1. **Re-adjudicate, and inspect if the point is contested.** Read the surviving findings
   yourself. A finding that has outlived two refine passes is often one the reviewer is wrong
   about — reject it, with the rationale in the report. If instead the two of you disagree
   about a fact, spawn a fresh `brainstormer` on that point: a plan review that will not
   settle is frequently a question the repository can answer that nobody asked it.
2. **Tighten the design record.** If the plan keeps failing review in the same place, the
   ambiguity is usually in §3's record rather than in the plan. Restate the agreed design and
   spawn a fresh `planner` against the restatement. Restating what was agreed is allowed;
   deciding something new is a halt under §9.

Each rung is used at most once. After every round, record whether it **made progress** — a
finding resolved or rejected, the set of open findings changed, the plan file actually edited,
or a repository fact newly established. A round with none of those is **unproductive**: one
unproductive round forces the next rung immediately, and **two consecutive unproductive rounds
end the command**, reporting every rung tried and every finding left standing.

That ledger, not a counter reaching two, is what stops this loop. A bound being reached is a
signal to change the approach.

## 9. Halt conditions — the ones only the human can resolve

- A **shape-changing decision** the human has not settled and inspection cannot.
- A **plan-number collision** at the number chosen in §4.
- The idea **needs a new third-party dependency**. Stop and ask, with a concrete usage
  example and an honest cost/benefit against the dependency-free alternative, before a plan
  is written around it.
- The idea turns out to need **more than one plan file**. Say so and let the human decide
  the split rather than writing a monolith.
- The plan review has **run out of moves** — two consecutive unproductive rounds under §8.
  The first one already forced a new rung, so a second means the approach changed and still
  moved nothing. Report the unresolved findings and what each rung tried.

**A plan review that is merely not clean yet is not on this list.** Reaching the refine bound
changes the approach (§8); it does not end the command.

On any halt: report what was agreed so far, the halt reason, and precisely what is needed.
A halt is a successful outcome of this command, not a failure of it.

## 10. The handover report

- the plan path;
- the agreed design, in a few sentences;
- **which decisions were the human's and which came from inspection**;
- the out-of-scope boundaries;
- the review history and the refine-round count, plus any escalation rungs taken from §8 and
  the progress ledger behind them — **both lenses per round**, with `plan-reviewer`'s verdict
  and `plan-simplifier`'s;
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
spawns_planner: <n>
spawns_plan_reviewer: <n>
spawns_plan_simplifier: <n>
brainstorm: full|short_circuited
reviewer_verdict_round1: APPROVED|CHANGES_REQUIRED
simplifier_verdict_round1: ALREADY_MINIMAL|SIMPLIFICATIONS_FOUND
findings_raised: <n>
findings_accepted: <n>
findings_rejected: <n>
simplifications_accepted: <n>
refine_rounds_used: <n>
escalation_rungs_taken: <n>
```

Report the real numbers. `simplifications_accepted: 0` over several plans is the evidence for
changing that phase; a block tuned to look healthy is worth nothing.


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
  `.claude/settings.json`.
- **The only file this command creates is the plan.** No source file, no build file, no
  documentation page. If the design implies such a change, that is a task in the plan.
- Never read or print a secret or an API key.
- Do not edit the project's guideline or convention documents.

## 13. Why running several phases unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each belongs on a
deliberately chosen model, and rolling forward inside one session would run the next phase on
whatever model the session happened to be on. Delegation does not have that problem:
`brainstormer`, `planner`, `plan-reviewer` and `plan-simplifier` each pin their own **model and
effort** in their own frontmatter, so every phase runs on the right one whatever this session
is. `/implement-plan`
delegates every phase for the same reason — there is no artifact either command could usefully
write itself, and the plan, like the code, is a document its reviewer must not have authored.

The offer in §11 is a separate, explicit consent point, taken after the human has seen the
plan. Nothing here licenses crossing a phase boundary in-session without delegating.

Idea: $ARGUMENTS
