# RYEV #105 — exact bipartite Q6-face recombination for the Q7 C4 problem

**Owner:** Devin J. Wright. **Lead:** Ryev. **Review requested:** Lemnis, Axiom, Vesper. **Status:** internally proved exact finite catalogue result; independent human theorem/priority review pending.

## Mathematical reduction

Write Q7 as two opposite Q6 faces with C4-free selected edge sets A and B, together with 64 possible connecting edges. Let H have vertex set F_2^6 and edge set A∩B.

A chosen connecting-edge set I⊆F_2^6 creates a crossing C4 exactly when it includes both endpoints of a common selected face edge (u,v)∈A∩B. Both face graphs already have no internal C4. Thus the entire Q7 join is C4-free **if and only if I is independent in H**.

Because H is a subgraph of the bipartite Q6 graph, König's maximum-matching theorem gives α(H)=64−ν(H). Consequently the maximum C4-free Q7 join for this **fixed** A,B is

    |A| + |B| + 64 − ν(A∩B).

This is an exact, polynomial-time global optimization of the 64 connecting-edge decisions **given two fixed face inputs**. It is an elementary established combinatorial theorem, rather than a claim of new theory.

For two 132-edge Q6 faces, a 305-edge Q7 would require ν(A∩B)≤23. For sizes 131+132 it would require ν≤22; for 131+131 it would require ν≤21.

## Executed source-frozen catalogue experiment

The upstream Minamo Minamoto 180 Q7 304-edge representative masks are inherited, unchanged, from the global-face work in PR #101. Canonical byte-string SHA-256:

    2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1

For each original selected Q7 edge, project to the appropriate Q6 face by deleting one fixed coordinate, remapping its direction index. Extract **every distinct normalized face of size 131/132**. The result contains 253 faces of size 131 and 120 of size 132 (373 total). All extracted faces are separately verified C4-free.

For each unordered pair, the Python checker computes a maximum matching by exhaustive augmenting paths, recovers a minimum vertex cover using alternating reachability, constructs a maximum independent set, and verifies that the number of connecting edges is exactly 64−ν. This is a **maximal join of each input pair**, not a heuristic or approximate objective.

### Exact completed results

| Quantity | Result |
|---|---:|
| Original attributed Q7 masks | 180 |
| Distinct normalized Q6 faces (131 / 132) | 253 / 120 |
| Pairings (131+131) | 32,131 |
| Pairings (131+132) | 30,360 |
| Pairings (132+132) | 7,260 |
| Total pairings | **69,751** |
| Minimum ν for 131+131 | **22** |
| Minimum ν for 131+132 | **23** |
| Minimum ν for 132+132 | **24** |
| Maximum attainable joined edge count | **304** |
| Pairings attaining that maximum | **649** |
| Minimum sampled improvement above published 304 | **0** |

An explicit maximal 304-edge graph is constructed from one of the maximizing pairings, and `best_join_edges.txt` is written using sorted ASCII `u v\n` records. The independent checker rebuilds 448 potential Q7 edges and 672 coordinate squares, confirms 304 selected and zero C4s, and checks the text SHA-256:

    a33b5f50089e25c152fb84d840a3892c0ed69cadc8d4a12514470596cb923da1

The new experiment closes the 305 search **only for these 373 normalized source Q6 faces in their fixed common coordinate alignment**. It does not exhaust arbitrary coordinate permutations, binary translations, other Q6 face classes, or all possible Q7 graphs. This result cannot establish the global upper bound 304 or surpass the known external lower bound 304.

## Independent adversarial tests

`test_matching.py` enumerates all **4,096** possible subgraphs of Q3, embedded in the first eight vertices of Q6. For each it finds the minimum vertex cover by a *separate full 256-subset brute-force search*, and checks equality with the general matching/cover algorithm. It also deliberately chooses two crossing edges spanning a common selected Q6 face edge; this causes a C4 and the checker rejects it. A valid matching-derived 304-edge Q7 join passes all 672 squares.

The full exact pair computation completed in **2.763 s** in GitHub Actions; additional independent oracle and full C4 checks passed.

**Workflow:** https://github.com/d3lefts/d3lefts/actions/runs/40830049048

## Reproduce

```bash
python3 research/nightfall/projects/erdos/q7-face-matching-20261029/test_matching.py
python3 research/nightfall/projects/erdos/q7-face-matching-20261029/matching.py
```

No third-party optimizer required. Python standard library only.

## Next falsifier and opportunity

The precise 305 target is a pair of C4-free Q6 faces A,B with

    ν(A∩B) ≤ |A|+|B|−241,

equivalently `|A|+|B|+64−ν ≥305`. A Q7 solution is then immediately reconstructible from a matching-derived independent set and independently checkable.

Test full automorphism transforms (64 translations × 720 coordinate permutations of each candidate face) and new Q6 extremal face families. The exploratory JS pilot already checked 30,000 seeded transformed partners against one fixed 132-edge face and found minimum ν=27, without covering the entire transform group; those trials are **unreviewed exploratory evidence** and do not appear as an exhaustive certificate.

The external extremal benchmark remains `304 ≤ ex(Q7,C4) ≤ 308`; contemporary priority search and human mathematical audit are required before publication. The finite matching identity itself is classical.
