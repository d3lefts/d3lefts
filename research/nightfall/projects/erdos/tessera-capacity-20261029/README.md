# TESSERA — universal Sidon append capacity and two exact unrestricted optima

**Date:** October 29, 2026. **Assignment:** [#122](https://github.com/d3lefts/d3lefts/issues/122) (self-designed), supporting standing [#95](https://github.com/d3lefts/d3lefts/issues/95).

**Scientific status:** exact elementary corollary of *classical* Sidon bounds and two fully enumerated finite, prefix-specific optimality results. **No claim of new asymptotic constant, Erdős #44/#329 solution, or established original literature priority.**

## Theorem 1 — source-independent asymptotic capacity obstruction

Let A be any integer Sidon prefix of size m. Let F be **any** K-element set of prospective new integers, disjoint from A, with A∪F⊂[1,M]. Suppose R⊂F and C=A∪(F\R) is Sidon; put d=|R|.

The classical Erdős–Turán/Lindström explicit upper bound for Sidon sets states

    |C| ≤ sqrt(M) + M^(1/4) + 1.

Therefore, since |C|=m+K−d,

    d ≥ max{0,m+K−floor(sqrt(M)+M^(1/4)+1)}.

For parameter families m/q→α, K/q→1, M/q²→λ∈(0,∞),

    liminf_{q→∞} d/q ≥ max{0,1+α−sqrt(λ)}.

For λ=2, any α>sqrt(2)−1 forces **linearly many deletions even if the new block is not Singer or algebraic**. If α=1, the mandatory fraction is at least 2−sqrt(2)≈0.585786. This is a necessary capacity budget, **not** a theorem forbidding all nested Sidon constructions: scale separation q_next≫m evades its positive threshold.

**Exact interval-arithmetic corollary** for whole q-scale Singer prefixes m=K=q+1 and endpoint M=2(q²+q+1):

| q | M | Sidon total-cardinality upper bound | Minimum deletions |
|---:|---:|---:|---:|
| 5 | 62 | 11 | 1 |
| 7 | 114 | 14 | 2 |
| 25 | 1302 | 43 | 9 |
| 1009 | 2,038,182 | 1466 | 554 |

Run `python3 verify_capacity.py`; no floating point is used. The program encloses fourth roots and square roots between rationals of denominator 10^6, verifies the floor is unambiguous, and applies the classical bound.

## Theorem 2 — unrestricted optimal finite append for q=5 and q=7

**Case q=5:** v=31, classical cyclic perfect difference set D={0,1,3,8,12,18}. Freeze the prescribed prefix A=1+D={1,2,4,9,13,19}. Among ALL subsets B of the consecutive interval **[31,61]**, if A∪B is an ordinary integer Sidon set, then **|B|≤2**. The witness B={32,46} attains equality.

**Case q=7:** v=57, D={0,1,3,13,32,36,43,52}; prefix A={1,2,4,14,33,37,44,53}. Among ALL subsets B of **[57,113]**, the exact maximum is **|B|=3**, attained by B={90,98,112}.

These bounds apply to every possible set B, with **no Singer, modular, affine or source-family restriction**.

### Exhaustive proof certificate (small finite instances only)

If A∪B is Sidon, all positive differences between distinct members of B must avoid the positive difference set Δ(A). Otherwise a positive common difference d=b_j−b_i=a_j−a_i creates an A+B=A+B collision. Form graph G on the integers 0,…,v−1, connecting x<y precisely when y−x∉Δ(A). Every admissible B−v is a clique in G.

Enumerate **every clique** recursively (not only maximal ones), and independently check **every unordered pair sum** of A∪(v+clique). There are no cliques larger than the listed maxima:

| v | Clique sizes 0,1,2,3,4,5 | Sidon-acceptable count by size | True maximum |
|---:|---|---|---:|
| 31 | 1,31,128,22 | 1,27,69,0 | 2 |
| 57 | 1,57,692,1683,644,3 | 1,23,73,19,0,0 | 3 |

The q=5 and q=7 sources have every nonzero ordered modular difference exactly once, independently checked. Even each graph-admissible 3-clique at q=5 and each 4- and 5-clique at q=7 fails a direct Sidon sum test. Witnesses in the table pass the same oracle. Deliberate B={v,v+1} is rejected for both prefixes, establishing a negative control. A second NetworkX maximal-clique calculation on a separate code path agrees: clique numbers 3/5 and 22/3 maximum cliques.

Run `python3 verify_unrestricted.py` (stdlib only); certificate-summary SHA-256 must equal:

`2c8de726cdd8878ae2eee1a8ec569550f026d2c69fd5ec9067fdc4fc1481ca6d`.

**Comparison with exact affine Singer census:** independent exploration over all units×cuts found minima of 4 deletions from six marks (930 pairs) for q=5, and 5 from eight marks (2,052 pairs) for q=7; the witnesses above are affine instances. Thus an affine Singer family attains the globally optimal append size at these particular prefixes and windows. All finite statements are independent of the newer field's algebraic structure.

## What this does and does not establish

- **Established:** source-independent necessary deletion capacity for growing prefixes; complete fixed-prefix/interval optima for v=31 and v=57.
- **Not established:** that these small optima persist uniformly in q; a stronger general-than-classical inequality; original mathematical priority; an improved infinite Sidon coefficient.
- **Next mathematical decision:** seek exact clique/independence bounds for the difference-avoidance graph of a long Singer prefix, then test whether the resulting source-independent obstruction is uniform in q. Alternatively seek recursively closed prefixes of size m=o(q) and low mixed-collision repair, since positive capacity constraints vanish in that scale regime. Avoid spending effort on more q1009 constant polishing.

## Prior art

- Erdős and Turán (1941) / Lindström (1969): classical bound `R(M)≤sqrt(M)+M^(1/4)+1`. See https://www.erdosproblems.com/30 .
- Singer (1938): cyclic perfect difference sets. https://personal.ntu.edu.sg/bernhard/Publications/pub/Singer.pdf .
- The infinite-sequence Sidon coefficient question remains open; Krückeberg 1961 ≥1/sqrt(2) and universal upper ≤1. https://www.erdosproblems.com/329 .
- Recent 2026 finite Sidon upper-bound constants are sharper in lower-order terms; their use would slightly tighten the finite capacity budget. See https://terrytao.wordpress.com/2026/10/28/on-the-diameter-and-distribution-of-sidon-sets/ .

**Review gates:** external same-scope prior art and independent non-author mathematical proof referee pending. Keep this in a draft PR. Do not add to public Original Findings before Vesper's approval.
