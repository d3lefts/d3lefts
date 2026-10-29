# RYEV — near-optimal odd-square rigidity and the two-edge syndrome exclusion

**Date:** 2026-10-29. **Owner:** Devin J. Wright / NIGHTFALL. **Derivation:** Ryev (GPT-6). **Parent:** #48, #140, draft PR #148. **Status:** R1 / candidate analytic theorem with internally exact finite controls; Lemnis and Axiom proof review, Vesper priority review, outside human referee all **OPEN**. This is **not** a solution of ex(Q7,C4).

## Definitions

Let Q_n be the binary n-cube; an **odd-square** edge set H contains exactly 1 or 3 edges from every coordinate square. Let M_n be the largest size of such a set. A missing edge e is **C4-safe** for H if H+e contains no complete coordinate square. For a graph G, its **even-square syndrome** T(G) is the set of 0- or 2-edge squares; dE is the mod-2 set of squares with odd E-edge occupancy.

## Proposed theorem: rigidity of near-optimal odd-square states

**For every odd n≥5, if H is odd-square and |H|=M_n−1, then H has at most one C4-safe missing edge.**

### Proof

Write n=2m+1. Vertex-star switching (toggling all n incident edges at v) preserves square parity and changes |H| by n−2deg_H(v). Since |H|=M_n−1, every vertex has deg_H(v)≥m (otherwise a switch improves past M_n).

Suppose e=uv is missing and C4-safe. Every square through e must have exactly one selected H-edge (three would become four). The n−1 other edges incident to u or v lie in distinct e-squares, each containing at most one of those edges. Therefore deg_H(u)+deg_H(v)≤n−1=2m. The degree lower bounds force deg_H(u)=deg_H(v)=m. Switching at u **or** at v produces a maximum odd-square graph K_u or K_v, each with M_n edges.

Every maximum odd-square graph K is C4-saturated: switching forces deg_K(w)≥m+1 at every vertex, whereas a safe missing edge ab would have deg_K(a)+deg_K(b)≤2m. Hence no safe missing edge remains in K.

Assume f≠e is another C4-safe missing edge for H. If f is absent from every square containing u, toggling the star of u neither adds f nor changes any square through f; f remains safe in K_u, contradicting its saturation. Hence f must lie on some square containing u. The same argument switching v shows f must lie on some square containing v.

**Geometric two-endpoint lemma.** If e=uv is a cube edge, and f lies in (possibly different) coordinate squares containing u and v respectively, then e and f lie in a common coordinate square. To prove it, label e in direction i and f in direction j. If j=i, the projection of f off coordinate j differs from that of e in at most one coordinate, so f=e or is opposite e in a square. If j≠i, projecting off j gives adjacent vertices u',v' in Q_(n−1). The projected location of f is at Hamming distance at most one from each. The intersection of their radius-one balls is {u',v'}, so f is incident to u or v. Both cases are cofacial.

Thus e,f are cofacial. The cofacial case is forbidden by the exact argument in THEOREM.md, restated here:
- For adjacent e,f, their common square has e,f absent. Since both are safe, the edges opposite e and opposite f must both be absent, contradicting odd-square parity.
- For opposite e,f, the common square has exactly one selected edge g. Switch the endpoint of e incident to g; its degree is m, so this produces an M_n-edge odd-square graph. The switch toggles e and g on the common square but leaves f absent, and no other f-square meets the switched vertex. The still-safe f contradicts maximum saturation.

Therefore no two distinct C4-safe missing edges exist in H. QED, **subject to independent referee checking of the geometric projection and switching dependencies**.

## Consequence: the entire one-/two-edge syndrome sectors are forbidden above M_n

For **odd n≥5**, suppose G is C4-free and |G|>M_n. Then **T(G)≠dE for every E with 0, 1 or 2 edges**.

If |E|=0 then G itself is odd-square, impossible. For |E|=1, H=G△E is odd-square; if E is absent from G, |H|>|G|>M_n; otherwise |H|=|G|−1, so |G|=M_n+1 and H is a saturated maximum odd-square graph to which adding its missing safe edge gives G, impossible.

For |E|=2, write k=|G∩E|. Since H=G△E is odd-square, |H|=|G|+2−2k≤M_n, which forces k=2 and |G|∈{M_n+1,M_n+2}. Both edges of E are therefore absent and individually C4-safe in H⊂G. If |G|=M_n+2 then |H|=M_n and saturation rules out either edge. If |G|=M_n+1 then |H|=M_n−1 and the rigidity theorem rules out two safe missing edges. Contradiction.

### Q7 application and exact independent combinatorial count

Using the externally published odd-square optimum M_7=304 (Minamoto's corrected 2026 manuscript, derived from earlier fully frustrated-hypercube literature), any hypothetical C4-free 305-edge Q7 graph has T(G) different from **all 448 single-edge syndromes and all 100,128 two-edge syndromes**. Of the two-edge syndromes, 4,032 have weight 10 (cofacial edges), and **96,096 have weight 12** (noncofacial edges). Different pairs give distinct syndromes: a shared syndrome would imply the nonempty symmetric difference of at most four edges is a cube vertex cut, impossible since a nontrivial Q7 cut has ≥7 edges.

Run `python3 research/nightfall/agent-reports/ryev_q7_second_shell_20261029/audit_q7_two_edge_sector.py`. This check builds 128 vertices, 448 edges, 672 squares by integer vertex geometry, and enumerates every unordered pair without importing the original theorem verifier. Source SHA-256: `122c2bcb472711edc1d6b175ec8bece49200cd775dd21ff92f39f006a26a3d5d`; pair-weight-CSV SHA-256: `2e87cdb4964dae30381472130137b88c26f170dad2219f897e32d545cc4a2faf`.

**Interpretation:** The ≥12 even-square necessary condition of PR #148 remains unchanged. The new implication eliminates every **two-edge-representable** 12-square pattern, leaving only more complicated 12-square syndromes as candidates. It neither proves those survivors impossible nor decreases the overall upper bound ex(Q7,C4)≤308. Numerical counts are exact internal finite arithmetic; universal rigor requires adversarial proof review. Priority and significance relative to cubical/cochain coding theory remain unestablished.

## Next falsifier / audit plan

1. Independently exhaust all Q3 odd-square graphs and every missing-edge safety pattern as a lower-dimension boundary check; n=3 is outside the declared n≥5 theorem.
2. Lemnis: seek a counterexample to the geometric two-endpoint lemma or an unsafe assumption in the opposite-edge switch.
3. Axiom: derive the projection lemma using cubical incidence without reading the original proof.
4. Vesper: compare this stability lemma against cubical codes, fully frustrated hypercubes and Minamoto's prior work, then review release status.
5. If the lemma survives, analyze the first 12-square closed cochains **outside** all two-edge images and test whether 305-edge C4-free constraints can rule out that next family. Do not represent a 100,128-mask exclusion as a global 305 impossibility certificate.
