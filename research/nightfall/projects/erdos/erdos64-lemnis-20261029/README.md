# NIGHTFALL / Lemnis — Erdős #64: exact 3-port replacement obstruction

**Checkpoint:** 2026-10-29. **Claim label:** reproducible exact finite exclusion; independently implemented C++ and Python code paths, but no independent external referee. **Novelty label:** not established. **Erdős–Gyárfás conjecture:** OPEN.

## Contract and external baseline

Every finite simple graph of minimum degree at least 3 is conjectured to contain a simple cycle of length 4, 8, 16, 32, ... . A finite counterexample must avoid *every* power-of-two length up to its order. The strongest 2026 result located is Ducoffe–Dumitru (arXiv:2609.28594): all graphs up to 40 vertices, cubic graphs up to 48, and bipartite graphs up to 66. Tranquilli (arXiv:2608.02675) independently covers cubic bipartite graphs up to 58. For the cubic function f(4), the literature-reported range is 54 ≤ f(4) ≤ 78 (Markström, Exoo). These are external results; this work does not improve these bounds.

## Exact transfer lemma

Let G be cubic, S a subset of vertices, and H a connected three-port replacement gadget with three marked vertices of internal degree 2, all other vertices degree 3. Replace each v in S by a disjoint copy of H and reconnect its three original incident edges bijectively to H's ports. Assume every pair of ports has simple internal paths of **exactly** all integer lengths a,a+1,...,b. Then the expanded graph's cycle-length set consists of:

1. Cycles internal to H, if S is nonempty;
2. For each simple cycle C of G of length L, all integers in the interval **[L+a|C∩S|, L+b|C∩S|]**.

**Proof:** A simple cycle crosses each gadget's three-edge cut either zero or two times (parity). In the latter case it uses a simple port-to-port path, and contracting it gives a base cycle. A simple cycle cannot use one gadget twice. Conversely, any base cycle can be lifted using independent port paths in disjoint gadgets. The sums of contiguous integer path-length sets are contiguous integer intervals. If no cut is crossed, the cycle is internal to a gadget or an unmodified base cycle. QED.

Two gadgets were checked:

* Triangle K3: port-pair path lengths {1,2}; only internal cycle has length 3.
* Seven-vertex gadget with graph6 string **FhcYG**: every port pair has path lengths {2,3,4,5,6}; it contains no C4, and cannot contain C8 or C16 internally. The Python verifier independently checks these properties.

**Five-vertex gadget obstruction:** Any simple 3-port gadget on five vertices has degree sequence (3,3,2,2,2) and contains a C4. If the two degree-3 vertices are nonadjacent, the graph is K2,3. If adjacent, degree counting forces exactly one terminal-terminal edge and one terminal adjacent to both internal vertices; the two remaining terminals attach to different internal vertices, producing a C4. This is an elementary structural lemma, not claimed novel.

## Finite exclusion (27 exact graph6 inputs)

The file markstrom_24_and_26.g6 lists four 24-vertex and twenty-three 26-vertex cubic graphs with no C4 or C8, from Markström's census as independently reproduced in oaustegard/Muninn's July 2026 working note. We verify the 27 **specified strings**, not the completeness of the external census.

For each of these 27 graphs, and separately for each gadget above, all 2^n possible vertex subsets S were checked by exact integer bitset constraints derived from the transfer lemma.

| Gadget | Base/subset configurations checked | Avoid C4 and C8 | Avoid C4, C8 and C16 |
|---|---:|---:|---:|
| K3 | 1,610,612,736 | 856,067 | **0** |
| FhcYG | 1,610,612,736 | 7,580,424 | **0** |

**Conclusion:** None of these 3,221,225,472 *configurations* yields a graph avoiding all three lengths. They are not 3.2 billion nonisomorphic graphs. This is a finite negative result, not a counterexample, a global theorem about Erdős #64, or an improved f(4) bound.

## Reproduce

From this directory:

~~~bash
sha256sum markstrom_24_and_26.g6
# expected 476da0276616045a2750b09a47bf39ce602fe3c5c79d7359e73281d3d2c30f00
g++ -O3 -std=c++20 -Wall -Wextra -pedantic expand_search.cpp -o expand_search
./expand_search
./expand_search --gadget7
python -m pip install networkx numpy
python independent_audit.py
python independent_audit.py --gadget7
python spotcheck_expansion.py
~~~

The C++ verifier decodes graph6 itself, enumerates simple base cycles with DFS, deduplicates by vertex masks, then scans every subset using popcounts. The independent Python code uses NetworkX graph6 decoding, root-deleted simple-path cycle enumeration, and NumPy vectorized subset filtering. The full 27-entry C4/C8 survivor counts agree exactly between them in both gadget modes. A third path constructs twenty expanded graphs literally and detects 4-, 8- and 16-cycles, matching the predicted cycle spectrum. No floating point, SAT solver trust, or tolerances enter the claims.

**Audit obligations:** Verify graph6 upper-triangle bit order, n and degree, graph6 roundtrip, C4/C8 absence in bases, non-induced simple cycles (chords allowed), gadget port path sets, internal cycles, both directions of the transfer lemma, S empty and full, and 32-bit masks for n≤26. Two code paths are not two independent authors; external referee replay remains open.

## Mechanism and handoff

**Operator status:** Uniform triangle replacement and uniform-path seven-vertex replacement are closed for all 27 tested bases. The five-vertex 3-port gadget is structurally impossible without a C4. This is a meaningful pruning of the construction space, not a positive record.

**Next experiment:** The other connected C4-free seven-vertex 3-port gadget in the graph atlas, graph6 **FgqPg**, has asymmetric port-pair signatures: two pairs allow {2,3,4,5,6}, one pair only {3,4,5,6}. Introduce port assignments as variables, and test whether this symmetry breaking eliminates the 16-cycle contact without generating C4/C8. After that, switch to edge/pair replacement or voltage-lift families. Do not repeat uniform subset tuning.

**Stop rule:** Two complete uniform gadget families failed across 27 bases; 5-vertex gadgets fail structurally. Reopen only for a new representation, new port signature, or new base graph.

## External references, checked 2026-10-29

* Erdős #64: https://www.erdosproblems.com/64
* Ducoffe–Dumitru (2026): https://arxiv.org/abs/2609.28594
* Tranquilli (2026): https://arxiv.org/abs/2608.02675
* Garcia (2026): https://arxiv.org/abs/2609.04686
* Exoo: https://arxiv.org/abs/1403.5636
* Markström, *Extremal graphs for some problems on cycles in graphs*, Congressus Numerantium 171 (2004).
* Source of the 27 graph6 strings: https://github.com/oaustegard/experiments/blob/main/erdos-gyarfas/note.html
* Generalized Petersen 8-cycle classification (already known; not a NIGHTFALL result): https://doi.org/10.1016/j.dam.2020.03.007
