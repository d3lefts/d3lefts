# NIGHTFALL — adaptive witness-rank contraction core (post-merge PR #316)

Date 2026-11-10/11. Research lead Devin J. Wright. **Status:** three new Lean declarations under review; the predecessor 12 finite static witness/conflict declarations are already kernel-checked and merged through PR #311. This is not a proof that every system is cheaply discoverable, and does not claim historical novelty.

## Objective
Close the exact **one-step** bridge behind the written universal witness-rank discovery theorem r <= D(f) <= wr. Model static states x, exact sensor observations rho_i(x), target f(x), history Q of queried sensor labels, and block-sensitive changes with admissible witness states. Define remaining packing rank r_Q(x) as the maximum size of a pairwise disjoint family of sensitive blocks that avoid Q.

## Mechanism and formal theorem candidates
1. remaining_rank_drop: whenever B is nonempty, sensitive at x and disjoint from Q, a bound r_Q(x) <= r+1 implies r_(Q union B)(x) <= r. Enlarge any disjoint packing outside Q union B by B itself, contradicting r+1 if r more blocks survive.
2. uniform_query_decreases_rank: choose the SAME block B from the current observation fiber, uniformly sensitive for every state y compatible with the current query set Q. Rank drops for all compatible y, with no hidden-state dependence in witness selection.
3. remaining_rank_zero_certifies: if a uniformly revealing block exists whenever the observed fiber is unresolved, remaining rank zero forces the target to be determined already.

These concern arbitrary admissible static state spaces, finitely many heterogeneous sensors, and exact readings. The written construction obtains the full adaptive theorem by induction on rank, choosing a canonical block per observable fiber. The complete dependent decision-tree object, output correctness and query-cost recurrence are **not** kernel formalized by these three declarations. Computational effort to find a witness block is excluded from sensor-query cost.

## Negative controls
A two-state constrained system differing in two sensors has witness width w=2 and optimal D=1; so w is not a necessary lower bound on D. A greedy strategy for the address toy uses 3 observations while an optimal strategy uses 2. The exact checker now computes both facts and preserves failed initial CI receipts from incorrect greedy expectations.

## Prior art and provenance
Block-sensitivity/decision-tree theory is classical: Nisan (1989), Midrijanis (2004), and Chugh–Podder–Sanyal, FSTTCS 2023, Proposition 29. A globally new bound is not established merely by repackaging these constructions.

- Existing 12 Lean declarations: [CI #42927550285](https://github.com/d3lefts/d3lefts/actions/runs/42927550285), pinned Lean 4.35 / Mathlib 4.35, accepted standard axioms only, no sorryAx.
- Constructive greedy, N-ary address and 7792 palette tests: [CI #42927868279](https://github.com/d3lefts/d3lefts/actions/runs/42927868279), PASS.
- New AdaptiveRankDrop.lean must pass pinned CI before any kernel certificate or result status change.

Next gate: complete finite observation-fiber decision-tree construction with source-bound choices, then derive novel structural width/rank estimates or an efficient witness selector. Do not merge, publish or promote claims automatically.
