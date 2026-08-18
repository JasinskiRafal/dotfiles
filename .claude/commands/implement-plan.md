---
description: Drive one plan file to done — implement, review, refine, repeat — stopping only at the end or on a hard halt
argument-hint: [--commit] <plan file, e.g. plans/007-uart-dma.md>
model: opus
---
Drive the plan file below from its first task to its last. You are the orchestrator: you
read, you delegate, you adjudicate, you report. You do not write production code yourself
— every implementation and every review is a fresh subagent.

Unlike `/execute`, this does **not** stop for the human between batches. It runs to the
end of the plan or to a hard halt. That autonomy is the reason the rules below are strict
rather than advisory.

**Cost shape, so it is not a surprise.** Orchestration runs on opus, each implement pass on
sonnet, and each batch is reviewed by one or two opus agents. A twelve-task plan needing no
refinement is roughly 12 implementer and 12–24 reviewer spawns; a plan needing two refine
passes per batch roughly triples the review count. Prefer a short plan for a first run.

## 1. Parse the arguments, then read the plan in full and critique it

The argument at the end of this file carries the plan path and optionally the flag
**`--commit`**. Strip the flag; the remaining token is the plan file. Without the flag the
loop never commits, which is the default.

**When `--commit` is present, check two preconditions once, before batch 1. Each unmet one
is a halt.**

- **The working tree is clean** — `git status --porcelain` must be empty. Otherwise the
  first commit would capture unrelated work in progress. On failure, report the dirty
  paths and stop; the human decides whether to commit them or set them aside.
- **HEAD is not the default branch** — resolve it with
  `git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to whichever of
  `main` or `master` exists when there is no remote HEAD. You may not create a branch, so
  on the default branch report the `git switch -c <name>` command for the human and stop.

Then read the whole file — Goal, Context, Constraints, Tasks, Out of scope, Open questions.
Then say what is wrong with it. Ambiguity, a task that contradicts the codebase, a
verification step that cannot be run, an Open question whose answer changes a task: raise
all of it now.

If a problem can be settled by inspecting the repository, settle it and say so. If it
cannot, that is a **halt** — not a guess, and not a "reasonable assumption" recorded in a
footnote.

## 2. State the batching before spawning anything

Default: **one batch per `###` heading inside the plan's `## Tasks` section**, whatever
that heading is labelled. Merge two adjacent tasks only when one is meaningless without the
other, and name the merge and its reason. There is no human at a checkpoint to confirm a
proposed batching, which is exactly why the default is mechanical rather than a judgement
call.

Match on position, not on wording. Plans in the wild use at least three task-heading
conventions — `### Task 1 — …`, `### 1. …`, and `### Phase A — …` — and a rule keyed to any
one of them silently finds nothing in the others. The `###` headings under `## Tasks` are
the batches in all three.

If the plan has no `## Tasks` section, or that section contains no `###` heading, that is a
**halt**: say so and let the human tell you how the file is meant to be divided. Do not
invent a batching from prose.

Print the batching, then begin.

## 3. The per-batch loop

```
fresh implementer  (batch tasks + plan path + accumulated-changes note)
  ├─ reports a plan/repository discrepancy ──────────────► HALT
  ├─ reports an unexplained verification failure ───────► HALT
fresh reviewer      ┐  spawned in ONE message, both read-only
conventions reviewer┘  (only where the project defines one, and it applies — §6)
adjudicate every finding
  ├─ accepted findings? → fresh implementer (fix mode) → re-review
  │    └─ not clean after 3 refine iterations ──────────► HALT
commit the batch  (only with --commit; never before review passes)
emit batch report, continue without waiting
```

## 4. A fresh agent for every assignment

Never reuse an implementer as its own reviewer. Never reuse a reviewer across a refine
iteration — a reviewer that has already approved its own reasoning is not an independent
second look. Every spawn is a new agent with no memory of the last one.

## 5. Spawn the reviewers in one message

They are read-only, so they cannot conflict and they should run concurrently. Never run two
file-mutating agents at the same time.

## 6. The second review angle is conditional

Some repositories define their own conventions reviewer — a project-level
`.claude/agents/guidelines-reviewer.md` or similar — that audits a diff against that
project's written coding rules. Check whether one exists before batch 1 and say what you
found.

- **No such agent** — spawn the correctness `reviewer` alone, every batch, and say so once.
- **It exists** — spawn it beside `reviewer`, but only when the batch's changed-file list
  actually falls under its remit (typically source files, not markdown, compose files, or
  shell scripts). When it does not apply, record in the batch report that the pass was
  skipped and why. Inventing a rule ID for a file the rules do not govern is a defect, not
  thoroughness.

## 7. Scope each review explicitly

`git diff` shows the whole working tree against `HEAD`, so by the third batch it contains
the first two. Narrowing it with git is forbidden. Give every reviewer three things
instead: the batch's task text, the changed-file list the implementer reported, and a note
naming the files earlier batches already touched whose changes are reviewed and out of
scope. A finding against an already-reviewed file is answered with that note, not a fix.

If an implementer's report omits the changed-file list, ask it for the list rather than
reconstructing one from `git status` — the point of taking it from the report is that it
records what that agent believes it changed, which is what the review is scoped to.

**With `--commit` active this gets simpler.** Every approved batch is already a commit, so
from batch 2 onward the scope is exactly `HEAD~1..HEAD`, and you tell the reviewer so. The
three-part prose scope above remains the fallback for two cases: the whole no-flag path,
and batch 1, where no commit from this run exists yet. Say which of the two you are using.

## 8. Adjudicate every finding — do not obey blindly

Accept a `blocking` or `should-fix` finding when it is technically justified and inside the
batch's scope. Reject the rest, each with a one-line rationale that goes into the report.
A `nit` never starts a refine iteration. An accepted finding that turns out to require a
plan change is a halt, not a fix.

## 9. Commit the batch — only with `--commit`, and only after review

Once the batch's reviews come back clean and its findings are adjudicated, `git add` the
paths the implementer reported — **plus the plan file if its checkboxes changed** — and
commit them. Never before review, never a partial batch, never a file the implementer did
not report.

The plan file is included deliberately: the implementer ticks its checkboxes as it goes, and
leaving those edits out would leave the tree dirty from batch 2 onward, falsifying §10's
claim that a halt leaves only the failing batch uncommitted.

The message is mechanical, because these are scratch commits:

```
plan NNN batch M: <the batch's task heading, verbatim>
```

No body, no co-author trailer, no generated-with line. **These commits are provisional and
exist to be squashed** — they buy exact review scope and a recoverable halt, not history.
Do not "improve" them into messages meant to survive; the human writes the one that does.

A commit here means *implemented and reviewed clean*, which is the property that makes
`HEAD~1..HEAD` a scope a reviewer can trust in §7.

## 10. Halt conditions — hard stops, every one

- The implementer reports a **plan/repository discrepancy**, including work already
  present.
- A verification command **fails for a reason the implementer cannot explain**.
- A batch is **not clean after 3 refine iterations**. This is deliberately tighter than the
  five used by workflows that stop for a human at every step, because here nobody is at the
  checkpoint.
- A task needs a **new third-party dependency** — that requires asking, with a usage example
  and an honest cost/benefit — or needs a decision the plan left in Open questions.
- A task calls for a **test the plan did not authorize**. Testing is opt-in.

On any halt: emit the full report for the batches already completed, state the halt reason
and precisely what is needed to resolve it, change nothing further, and stop. A halt is a
successful outcome of this command, not a failure of it.

**With `--commit` active, a halt leaves every approved batch committed and only the failing
batch dirty and uncommitted.** That is the state a human wants to inspect. Say so in the
report, and offer `git reset --soft HEAD~1` as text if they want the last batch unpicked —
it is the human's to run, so it goes in the report and nowhere else.

## 11. Not a halt

A check that needs a resource you cannot reach from here — target hardware, an accelerator,
a device, a deployed environment, credentials you do not hold. Record it as a **deferred
check** and continue, naming the exact command and the machine it belongs on. Where the
project batches such checks into one pass at the end of a plan series, follow that.

## 12. The closing gate

After the last batch, spawn a fresh `verifier` for the evidence gate and a fresh `reviewer`
with whole-plan scope. Claim completion only when both come back clean.

If either does not, adjudicate its findings as in §8 and run a fix pass, then re-run the
gate — under a bound of its own: **3 gate iterations**, counted separately from any batch's.
The cap in §10 is per batch and does not carry over to a gate that belongs to no batch.

On exhausting the gate bound, **halt**: report the unresolved findings, the evidence
gathered so far, and every batch that did pass, and make no further change. An unbounded
loop at the end of a run is where the most work has already been spent, which is exactly
why this bound exists.

## 13. The final report

- the plan path, and the batching used;
- batches completed, and the files changed by each;
- verification evidence — real command output, not claims;
- review history and refine-iteration count per batch;
- findings **rejected**, and the rationale for each;
- deferred checks, with the exact commands and the machine to run them on;
- **with `--commit`: the commit list**, one line per batch with its short SHA, plus the
  reminder that they are provisional and the `git rebase -i <base>` command for squashing
  them;
- the git commands the human may choose to run.

## 14. Hard constraints

- **Git is tiered by reversibility.** Read-only (`status`, `diff`, `log`, `show`,
  `blame`) is always allowed. The **additive** tier — `git add` and `git commit` — is
  available to *you only*, only with `--commit`, and only at the post-review checkpoint in
  §9; this is the single carve-out in `~/.claude/CLAUDE.md`'s version-control policy, and it
  does not widen. No agent you spawn may commit. The **destructive** tier — all of
  `git stash` and `git checkout`, plus `restore`, `clean`, `rm`, `reset --hard`, `rebase`,
  `commit --amend`, `push`, `branch -D`, `tag -d`, `worktree add`/`remove` and the rest — is
  the human's alone, and some projects deny it mechanically in `.claude/settings.json`.
  Never branch, switch, or create a worktree. Put any command you may not run in the report
  for the human.
- **A project that forbids agent commits outright wins.** If the repository's own
  `CLAUDE.md` or settings deny `add`/`commit`, `--commit` is unavailable there: say so and
  run the unflagged loop instead of working around it.
- Never read or print a secret or an API key.
- Do not edit the project's guideline or convention documents. The loop is held to those
  rules; it does not rewrite them.
- Do not edit the plan file beyond ticking its checkboxes.

## Why running several phases unattended does not break the step-boundary rule

`~/.claude/CLAUDE.md` requires the human to start each phase because each phase belongs on a
different model, and rolling forward inside one session would run the next phase on the
current session's model. Delegation does not have that problem: every agent pins its own
model in its own frontmatter, so implement runs on sonnet and review runs on opus whatever
this session is. Spawning a subagent is the one way to cross a phase boundary while
preserving exactly what the boundary protects. Do not read this loop as a licence to cross
a boundary in-session.

## Related entry points

This drives one plan file. `/execute` remains the batch-at-a-time alternative for a plan the
human wants to watch as it goes, and `/review` remains available for a standalone pass over
the current diff.

Plan file: $ARGUMENTS
