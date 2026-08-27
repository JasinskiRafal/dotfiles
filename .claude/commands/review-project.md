---
description: Audit the project as it stands on several lenses at once, verify every finding, and write a numbered review report in reviews/ for /create-plan to consume
argument-hint: [path or subsystem, e.g. firmware/lib] — omit to scope interactively
model: opus
effort: medium
---
Audit the project **as it currently stands** and write one numbered review report under
`reviews/`. You orchestrate: you scope, you delegate the lenses, you verify every finding, you
adjudicate, you write the report. **You change no code.**

This is a third entry point beside the planning pipeline, and the report is the interface into
it:

```
/review-project  scope → audit on N lenses (concurrent) → verify each finding → report
                                                                                  │
/create-plan     brainstorm → plan → review + simplify → refine → hand over  ◄────┘
/implement-plan  implement  → review → refine → next batch → closing gate
```

**This command produces a document, not a change.** It does not fix, refactor, or improve
anything, and it does not write a plan. Its output is evidence the human reads before deciding
what is worth doing — and `/create-plan` is where a decision gets made.

**Why it is separate from the `reviewer` agent.** `reviewer` judges a diff against a task: it
needs code that just changed and a specification to judge it by. Here nothing has changed and
there is no specification — the question is what the code *is*, not whether a change was
correct. Different question, different scope, different agent (`auditor`).

**Cost shape, so it is not a surprise.** One `auditor` spawn per lens on sonnet at high
effort, then one `auditor-verify` per surviving finding on sonnet at **medium** — the verify
pass is the volume here, and refuting one named claim is a narrower job than auditing a scope,
so it is priced lower. A five-lens audit producing thirty findings is 5 + 30 spawns. That is
deliberate — see §5 for why verification is not the place to economise — but it means **scope is
the cost control**, and §1 exists to keep the scope honest rather than heroic.

## 1. Scope it, and say what is out

The argument at the end of this file is the scope: a path, a subsystem, or nothing.

**A scope is a set of directories you can actually cover.** Take the repository's own layout
seriously: a firmware tree with a `firmware/lib`, a `system/`, and a `docs/` is three or four
plausible scopes, not one. Count the files and read the largest few before committing.

- **An argument was given** — use it. Confirm it exists, count what is in it, and print that.
- **No argument** — do not silently audit everything. Inspect the layout, propose two or three
  candidate scopes with file counts and a recommendation, and **ask.** This is the one
  interactive point in this command, and it is here because auditing the wrong half of a
  repository wastes the entire run.

**Then state what is out of scope, explicitly**: vendored and third-party directories,
generated code, build output, and anything the argument excluded. Generated files are a
particular trap — a finding against generated code is noise, and its fix is in the generator.

**Print the scope, the exclusions, and the file count before spawning anything.** If the scope
is too large to cover honestly, say so and propose splitting it into two reviews rather than
producing a thin audit of everything. A shallow report over a whole repository is worth less
than a real one over a third of it.

## 2. Choose the review number: `max + 1`

```sh
ls reviews/*.md 2>/dev/null | sed 's#.*/##' | cut -d- -f1 | sort -n | tail -1
```

Highest number in `reviews/*.md`, plus one. **Never the first gap, never reused** — the same
rule plans follow, and for the same reason: a citation like "review 003, finding A4" has to
stay resolvable after the report is superseded. If `reviews/` does not exist, this is `001`
and you create the directory with the file.

If a file with your chosen number already exists, **halt.** Do not create a second file
sharing a number.

## 3. Read the project's own rules first

Before any lens runs, read what the repository says about itself: `README`, `CONTRIBUTING`,
its `CLAUDE.md` or `AGENTS.md`, and any guideline documents under `docs/`. Print what you
found and what it governs.

This is not ceremony. **A local convention that differs from the language default is usually a
decision, not a defect**, and an audit that reports it as a smell is an audit the human stops
trusting on the first page. Where the repository documents coding rules with IDs, findings
that violate them should cite the ID; where it documents a deliberate deviation, findings
against it are wrong.

Every `auditor` you spawn gets this brief — the scope, the exclusions, the build and test
commands, and the guideline documents that apply — established **once**, here, so no spawn
rediscovers it.

## 4. Spawn the lenses concurrently

**One `auditor` per lens, all in a single message.** They are read-only, so they cannot
conflict, and one lens each is what keeps them sharp: an agent asked to find everything finds
the obvious thing on every axis and the deep thing on none.

The default lenses:

1. **Architecture and design patterns** — module boundaries and layering, coupling and
   dependency direction, patterns used well, patterns misapplied, and patterns *missing* where
   the code is visibly straining without one. Also abstractions that do not earn their place:
   an interface with one implementation, a layer that only forwards.
2. **Code smells** — duplication, functions and files that do too much, god objects, feature
   envy, primitive obsession, shotgun surgery, dead code, comments that contradict the code.
   Recurring smells are one finding with many sites (the `auditor` is told this).
3. **Correctness and robustness risk** — error and failure paths, resource lifetimes,
   boundary conditions, integer and buffer handling, concurrency and reentrancy, partially
   updated state on a failed path. This lens produces the `critical` findings if any exist.
4. **Test coverage and testability** — behaviour with no test, vacuous tests that would pass
   without their production code, tests that do not run on the host, and code that *cannot* be
   host-tested for want of a seam. Testing is mandatory on this project and tests are
   host-native, so this lens is not optional and its findings are not stylistic.
5. **Conventions conformance** — only where §3 found documented rules. Cite rule IDs. **Skip
   this lens entirely when the repository documents no conventions**, and say you skipped it;
   inventing a rule to cite is a defect, not thoroughness.

Adjust the lens set to the project and **say what you changed and why**. A repository with no
concurrency does not need a concurrency emphasis; a public library needs an API-surface lens
this list does not have. Adding a lens is cheap and one message; dropping one silently is not.

## 5. Verify every finding before it reaches the report

Spawn a fresh **`auditor-verify`** per surviving finding — that agent's whole job is to refute
one named claim, and it defaults to `REFUTED` when uncertain.
**Issue them in a single message**, one spawn per finding — they are read-only, so they cannot
conflict, and a verification pass that goes out one finding at a time turns the cheapest step in
this command into the longest. Where the surviving set is large, send them in as few messages as
the harness will take rather than in a loop of one.

This is the step that makes the report worth reading. An audit's characteristic failure is not
missing something — it is a confident, well-written finding that is not true: a path that
moved, a race on single-threaded data, duplication between functions that differ where it
matters. Such a finding survives the report, becomes a task in a plan, and is discovered to be
imaginary only when somebody tries to fix it.

- **`REFUTED`** — drop it. Record it in the report's rejected list with the refutation, so the
  next review does not re-raise it.
- **`CONFIRMED`** — it goes in, with any correction the `auditor-verify` made to its severity
  or sites.
- **`auditor-verify` and `auditor` disagree about severity** — you decide, and say so.
- **It returns a finding of its own** under `Noticed in passing` — that is not verified and does
  not enter the report as a finding. Either it is worth a fresh `auditor` spawn on the right
  lens, or it is a line in `Not covered`. Never promote an unverified observation.

**Never skip verification to save spawns.** If the finding count is so high that verification
is unaffordable, that is a signal the lenses over-reported: push back on severity first
(§6), verify what remains, and say in the report that you did. Dropping verification silently
turns this command into a generator of plausible fiction.

Deduplicate before verifying, not after: the same defect found by two lenses is one finding
with two lenses' evidence, and verifying it twice pays twice for one answer.

## 6. Adjudicate — and push back on the lenses

You are the only component that sees all lenses at once, and inflation is the default failure.

- **Reject findings with no consequence.** "Not idiomatic" with no named cost is a `note` at
  most, and often nothing.
- **Demote aggressively.** A `major` whose consequence is "a future reader might be confused"
  is a `minor`. Severity has to mean something for the report to be sortable.
- **Reject anything that is a design decision in disguise** — "this should use an event bus"
  is not a finding, it is a proposal, and proposals belong to `/create-plan` with the human.
- **Reject findings against excluded code** — generated, vendored, build output.
- **Merge across lenses into themes.** Several findings with one root cause is the most
  valuable thing this command produces, because it changes what the fix is: five duplication
  findings and two testability findings that all trace to one god object is *one* problem.

Record every rejection with its reason. A rejected finding with a stated reason is useful; a
finding that quietly vanished makes the report unauditable.

## 7. Ask what was missed

Before writing, spawn one final `auditor` with a **completeness lens**: given
the scope, the exclusions, and the confirmed findings, what part of the scope did no lens
actually read, and what class of problem could this lens set not see?

Put its answer in the report verbatim, under `Not covered`. **An audit that does not say what
it missed reads as complete**, and the human then plans against it as though it were.

## 8. Write the report

You write it yourself, at `reviews/NNN-<slug>.md`. The slug names the scope
(`reviews/003-firmware-lib.md`).

Writing it here rather than delegating is deliberate, and it is the same rule `/create-plan`
follows: **the phase that writes a file runs inline, and every spawned phase is read-only.**
The findings were produced by agents you did not brief on each other and independently verified
by agents that tried to refute them — the report is a synthesis of adjudications only you made,
and there is no brief that would let a fresh agent reconstruct them. It gets reviewed downstream
anyway: `/create-plan` puts any plan built from it through `plan-reviewer` and
`plan-simplifier`.

Required structure:

```markdown
# NNN — Review: <scope>

## Scope
What was audited, the file count, and the lenses that ran. Which lenses were
added, dropped, or skipped, and why.

## Not covered
Exclusions, anything in scope no lens read, and §7's answer verbatim. Honest and
specific.

## Summary
The state of this scope in a few sentences, and the two or three things that
matter most. Written for someone deciding where to spend effort.

## Themes
Root causes spanning several findings. Each names the findings it explains.
This is the section to read first, and often the only one that changes a plan.

## Findings
Worst first. Per finding: id, title, severity, sites as `path:line`, what is
wrong, the concrete consequence, the verifier's verdict, and a one-sentence
direction where there is one.

## Rejected
Findings raised and dropped, with the reason — refuted, no consequence,
deliberate, out of scope. So the next review does not re-litigate them.

## Suggested plan slices
How this work divides into plans — each a coherent slice with the findings it
would close. Sizing and sequencing only. **No designs, no task breakdowns.**
```

**`## Suggested plan slices` is a sizing note, not a plan.** Name the slice, list the finding
ids, say roughly how big it is and what should come first. The moment it contains an approach,
an interface, or a task list, it has pre-empted the design conversation `/create-plan` exists
to have — and worse, a design nobody agreed to arrives wearing the authority of a review.

## 9. Halt conditions

- **A review-number collision** at the number chosen in §2.
- **The scope is unclear and no argument was given** — §1 asks; if the answer does not settle
  it, stop rather than guessing.
- **The scope is too large to audit honestly** and the human has not chosen a split.
- **A committed secret.** Report the path and that it exists, never the value, and stop for
  the human — this outranks finishing the report.

**A lens returning nothing is not a halt.** "This scope is in good shape on this lens" is a
real result. Neither is a high finding count: that is §6's job.

## 10. Then hand over — do not continue

Report the review path, the finding counts by severity, the themes, and the suggested slices.

Then **stop.** Do not write a plan, do not start fixing anything, and do not run
`/create-plan` yourself. Say what the next step is:

```
/create-plan improve <the slice> per reviews/NNN-<slug>.md findings A1, A4, B2
```

The human decides which slice is worth doing, and that decision is the whole point of
producing a report instead of a change. A review that flows straight into implementation is a
refactor nobody approved.

## 11. Hard constraints

- **Read-only for code, for you and every agent you spawn.** No `Edit` or `Write` to any
  source, build, test, or guideline file. The only file this command creates is the report.
- **Read-only git only** — `status`, `diff`, `log`, `show`, `blame`. No commit, add, branch,
  checkout, stash, or worktree. `git log` and `git blame` are useful here — churn and
  authorship help distinguish a deliberate pattern from an accident.
- **Do not run the build or the test suite** to produce a finding. This command reads code.
  Where a finding depends on runtime behaviour, it is a `What I could not judge` entry, not a
  guess.
- **Never invent a finding, a rule ID, a path, or a line number.** Every finding is evidenced
  by an `auditor` and survived an `auditor-verify`, or it is not in the report.
- Never read or print a secret or an API key.
- Do not edit an existing review report. A superseded review stays as written; a new audit is
  a new number.

## 12. Why this does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each belongs on a
deliberately chosen model. **A slash command pins a model in its own frontmatter exactly as a
subagent does**, so every phase here runs on one chosen for it: this file pins `opus` at
`medium` for scoping, adjudication and synthesis, `auditor` pins `sonnet` at `high` for the lens
audits, and `auditor-verify` pins `sonnet` at `medium` for the per-finding refutations.

**Why the verify pass is cheaper than the audit.** An audit reads a scope it has not seen and
decides what is worth reporting; a refutation is handed a path, a line and a claimed
consequence, and usually settles on the first check — does the cited code exist as described.
That is the most common way a finding is wrong and the cheapest thing to look at, so the pass
that does it many times over is the one to price down. It is also why it never audits: an agent
asked to refute *and* to look around returns findings nobody verified.

This command is the simplest case of the workflow's split — **writers inline, readers spawned
and parallelized.** It has no writer phase but the report, which is yours; every one of its
spawns is a read-only `auditor`, and they go out concurrently in §4, §5 and §7.

The handover in §10 is a consent point, not a formality: this command's entire purpose is to
put a decision in front of the human, so rolling into `/create-plan` would destroy the reason
it exists.

Scope: $ARGUMENTS
