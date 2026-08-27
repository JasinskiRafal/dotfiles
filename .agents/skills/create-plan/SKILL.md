---
name: create-plan
description: Interactively turn a rough feature or work-item idea into an agreed design, then delegate creation and independent review of one numbered plan under plans/. Use only when the human explicitly invokes $create-plan; stop after handing over the reviewed plan and never begin implementation without separate consent.
---

# Create plan

Orchestrate the front half of the development pipeline:

```text
brainstorm -> agree design -> write plan -> review + simplify (concurrent) -> refine -> hand over
```

The weight of the pipeline is deliberately on this end. A defect caught in the plan
costs one refine round; the same defect caught during execution costs a batch, a
review, a plan amendment, and every batch built on it since.

Delegate every specialist phase to a fresh custom agent. Keep the agreed design,
decision provenance, review findings, adjudication, and iteration count in the
parent context. Write no production file.

## 1. Determine whether design is needed

If the request is fully specified and mechanical, say why the design space is
already settled and continue to plan numbering. When the request defines what
but leaves shape-changing implementation or behavior decisions open, continue
through brainstorming.

## 2. Inspect and agree the design

Spawn a fresh `brainstormer` with the idea and relevant repository paths. Require
it to return constraints settled by inspection separately from genuinely open
decisions.

Answer repository-discoverable questions by inspection. Put only genuine open
decisions to the human, a few at a time, with the recommended alternative first
and concrete tradeoffs. If an answer opens another repository question, use a
fresh `brainstormer` scoped to that question.

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

Check the chosen number once more immediately before spawning the writer. Halt
if any file already uses it. If `plans/` does not exist, authorize the writer to
create it with the first plan file.

## 4. Write the plan

Spawn a fresh `plan-writer` in write mode with:

- the agreed design and its provenance;
- constraints and compatibility requirements;
- explicit out-of-scope boundaries;
- the fixed plan number.

The writer chooses the slug and writes exactly one
`plans/NNN-short-slug.md`. The parent never writes or patches the plan.

## 5. Review on two lenses, then refine

Spawn two fresh agents concurrently, in a single message, each with the complete
agreed design and the plan path. Both are read-only, so they cannot conflict and
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

When accepted findings exist, spawn a fresh `plan-writer` in refine mode with only
those findings — one refine spawn carrying both lenses' accepted findings, never
one per lens — then re-run both lenses. A refined plan is a new plan: a
simplification applied in one round can break coverage in a way only a fresh
`plan-reviewer` will see.

Never let a writer review its own plan or reuse a reviewer across iterations. A
round is clean when `plan-reviewer` returns `APPROVED`; a `SIMPLIFICATIONS_FOUND`
whose every finding was rejected with a rationale does not hold the loop open.
Halt when the plan is not approved after three refine-and-review iterations and
report the unresolved findings.

Skip code and conventions reviewers because there is no implementation diff.
Record that skip in the handover.

## 6. Hand over and stop

Report:

- the plan path and concise design;
- human decisions versus inspection-derived constraints;
- out-of-scope boundaries;
- review history and refine count, with both lenses' verdicts per round;
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
- Never change Git state. Spawned agents are read-only with respect to Git.
- Never inspect or print secrets or secret-bearing configuration.
- Never edit repository policy, guideline, source, build, test, or documentation
  files.
- Add test tasks only when the human explicitly requested tests in the agreed
  design.
- On every halt, report what was agreed, the exact reason, and what the human
  must decide or change.
