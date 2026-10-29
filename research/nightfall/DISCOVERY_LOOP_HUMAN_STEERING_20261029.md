# CONSTELLATION — Human-Steered Discovery Loop v1.1

**29 October 2026 · evidence status: bounded local software pilot**

## Architectural decision

Keep the human in charge of executing each research experiment. The system proposes and orders tests. The operator examines the hypothesis and the exact resource estimate, can redirect to an alternative, and must explicitly approve a single test before execution. There is no background or scheduled execution. Every approved target and any explanatory note are preserved in the exact finite run ledger.

## What changed

1. The core now exposes candidates(state,limit): a deterministic sorted list of untested (n,m) designs, an explicit local-transfer gap prediction, ordering score, source explanation, and exact number of anchored subsets to enumerate. Scores are **proximity/cost/surprise heuristics**. They are never reported as calibrated information gain, predicted theorem significance, or novel evidence.
2. The UI initially presents the top four candidates, with a control to inspect the full finite scope. Selecting the recommended candidate requires an explicit **Approve and run one test** action. Selecting any alternative requires a nontrivial note (10–280 characters) explaining the research reason. Every click authorizes exactly one finite enumeration, never an unreviewed multi-step batch.
3. The evidence record retains the exact target and policy rank at approval, whether the option was recommended or human-redirected, and the operator's text. The note is user-supplied context and does not establish an identified researcher, independent reviewer, mathematical fact, or date.
4. The work counter shows approved tests, exact anchored subsets inspected, falsified local predictions, strict finite gaps, and human redirections. These are *bookkeeping quantities*. They do not measure performance relative to alternative discovery systems.
5. Replay reconstructs and checks every approved selection and calculated outcome against prior state. It rejects forged decision ranks, tampered notes, modified mathematical results, mismatched residue ledgers, and any purported promotion to independent audit, peer review, Original Finding, or a larger resource budget.
6. Existing verified v1 local states remain readable. Previously executed steps lacking a user approval object are preserved as **LEGACY AUTOMATIC STEP**, never reclassified as human approved. All newly executed steps require review. The evidence/export schema remains v1 because both branches are explicit within its deterministic replay contract.

## Checkable acceptance

- A first explicit approval computes the exact finite (15,6) minimax 3, with elementary floor 3.
- The next top-ranked proposal is (16,6), with predicted lower-bound gap 0. If approved, full exact enumeration yields minimax 3 and floor 2. The falsified prediction is retained as an unreviewed mathematical residue.
- The operator may instead choose (14,6) with a written justification, producing a different, reproducible study path. Attempting this change with no justification leaves state unchanged.
- A direct all-binary-mask test uses a structurally distinct enumeration implementation from the anchored-subset production algorithm. Browser smoke checks per-step approval, ranked alternatives, refusal without reason, persistence, tamper rejection, and mobile overflow.
- A saved state with missing/modified review authority or a claimed review status fails local reconstruction. **Browser replay remains a same-code integrity check, not a cryptographic attestation or independent scientific audit.**

## Evaluation path toward meaningful research discovery

With consented research inputs, run the same interface against real unresolved assignments under a preregistered budget. Compare three human-visible, budget-matched approaches: fixed static question order, algorithmic next-test suggestions accepted by the operator, and human-redirection alternatives. Track *independently checked new constructions, valid counterexamples, novel proof obligations resolved, and measured compute cost*. Make falsified hypotheses and negative comparisons visible. Require independent novelty assessment before upgrading any discovered result.

The design objective is a higher yield of *valid scientific decisions per researcher attention and experiment budget*, while preserving a clear human veto at each test. This release claims implemented steering and auditability only.