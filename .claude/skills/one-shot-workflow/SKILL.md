---
name: one-shot-workflow
description: Run the complete design, planning, execution, verification, and code-review loop autonomously, including fixing review findings and repeating checks until clean. Use only when the human explicitly invokes `$one-shot-workflow` or says to use the one-shot workflow; never select it implicitly.
---

# One-shot workflow

Complete one requested change without checkpoints between phases or execution
batches. Preserve every repository agreement that does not specifically require
a phase or batch checkpoint.

## Prepare

1. Honor the active `AGENTS.md` instruction chain, then read the complete
   sibling skills for `brainstorming`, `writing-plans`, `executing-plans`,
   `verification-before-completion`, and `requesting-code-review`.
2. Follow their quality criteria and constraints. Override only instructions
   that require stopping, waiting for approval, suggesting the next phase, or
   ending after a phase.
3. Inspect the working tree without changing Git state. Preserve unrelated
   human changes and establish which existing changes belong to this request.

## Run the loop

1. **Design:** Establish a concrete design from the request and repository
   evidence. Make reversible, in-scope assumptions autonomously. Stop for input
   only when a missing decision would materially change scope or architecture.
2. **Plan:** Write the numbered plan under `plans/` as required by
   `writing-plans`. Do not pause for approval.
3. **Execute:** Define small internal batches and implement them in order. Run
   each batch's verification before continuing, but do not ask for batch
   approval. Never add tests unless the human or plan explicitly requires them.
4. **Debug:** If verification fails unexpectedly, read and follow the sibling
   `systematic-debugging` skill. Prove the cause, apply the smallest in-scope
   fix, and rerun the failed verification.
5. **Verify:** After all batches, perform the completion verification with
   fresh command output. Do not substitute code inspection for executable or
   target-specific checks when those checks are available.
6. **Review:** Inspect the complete diff against the request and plan. Fix every
   in-scope `blocking` and `should-fix` finding, then repeat completion
   verification and review. Fix nits when they are low-risk and in scope;
   otherwise report them.
7. Repeat the repair, verification, and review cycle until no unresolved
   `blocking` or `should-fix` finding remains.

## Stop conditions

Stop and ask the human only when:

- a material product or architecture decision cannot be resolved from the
  request or repository;
- continuing requires authority outside the original scope;
- unrelated working-tree changes cannot be preserved safely;
- required access or hardware is unavailable; or
- repeated evidence-based debugging reaches an impasse with no new evidence to
  gather.

Do not stop merely because a phase ended, an internal batch completed, a
verification failed, or review found an in-scope defect.

## Finish

Report the plan path, internal batches, changed files, verification evidence,
review result, and any remaining manual or hardware checks. Never claim success
without fresh evidence. Do not change Git state; when useful, give the human
the exact read-only inspection or commit commands they may choose to run.
