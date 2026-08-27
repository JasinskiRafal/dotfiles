---
name: review-project
description: Audit the project as it stands on several lenses at once, adversarially verify every finding, and write a numbered review report under reviews/ for $create-plan to consume. Use only when the human explicitly invokes $review-project. Produces a document, never a code change.
---

# Review project

Audit the project **as it currently stands** and write one numbered report under `reviews/`.
Orchestrate: scope, delegate the lenses, verify every finding, adjudicate, write the report.
**Change no code.**

```text
$review-project  scope -> audit N lenses -> verify each finding -> reviews/NNN-*.md
                                                                            |
$create-plan     brainstorm -> plan -> review + simplify -> refine  <--------+
$implement-plan  implement -> review -> refine -> next batch -> closing gate
```

This produces a document, not a change. It does not fix, refactor, or improve anything, and it
does not write a plan. Its output is evidence the human reads before deciding what is worth
doing; `$create-plan` is where a decision gets made.

Why not the `reviewer` agent: `reviewer` judges a diff against a task, needing changed code and
a specification. Here nothing has changed and there is no specification — the question is what
the code *is*. Different question, different agent (`auditor`).

Cost: one `auditor` per lens at `xhigh`, then one `auditor-verify` per surviving finding at
`high`. Five lenses producing thirty findings is 5 + 30 spawns, and the verify pass is the
volume — which is why refuting one named claim is priced below auditing a whole scope. Scope is
the cost control.

This skill is the simplest case of the workflow's split — **writers inline, readers dispatched
concurrently.** It has no writer phase but the report, which is the parent's; every spawn is a
read-only auditor, and they go out together in Sections 4, 5, and 7.

## 1. Scope it, and say what is out

The invocation argument is the scope: a path, a subsystem, or nothing. A scope is a set of
directories you can actually cover — take the repository layout seriously and count files
before committing.

- Argument given: use it, confirm it exists, count what is in it, print that.
- No argument: do not silently audit everything. Inspect the layout, propose two or three
  candidate scopes with file counts and a recommendation, and **ask.** This is the one
  interactive point, and it is here because auditing the wrong half of a repository wastes the
  whole run.

State exclusions explicitly: vendored and third-party directories, generated code, build
output. Generated files are a trap — a finding against generated code is noise and its fix
lives in the generator.

Print the scope, exclusions, and file count before spawning anything. Where the scope is too
large to cover honestly, say so and propose two reviews rather than a thin audit of everything.

## 2. Choose the review number: `max + 1`

Highest numeric prefix in `reviews/*.md`, plus one. Never fill a gap, never reuse — the same
rule plans follow, so a citation like "review 003, finding A4" stays resolvable. Use `001` and
create the directory when none exists. Halt on a collision.

## 3. Read the project's own rules first

Before any lens runs, read the `README`, `CONTRIBUTING`, applicable `AGENTS.md` files, and any
guideline documents under `docs/`. Print what you found and what it governs.

A local convention differing from the language default is usually a decision, not a defect, and
an audit reporting it as a smell is one the human stops trusting on the first page. Where the
repository documents rules with IDs, cite them; where it documents a deliberate deviation,
findings against it are wrong.

Every `auditor` gets this brief — scope, exclusions, build and test commands, applicable
guideline documents — established once, here, so no spawn rediscovers it.

## 4. Spawn the lenses concurrently

One `auditor` per lens, all in a single message. They are read-only so they cannot conflict,
and one lens each keeps them sharp: an agent asked to find everything finds the obvious thing
on every axis and the deep thing on none.

Default lenses:

1. **Architecture and design patterns** — module boundaries and layering, coupling and
   dependency direction, patterns used well, misapplied, or *missing* where the code strains
   without one; plus abstractions that do not earn their place.
2. **Code smells** — duplication, functions and files doing too much, god objects, feature
   envy, primitive obsession, shotgun surgery, dead code, comments contradicting the code.
3. **Correctness and robustness risk** — error and failure paths, resource lifetimes, boundary
   conditions, integer and buffer handling, concurrency and reentrancy, partially updated state
   on a failed path. This lens produces the `critical` findings if any exist.
4. **Test coverage and testability** — behavior with no test, vacuous tests that would pass
   without their production code, tests that do not run on the host, and code that cannot be
   host-tested for want of a seam. Testing is mandatory here and tests are host-native, so this
   lens is not optional and its findings are not stylistic.
5. **Conventions conformance** — only where §3 found documented rules; cite rule IDs. Skip the
   lens entirely when the repository documents no conventions, and say so. Inventing a rule to
   cite is a defect, not thoroughness.

Adjust the lens set to the project and say what changed and why. Adding a lens is cheap;
dropping one silently is not.

## 5. Verify every finding before it reaches the report

Dispatch a fresh **`auditor-verify`** per surviving finding — that agent's whole job is to
refute one named claim, and it defaults to `REFUTED` when uncertain. **Issue them in a single
message**, one per finding: a verification pass sent one finding at a time turns the cheapest
step here into the longest. Where the surviving set is large, use as few messages as the
harness will take rather than a loop of one.

This is what makes the report worth reading. An audit's characteristic failure is not missing
something — it is a confident, well-written finding that is not true: a path that moved, a race
on single-threaded data, duplication between functions differing where it matters. Such a
finding survives into a plan and is found imaginary only when somebody tries to fix it.

- `REFUTED`: drop it, and record it under `Rejected` with the refutation so the next review
  does not re-raise it.
- `CONFIRMED`: it goes in, with any correction to severity or sites.
- Disagreement about severity: the parent decides and says so.
- A finding of its own under `noticed in passing`: that is unverified and never enters the
  report as a finding. Either it warrants a fresh `auditor` on the right lens, or it is a line
  in `Not covered`. Never promote an unverified observation.

Never skip verification to save spawns. Where the finding count makes verification
unaffordable, the lenses over-reported: push back on severity first, verify what remains, and
say in the report that you did. Deduplicate before verifying, not after.

## 6. Adjudicate — and push back on the lenses

The parent is the only component seeing all lenses at once, and inflation is the default
failure. Reject findings with no named consequence. Demote aggressively — a `major` whose
consequence is "a future reader might be confused" is a `minor`. Reject anything that is a
design decision in disguise, because proposals belong to `$create-plan` with the human. Reject
findings against excluded code. Merge across lenses into themes: several findings with one root
cause is the most valuable output, because it changes what the fix is.

Record every rejection with its reason; a finding that quietly vanished makes the report
unauditable.

## 7. Ask what was missed

Spawn one final `auditor` with a completeness lens: given the scope, exclusions, and confirmed
findings, what part of the scope did no lens read, and what class of problem could this lens set
not see? Put its answer verbatim under `Not covered`. An audit that does not say what it missed
reads as complete, and the human then plans against it as though it were.

## 8. Write the report

The parent writes it, at `reviews/NNN-<slug>.md`, the slug naming the scope. That follows the
same rule `$create-plan` does — **the phase that writes a file runs inline, and every dispatched
phase is read-only.** The findings were produced by agents not briefed on each other and
independently verified by agents trying to refute them, so the report is a synthesis of
adjudications only the parent made, and no brief would let a fresh agent reconstruct them. Any
plan built from it is reviewed downstream by `plan-reviewer` and `plan-simplifier`.

Sections, in order: `# NNN — Review: <scope>`, then `## Scope`, `## Not covered`,
`## Summary`, `## Themes`, `## Findings`, `## Rejected`, `## Suggested plan slices`.

`## Suggested plan slices` is a sizing note, not a plan: name the slice, list finding ids, say
roughly how big it is and what comes first. The moment it contains an approach, an interface, or
a task list, it has pre-empted the design conversation `$create-plan` exists to have — and a
design nobody agreed to then arrives wearing the authority of a review.

## 9. Halt conditions

- A review-number collision.
- The scope is unclear and asking did not settle it.
- The scope is too large to audit honestly and the human has not chosen a split.
- A committed secret — report the path and that it exists, never the value, and stop. This
  outranks finishing the report.

A lens returning nothing is not a halt; "in good shape on this lens" is a real result. Neither
is a high finding count — that is §6's job.

## 10. Hand over and stop

Report the review path, finding counts by severity, the themes, and the suggested slices. Then
stop. Do not write a plan, do not fix anything, and do not invoke `$create-plan`. Say the next
step is an explicit `$create-plan` invocation citing the report and the finding ids.

The human decides which slice is worth doing, and that decision is the whole point of producing
a report instead of a change.

## Hard constraints

- Read-only for code, for the parent and every spawn. The only file created is the report.
- Read-only Git only — status, diff, log, show, blame. `git log` and `git blame` are useful
  here: churn and authorship distinguish a deliberate pattern from an accident.
- Do not run the build or test suite to produce a finding.
- Never invent a finding, a rule ID, a path, or a line number. Every finding is evidenced by an
  `auditor` and survived an `auditor-verify`, or it is not in the report.
- Never read or print a secret.
- Do not edit an existing review report; a superseded review stays as written and a new audit
  takes a new number.
