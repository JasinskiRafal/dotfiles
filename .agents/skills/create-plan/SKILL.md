---
name: create-plan
description: Interactively turn a rough feature or work-item idea into an agreed design, then delegate creation and independent review of one numbered plan under plans/. Use only when the human explicitly invokes $create-plan; stop after handing over the reviewed plan and never begin implementation without separate consent.
---

# Create plan

Orchestrate the front half of the development pipeline:

```text
brainstorm -> agree design -> write plan -> review -> refine -> hand over
```

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

## 5. Review and refine

Spawn a fresh `plan-reviewer` with the complete agreed design and plan path.
Do not substitute the code `reviewer`; no implementation exists yet.

Adjudicate every finding. Accept findings that are technically justified and
inside the agreed design. Reject other findings with a one-line rationale for
the handover report. A nit alone does not require refinement.

When accepted findings exist, spawn a fresh `plan-writer` in refine mode with
only those findings, then spawn a fresh `plan-reviewer`. Never let a writer
review its own plan or reuse a reviewer across iterations. Halt when the plan is
not approved after three refine-and-review iterations and report the unresolved
findings.

Skip code and conventions reviewers because there is no implementation diff.
Record that skip in the handover.

## 6. Hand over and stop

Report:

- the plan path and concise design;
- human decisions versus inspection-derived constraints;
- out-of-scope boundaries;
- review history and refine count;
- rejected findings and rationale;
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
