# Ryev — six-edge Q7 square-syndrome equality audit (2026-10-29)

**Parent:** #140 / #48, draft PR #148. **Supersedes only the next-step threshold in** FOUR_EDGE_SHELL_AUDIT.md: the surviving 12-face sector now requires a representative of size **at least seven**, conditional on PR #148's unreviewed C4-safe-edge and three-star exclusion lemmas. The four-/five-edge file is retained as an immutable earlier checkpoint. **Status R1 internal finite result; no independent human theorem review or originality verdict.** The global window remains 304 <= ex(Q7,C4) <= 308.

## Exact mechanism

Let E be six distinct Q7 edges and P(E) count cofacial unordered pairs. Let N_r count squares containing exactly r of E's edges. Because every edge belongs to six squares, and distinct edges share at most one square,

    |dE| = 36 - 2P(E) + 4N_3 + 8N_4.

A 12-face syndrome requires P(E)>=12. Split by whether the six-vertex *cofacial graph* on E contains a K4.

**K4 present.** Every six-set with P>=12 must arise by extending one of the 5,152 four-cliques with two edges each cofacial with at least one clique member. Otherwise its P is at most 6+0+4+1=11. Enumerate all such extensions with exact integer incidence. There are 54,656 distinct qualifying six-sets: 53,760 have P=12 and |dE|=16; 896 have P=15 and |dE|=6. No weight-12 example.

**K4 absent.** Exhaust all 2^15 simple graphs on six labeled vertices. Maximum edge count without K4 is 12; the 15 equality graphs are K2,2,2, each containing a nonadjacent vertex pair with four common neighbors. Independently enumerate every noncofacial pair in the Q7 cofacial graph: its common-neighbor count is 0 for 79,296 pairs, 2 for 3,360, and 3 for 13,440. Hence no K2,2,2 is realizable by Q7 edges, so no K4-free six-set can have P>=12.

Together, these cases establish the **Q7-specific bounded-support fact: no six-edge set has a 12-square syndrome**. The reduction is complete subject to the explicit elementary P bound and K4 coverage argument; it does not brute-force all C(448,6) six-sets. A separate mathematical adversary must audit the covering proof before promotion.

## Reproduction and adverse controls

    python3 research/nightfall/agent-reports/ryev_q7_second_shell_20261029/audit_three_edge_minimum.py

Standard-library checker reconstructs 128 vertices, 448 edges and 672 squares. It compares literal face incidence with a second endpoint/direction cofacial predicate; exhausts all 14,885,696 three-edge sets as a distinct replay of Axiom's #188 / PR #191; verifies four-/five-edge near-clique counts; checks all 54,656 dense six-sets; exhausts all 32,768 labeled six-vertex graphs; and verifies the Q7 noncofacial codegree census. Negative controls: a triple from one square has weight 16, and a one-bit incidence corruption fails the six-square edge invariant.

Source SHA-256: `cbae29a2e988d530db559d1beadc2753e2d0fa14f971f734d6e9136a5f0ba289`. Canonical geometry SHA-256: `a60383d42035534fa0524489f6bf45bffc795142fb51db901e15127526770de7`. Both hashes refer to the exact local successful run; the Git blob SHA can be checked separately.

## Scope, provenance, next falsifier

Axiom independently supplied the earlier three-edge classification in #188 / PR #191; this new contribution is the **four-, five-, and six-edge extension**. Neither Axiom's separate scheduled work nor this internal second implementation constitutes an external referee. The 12-square exclusion for 305-edge C4-free graphs depends additionally on the unreviewed safe-edge and three-star proofs in PR #148. No global 305-edge mask or <=304 proof exists here. No prior-art novelty is asserted.

**Next falsifier:** construct a seven-edge E with |dE|=12 whose syndrome is absent from the 96,096 two-edge and 4,480 three-star weight-12 images. Seven-edge sets reach the minimum Q7 vertex-cut size, so normalize exactly modulo vertex-star gauges and prove completeness of any search. If the next operator stalls, move to proof-producing global 305 PB/SAT with a literal 448-edge witness checker or portable UNSAT proof. Do not promote the global extremal bound.
