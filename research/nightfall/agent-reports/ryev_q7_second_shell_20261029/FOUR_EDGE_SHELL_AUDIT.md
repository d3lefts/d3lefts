# Ryev / Q7 four-/five-edge equality-sector audit — 2026-10-29

**Scope:** #140, #48; companion to draft PR #148 and Axiom's independent three-edge result in #188 / draft PR #191. **Status:** R1 internal analytic candidate plus exact finite check. No external mathematical referee, novelty decision, or owner publication approval. The global window remains **304 <= ex(Q7,C4) <= 308**.

## New operator: incidence-intersection clique reduction

For four distinct cube edges E={e1,e2,e3,e4} in Q_n, let N_r be the number of coordinate squares containing exactly r of the four edges, and let P be the number of unordered pairs of E-edges sharing a coordinate square. Any pair of distinct cube edges shares at most one square, so P<=6. Counting square-edge incidences and parity gives

    |dE| = 4(n-1) - 2P + 4*N_3 + 8*N_4.

Thus |dE|>=4(n-4). Equality requires P=6 and N_3=N_4=0. The graph of cube edges with cofacial adjacency has only two types of four-cliques: (i) four distinct coordinate edges at a common vertex; (ii) the four boundary edges of one square. Proof: a parallel cofacial pair forms opposite sides of a unique square; every other edge cofacial with both lies among the other two sides of that square. Without a parallel pair, all edges have distinct directions, so cofacial pairs share endpoints; in a triangle-free cube, pairwise-intersecting edges all share a vertex. A full square has N_4=1 and fails equality. Therefore, for n>=4, equality holds exactly for a four-edge vertex star. In Q7 the minimum is **12**.

For Q7, a four-star at vertex v is gauge-equivalent to its complementary three-star: toggling the entire seven-edge vertex star changes no square parity. Axiom #188 / PR #191 independently classified every three-edge weight-12 representation; this new four-edge argument extends the **bounded-preimage classification** through four edges without assuming any extremal-graph theorem.

## New extension: five-edge near-clique exclusion

For five edges, the same incidence identity reads |dE|=5(n-1)-2P+4*N_3+8*N_4, with P<=10. In Q7, |dE|=12 forces P=9 and N_3=N_4=0 (P=10 gives 10 modulo 4; P<=8 gives >=14). A five-vertex graph with nine cofacial pairs contains a four-clique. By the four-clique classification, it contains a four-star or the boundary of a square. Any fifth cube edge not incident with the star center is cofacial with at most two of the four star edges; any fifth edge outside the square is cofacial with at most two of its four sides. Hence no cofacial five-set has exactly nine pairs. The only five-sets with at least nine cofacial pairs are five-stars, with ten pairs and syndrome weight **10**, not 12. Thus **no five-edge Q7 set has a 12-square syndrome**. The proof avoids enumerating C(448,5) subsets.

**Conditional Q7 search consequence:** Assuming Ryev's still-unreviewed safe-edge rigidity and incident-three-star exclusion in PR #148, a hypothetical 305-edge C4-free graph with exactly 12 even squares has a square syndrome whose **minimum edge-preimage cardinality is at least six**. The 12-square classes with a preimage of size <=5 consist exactly of the 96,096 noncofacial two-edge classes and 4,480 three-star classes; the 4,480 four-stars add no new classes, and five-edge representatives contribute none. This is a necessary sector exclusion, **not** an impossibility proof for 305 edges or an upper-bound improvement. Even without those conditional exclusion lemmas, the pure cubical classification and gauge identity remain separate checkable statements.

## Independent adverse check

Run from repo root:

    python3 research/nightfall/agent-reports/ryev_q7_second_shell_20261029/audit_three_edge_minimum.py

Python 3 standard library; the file imports no prior NIGHTFALL verifier. Literal coordinate construction rebuilds 128 vertices, 448 edges, and 672 squares; a second geometric cofacial predicate checks all 100,128 pairs. The checker exhausts all 14,885,696 triples as an independent replay of Axiom #188, then enumerates **all four-cliques** in the cofacial-edge graph (without attempting all 1.6 billion four-edge sets): 5,152 cliques = 4,480 vertex-stars + 672 face boundaries. Their syndrome weights are respectively 12 and 20. It checks every four-star/complementary-three-star gauge equality, disjointness from the two-edge sector, and a three-edges-of-one-face negative control. The five-edge near-clique extension enumerates only K4 extensions with at least three additional cofacial pairs; these exhaust all P>=9 candidates by the elementary K5-minus-edge graph argument. One-bit incidence tampering is rejected by the six-square-per-edge invariant.

**Local exact output:** triple weight distribution {12:4480, 14:47040, 16:1685376, 18:13148800}; 100,128 distinct two-edge syndromes (4,032 weight 10 and 96,096 weight 12); 5,152 four-cliques (4,480 weight 12, 672 weight 20); 2,688 five-edge near-cliques (all five-stars, all weight 10). Canonical sorted edge/face geometry SHA-256 `a60383d42035534fa0524489f6bf45bffc795142fb51db901e15127526770de7`.

**Limit:** four-edge noncliques are excluded from weight 12 by the proved P<=5 incidence bound, and five-edge sparse cofacial sets by P<=8, not by brute-force enumeration of all four- or five-subsets. The script is internal executable corroboration; it is not independent human proof review. The all-n argument and the cofacial-clique dichotomy still require Lemnis attack; Axiom's earlier triple work is credited and is not retroactively reclassified as an independent review of this four-edge extension.

## Next falsifier / stop

Seek a six-edge set E with |dE|=12 whose syndrome is distinct from every two-edge and three-star syndrome. A literal E would establish a surviving **combinatorial** sector, not a 305-edge graph. For six edges, the pair-overlap threshold is P>=12, and K4-free cofacial graphs may attain P=12, so the K4-only enumeration cannot be reused as a completeness proof. Use a new exact dense-subgraph enumerator with a separately checked covering argument, then switch to global proof-producing PB/SAT with exact XOR and portable proof logging. For an actual Q7 extremal improvement, require a 448-edge literal mask checked against all 672 squares, or a globally checkable <=304 UNSAT proof. No site release or claim-status change.
