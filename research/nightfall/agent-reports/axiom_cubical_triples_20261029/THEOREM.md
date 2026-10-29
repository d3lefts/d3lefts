# AXIOM self-designed #188 — complete three-edge square-syndrome minimum in the hypercube

**2026-10-29 · Mathematical R1 / internal independent exact computation.**
Scientific owner: Devin J. Wright. Derivation, independent geometric enumerator: Axiom.
Related but distinct: Ryev's R1 incident-three-star exclusion in [PR #148](https://github.com/d3lefts/d3lefts/pull/148) and issue #140. The present classification does **not** prove Ryev's all-odd-n safe-edge rigidity or a new extremal Q7 value.

## Theorem and exact quantifiers

For any integer n≥3, write Q_n for the n-dimensional binary cube, and let \(\partial_\square E\) denote the collection of coordinate 2-faces containing an odd number of edges from an edge subset \(E\). For an edge triple \(E=\{e_1,e_2,e_3\}\), let:

- p(E) be the number (0–3) of edge pairs cofacial in a coordinate square;
- t(E)=1 if all three edges belong to one common coordinate square, and 0 otherwise.

**Theorem (elementary structural classification).**
\[
|\partial_\square E|=3(n-1)-2p(E)+4t(E)
\quad\text{and hence}\quad
|\partial_\square E|\ge 3(n-3).
\]
Equality holds **if and only if** all three edges are incident at a single cube vertex.

For n=7, a syndrome has exactly 12 squares and admits a three-edge preimage if and only if the preimage consists of three distinct edges incident to one vertex. There are exactly
\[
2^7\binom73=4,480
\]
distinct such syndromes. They do not arise from any edge set of size at most two.

**Scope:** this is a classification of square **syndromes coming from three edges**, not all 12-square closed cochains. It extends the combinatorial *completeness of the sector* discussed by Ryev; his proof that those syndromes are impossible for C4-free |G|>M_7 is a separate R1 theorem dependency requiring adversarial review.

## Proof

Each cube edge belongs to exactly n−1 coordinate squares. For any square σ, let r_σ∈{0,1,2,3} be the count of E-edges on that square. The parity bit satisfies
\[
r_\sigma\bmod2
=r_\sigma-2\binom{r_\sigma}{2}+4\binom{r_\sigma}{3}.
\]
Summing over squares gives the exact identity because any two distinct cube edges lie in **at most one** coordinate square; p(E) counts all such incidences, and t(E) counts whether the complete triple shares a square.

Since p≤3 and t≥0, the minimum is 3(n−1)−6. Equality forces p=3,t=0. Three distinct edges pairwise cofacial belong to precisely one of two geometries:

1. They all belong to one coordinate square (so t=1).
2. They share one vertex, with their three pairs lying in three different coordinate squares (so t=0).

To check completeness of this dichotomy, choose two cofacial edges e and f. If they are opposite edges of their square, any third edge cofacial with both is one of the other two edges of that square. If e,f are adjacent, a third edge cofacial with both must lie on that square **or** be incident at their common vertex. This follows by fixing the two flipped coordinate directions and observing that every further cube coordinate differs from the chosen square in an additional independent bit. No third geometry is possible. The first alternative has t=1, excluding equality; the second has p=3,t=0 and achieves it.

**Injectivity in Q7.** If \(\partial_\square E=\partial_\square F\) with |E|,|F|≤3, then the coboundary of E△F vanishes. The boundaries of coordinate squares generate the cycle space of Q_n: any closed cube walk can be reduced by commuting independent coordinate flips into 4-cycles, so an edge set with even incidence on every square is the gradient of a 0–1 vertex labeling, i.e. a cut. Every nonempty cut in Q_n has at least n edges (edge connectivity n, itself proved by induction on the two Q_(n−1) halves). In Q7 the symmetric difference has at most six edges, hence is empty. Thus the map E↦∂□E is injective on all edge sets of size≤3. The 4,480 vertex stars give 4,480 distinct syndromes; a ≤2-edge support cannot coincide with any of them.

For n=3 there is an instructive countercontrol: a three-edge vertex star is itself a cut, so its square syndrome is empty. This does **not** contradict the Q7 injection statement.

## Complete exact audit

Source: [verify_three_edge_sector.py](verify_three_edge_sector.py), standard-library Python. It reconstructs every vertex, edge and square directly from binary coordinates; enumerates every triangle in the pair-cofacial graph for Q3–Q7, checking that the only possibilities are the vertex-star and same-face families; checks all their square-syndrome weights. For Q7 it then tests **all 14,885,696 unordered three-edge sets** for 12-square syndrome, confirms **exactly 4,480** and rejects any nonstar equality case or duplicate syndrome. It separately enumerates all 100,128 two-edge syndromes, confirming disjointness.

Expected independent finite census:

| n | Edges | Squares | Three-edge stars | Same-square triples | Weight for star | Weight for same-square |
|---:|---:|---:|---:|---:|---:|---:|
| 3 | 12 | 6 | 8 | 24 | 0 | 4 |
| 4 | 32 | 24 | 64 | 96 | 3 | 7 |
| 5 | 80 | 80 | 320 | 320 | 6 | 10 |
| 6 | 192 | 240 | 1,280 | 960 | 9 | 13 |
| 7 | 448 | 672 | 4,480 | 2,688 | 12 | 16 |

Run:

\`\`\`sh
python3 research/nightfall/agent-reports/axiom_cubical_triples_20261029/verify_three_edge_sector.py
\`\`\`

## Research value and nonclaims

The consequence upgrades **three-edge sector classification** from "Ryev's listed 4,480 star configurations are examples" to "every three-edge-supported Q7 syndrome of weight 12 is one of those 4,480 configurations". It does **not** rule out 12-square syndromes supported on four or more edges, independently establish a stronger ex(Q7,C4) upper bound, determine any undecided Erdős problem, or elevate PR #148 to verified publication.

The identity follows elementary cubical incidence and standard edge-connectivity facts. It may well be classical. No same-scope mathematical novelty or external referee status is claimed. **Priority audit and adversarial attack remain open.**

**Falsifiers:** a nonstar three-edge subset of Q7 with exactly 12 odd-incidence squares; a duplicate between any distinct size≤3 supports; failure of the square-cycle spanning lemma; an input graph omitting one of 672 faces. Only after a separate independent referee check may the finite R1 theorem be considered for scientific promotion.
