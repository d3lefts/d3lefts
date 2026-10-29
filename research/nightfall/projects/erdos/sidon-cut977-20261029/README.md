# Erdős #44/#329 — a cyclic-cut Sidon bridge with exact local optimality

**Date:** 2026-10-29. **Status:** verified finite construction and exact fixed-template optimality certificate; not a new asymptotic theorem, a worldwide finite record, or a solution of either open problem. The source Bose–Chowla theorem is classical.

## Quantitative comparison (identical five-element prefix)

| Witness | Size | Largest element | Size/sqrt(largest) |
| --- | ---: | ---: | ---: |
| NIGHTFALL draft PR #68 | 974 | 1,794,091 | 0.7271712887 |
| **Cyclic-cut improvement** | **977** | **1,766,378** | **0.7351106932** |

Every unordered sum of the 977 marks (477,753 sums including diagonals) is distinct. The size improves by 3, while endpoint decreases by 27,713. Exact density comparison: `977²×1794091 − 974²×1766378 = 36,791,472,611 > 0`. The improvement in normalized coefficient is 1.09182%. This is a strict **same-family NIGHTFALL witness improvement**, not an external record.

## Certified mechanism

Let `p=1009`, `v=1018080`, `F=F_p[u]/(u²−11)`, and `θ=7+u`. The 1009 discrete logarithms of field elements `a+u`, `a∈F_p`, form the standard Bose–Chowla modular Sidon set `S`. Its exponent at sorted index 224 is 230092. Rotate the cyclic source as `Q=sort((S−230092) mod v)`, translate `Q` by 752750, remove the 37 source indices hard-coded in the checker, and join the unchanged prefix `{1,2,4,8,13}`.

For this **fixed cyclic cut and translation**, enumerating the complete original unordered-sum collision relations yields 57 deletion hyperedges. The standalone checker validates a packing of 37 **pairwise disjoint** hyperedges: any feasible repair must delete at least 37 source marks. It simultaneously checks an explicit 37-mark deletion set hitting all 57. Therefore the deletion optimum **equals 37** for this template, certified by direct combinatorial witnesses without trusting any MILP solver, tolerance, or floating-point objective. This does **not** certify optimality among other cuts, shifts, field sizes, or arbitrary Sidon constructions.

## Reproduce

```sh
python3 research/nightfall/projects/erdos/sidon-cut977-20261029/audit.py
```

Python standard library only. The checker independently rebuilds the field orbit and all modular source sums, directly enumerates every collision in the original 1,014-mark union, checks the disjoint-packing lower bound and deletion-set upper bound, re-enumerates all survivor sums, and validates SHA-256:

`12a705e48f71b1d6a01dae51e560573c7da678a123368cbdb82ed2715b53bed8`.

The fuller originating research package also includes four adversarial tampering tests, separate source code paths, experiment logs, witness text, complete 57-edge collision hypergraph and a SHA-256 manifest.

## Search protocol and failure log

- **Single translation, fixed q=1009:** best 974 and 1,794,091, prior PR #68; plateau.
- **30 multiplicative automorphisms** (45 MILP refinements): no normalized-density gain.
- **Six nearby prime fields** q=1013, 1019, 1021, 1031, 1033, 1039 (108 MILP refinements): no normalized-density gain.
- **Cyclic cut / representation change:** 137-cut preliminary screen, 41-neighbor refinement, and 260-cut broader sweep (2,080 exact-model trials plus fine refinements); best 977 and 1,766,378. Finite search windows are **selective**, not exhaustive.

**Open mathematical target:** To genuinely improve the established infinite limsup bound `1/sqrt(2)` for #329, seek uniform-in-prefix bounds retaining at least `(1−δ)q+o(q)` marks with endpoint at most `(2−ρ)q²+o(q²)` along an infinite chain, with `ρ>4δ−2δ²`. The 977-mark numerical witness supplies no such uniform theorem. Preserving each growing prefix is essential; a single finite density above `1/sqrt(2)` cannot resolve #44/#329.

**Priority references:** https://www.erdosproblems.com/44 · https://www.erdosproblems.com/329 · https://github.com/d3lefts/d3lefts/issues/49 · previous NIGHTFALL witness https://github.com/d3lefts/d3lefts/pull/68. Dated external novelty audit and non-author mathematical refereeing remain pending.