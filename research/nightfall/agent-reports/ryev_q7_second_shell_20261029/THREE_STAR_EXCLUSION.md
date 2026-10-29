# RYEV — exclusion of incident three-edge square syndromes above the odd-square optimum

**NIGHTFALL mathematical research — 2026-10-29**  
**Owner:** Devin J. Wright. **Derivation:** Ryev (GPT-6). **Context:** #48, #140; draft PR #148.  
**Claim state:** R1 / **analytic candidate with exact internal geometric enumeration**. Independent mathematical reviewer, historical priority audit, and human publication authorization OPEN. No new numerical value of the global C4-free hypercube extremal function.

## Definitions and domain

Let n=2m+1 be odd with n≥5. In the binary n-cube Q_n, every coordinate square is a 4-cycle. An *odd-square* edge set H has either 1 or 3 occupied edges on every square. Let M_n=max|H| over odd-square sets. A missing edge e is *safe* if H+e contains no 4-cycle. Define T(G) for a C4-free graph G to be its set of even-occupancy squares (0 or 2 edges). For any edge set E, dE is the mod-two collection of coordinate squares containing an odd number of E edges.

**Theorem candidate (incident triple exclusion).** If G⊂Q_n is C4-free and |G|=M_n+1, then T(G)≠dE for every set E of three distinct edges incident to one vertex.

This excludes a new geometrically explicit three-edge sector, independently of the two-edge sector treated in SAFE_EDGE_RIGIDITY.md.

## Two necessary lemmas

**Lemma 1 — a maximum odd-square graph has at least two separate blockers for every absent edge.**  
For any odd-square H with |H|=M_n, toggling the entire vertex edge-star preserves square parity. If deg_H(x)≤m, the toggle increases |H| by n−2deg_H(x)≥1, contradicting maximality. Thus every degree is ≥m+1. For an absent edge e=uv, each of its 2m coordinate squares contributes **at most one** endpoint-adjacent selected edge if the square has 1 selected edge (possibly zero if only the opposite edge is occupied), and **exactly two** such edges if it has 3 selected edges. The 2m squares partition all selected edges incident to u or v. Since deg_H(u)+deg_H(v)≥2m+2, at least **two distinct e-squares contain three occupied edges**. For distinct cube edges h≠e, at most one coordinate square contains both; hence deleting one arbitrary H-edge h cannot destroy all blockers. Therefore adding e to H−{h} still forms a complete square.

**Lemma 2 — three co-incident safe edges are impossible two below optimum.**  
Suppose H is odd-square with |H|=M_n−2, and e_i=vv_i, i=1,2,3, are three distinct absent edges individually safe. Vertex-star switching forces deg_H(x)≥m at every vertex, since a degree at most m−1 would increase the edge count by at least 3 and exceed M_n. For each safe e_i, all 2m e_i-squares have exactly one occupied edge. Those squares partition all selected H-edges incident to v and v_i. Therefore deg_H(v)+deg_H(v_i)≤2m; together with the degree lower bound this forces **both degrees equal m**, and every e_i-square has exactly one selected edge **among its two endpoint-adjacent edges**.

Let J be the m selected directions at v. Since e_1,e_2,e_3 are missing there, the other 2m−2 directions consist of J (m directions) and B (m−2 missing directions). Fix i. In each e_i-square for a direction j≠i, exactly one of v→v^j and v_i→v_i^j is selected. Thus at v_i, the edges in J-directions are absent, those in B-directions are selected, and the remaining two directions e_j with j∈{1,2,3}∖{i} must *both* be selected to reach deg_H(v_i)=m. Choose distinct i,j. The square spanned by e_i and e_j then has e_i and e_j absent, but both opposing sides present (one at v_i and one at v_j). It has exactly two occupied edges, contradicting that H is odd-square. QED.

## Proof of the theorem candidate

Assume T(G)=dE for a triple E incident to one vertex. Then H=G△E has odd occupancy on all squares, hence |H|≤M_n. Write k=|G∩E|, so |H|=|G|+3−2k=M_n+4−2k. Necessarily k≥2.

- **k=2.** H is odd-square with |H|=M_n. Precisely one edge h∈E belongs to H and the other two edges e,f are absent from H. The purported G=(H−{h})+{e,f} is C4-free. But Lemma 1 says after deleting h, adding either missing e or f still creates a completed square. Contradiction.
- **k=3.** H is odd-square with |H|=M_n−2. All three edges E are absent from H, and H⊂G. Every edge of E is individually safe because H+e⊂G is C4-free, contradicting Lemma 2.

Thus every case is impossible.

## Q7 exact geometry and scope

For n=7, any three distinct edges incident at a vertex have syndrome weight **3(n−3)=12**: each of their individual edge stars occupies n−1 squares, each of the three pairs shares exactly one square, and there are no triple-shared squares. There are 128·binom(7,3)=**4,480** such choices. Their syndromes are distinct because equal syndromes would make the symmetric difference of two three-edge sets into a nontrivial vertex cut supported on at most six edges; every nontrivial Q7 vertex cut has at least seven. They are distinct from the **100,128** two-edge syndromes by the same cut-size argument (3+2≤5).

Under the imported published result M_7=304 (see THEOREM.md's source ledger), every hypothetical 305-edge C4-free Q7 graph therefore avoids:
- 4,032 two-edge cofacial weight-10 syndromes,
- 96,096 two-edge noncofacial weight-12 syndromes,
- **4,480 additional three-coincident-edge weight-12 syndromes**.

These are explicit excluded geometries in the 12-square sector. **Other 12-square syndromes remain unclassified. The global inequality 304≤ex(Q7,C4)≤308 is unchanged, and the minimum of 12 even squares is not strengthened.**

## Independent executable checker and falsification contract

Run `python3 research/nightfall/agent-reports/ryev_q7_second_shell_20261029/audit_q7_two_edge_sector.py`. The checker reconstructs all 128 vertices, 448 edges, 672 squares, edge-star syndromes, and 100,128 two-edge syndromes, then **separately enumerates 4,480 incident three-edge patterns**, checking weight 12, mutual uniqueness, and disjointness from the two-edge set. It uses standard-library vertex geometry, rather than importing another script. Counts are exact finite evidence, not an independent proof of the all-n implications.

**Adversarial review requested:** Lemnis should attack the claimed degree/square incidence partition and the one-deletion/two-blocker argument. Axiom should reconstruct a Q5 or Q7 calculation from independent cochain matrices, including a negative control invalidating the conclusion when C4-free or odd-square assumptions are removed. Vesper should check published fully-frustrated hypercube and cubical-code literature for antecedents before an originality claim. Keep this R1 candidate in a draft; demote immediately if counterexamples or an invalid step are found.

**Next information-rich operator:** classify the remaining 12-square closed cochains outside both the two-edge and three-star images, then formulate a global 305-edge exact SAT/PB search with a portable proof log. A local neighborhood or face-shell exclusion does not certify f(7)≤304.
