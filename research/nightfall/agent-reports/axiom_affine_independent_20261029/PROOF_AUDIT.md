# Axiom independent audit of Vesper assignment #142 — full ambient q27 planar-gluing inequivalence

**2026-10-29. Status: internal proof-dependency and independent algebraic audit, R1 only.**
Owner: Devin J. Wright. Reviewer: Axiom. Subject is the *existing Axiom theorem candidate* in [issue #142](https://github.com/d3lefts/d3lefts/issues/142) and [draft PR #144](https://github.com/d3lefts/d3lefts/pull/144); this note contributes independent computational representation and a scoped logical audit, not an outside referee's certification. The original construction and prior finite checks remain attributed to Axiom's earlier work. Human owner publication consent and external priority review are absent.

## Statement under review

Let \(F=\mathbb F_3[T]/(T^3-T+1)\). For \(e\in\{2,4\}\), set
\[
S_e=\{(x,x^e,0):x\in F\}\cup\{(0,-y^e,y):y\in F\}\subset F^3\cong\mathbb F_3^9.
\]
The proposed theorem says **no** invertible affine transformation of the full ambient 9-space sends \(S_2\) to \(S_4\). This is strictly stronger than failure of a componentwise affine map. It does not solve integer Erdős #156, establish a better asymptotic bound, or prove first worldwide priority.

## Proof-dependency audit (exact domain, quantifiers, and falsifiers)

1. **Source arithmetic.** \(T^3=T-1\) defines a field of order 27; the proposed sets have 53 distinct points, two 27-point planar components sharing zero. Independent test uses multiplication by the **companion matrix** of T, not the original polynomial convolution.
2. **Enumerated 7-flats.** Each one-dimensional F3 subspace \(L\le F\) defines two codimension-two **linear** sections \(z\in L\) and \(x\in L\) of the ambient 9-space. Each intersects \(S_e\) in 29 points. There are \(13+13=26\) explicit distinct such sections, for **both** e=2 and e=4.
3. **Completeness dependency — imported, NOT reproduced independently here.** The source C++ program in PR #144 claims to enumerate all \(8,069,620={9\brack2}_3\) rank-two dual subspaces and all nine affine fibers. Its per-quotient **maximum** fiber cardinality is 29 for exactly 26 quotients, with no other maximum ≥19. A 53-point set cannot contain two disjoint 29-point fibers in one quotient, so each of those 26 yields exactly one affine 7-flat of size 29. **Only if** that original exhaustive RREF/affine-fiber count is correct can we assert that the 26 explicit sections are *all* large sections. This is the decisive external code-review obligation and is retained as a separate proof dependency.
4. **Intrinsic component recovery — separately checked here.** Two explicit 29-point sections have intersection size 27 iff they belong to the same coordinate family (156 within-family pairs in total); each of 169 cross-family pairs intersects in exactly 5. Thus the graph on *all 26* sections formed by declaring an edge when intersection size=27 is \(K_{13}\sqcup K_{13}\), independent of coordinate labels. The intersection of any two distinct sections within one \(K_{13}\) is exactly one of the original 27-point planar components. Any affine equivalence of full \(S_e\) must preserve the pair of component sets, with possible exchange. This implication contains no probabilistic step.
5. **Component spanning and missing differences.** Each component spans its 6D ambient coordinate plane; for \(f=x^2,x^4\), every difference \((a,b)\) with \(a\neq0\) appears exactly once among 702 ordered graph differences, and no nonzero \((0,b)\) appears. Thus the punctured vertical 3D subgroup is intrinsically the complete missing-difference set. An affine component equivalence must preserve vertical directions and therefore has extended-affine block form \((x,y)\mapsto(Ax,By+Lx)+(\xi,\eta)\) with F3-linear invertible A,B. This is a *full component-affine* restriction, not merely GL3 on each factor.
6. **Intrinsic noncommutation witness.** These two specific functions are Dembowski–Ostrom quadratic maps over F3, so their polarizations are bilinear; affine input/output terms vanish from polarization. The normalized maps \(N_x=B_f(x,\cdot)B_f(1,\cdot)^{-1}\) transform by conjugacy (after rechoosing a corresponding nonzero normalization index) under extended-affine equivalence. Therefore the property “every pair of normalized operators commutes” is invariant. A separate companion-matrix implementation reproduces all 676 ordered nonzero-pair ranks: for \(x^2\), 676 rank-zero; for \(x^4\), 244 rank-zero and 432 rank-two. This forbids a component-affine equivalence.
7. **Conditional conclusion.** When combined with the source program's *independently unreviewed* exhaustive completeness count, steps 4–6 yield the claimed full 9D inequivalence. The small independent audit verifies the recovery and algebraic links; it does not itself establish the large 8,069,620-quotient enumeration. This distinction is mandatory in site/proof-passport copy.

## Independent executable check

[Companion-matrix audit](audit_companion_matrix.py) computes finite-field arithmetic from \(T\cdot(a+bT+cT^2)= -c+(a+c)T+bT^2\). It constructs both 53-point sets without imports from PR #144, checks 26 large coordinate sections and their 325 pair intersections, confirms component spans and all 702 nonzero differences, then computes normalized polarization commutator ranks for each of 676 ordered pairs. Negative nonplanar control: \(f(x)=x^3\), whose polarization is degenerate.

Reproduce:

\`\`\`sh
python3 research/nightfall/agent-reports/axiom_affine_independent_20261029/audit_companion_matrix.py
\`\`\`

This is **independently implemented internal arithmetic**, still separate from external mathematical referee acceptance.

## Targeted novel-consequence and significance review

- Inequivalence of the **planar monomials/semifield structures** is not new in itself: the #142 archive records established Dembowski–Ostrom/semifield antecedents.
- Distinct possible additional claim: the **intrinsic large-section recovery** for these *specific 53-point glued unions* and its consequence for **full ambient 9-space** inequivalence. A same-configuration, dated 2026 literature search and independent human proof reviewer are missing. No originality promotion follows from a source-only computational extension.
- A failed earlier discriminator is preserved: both glued sets have identical *codimension-two maximum-intersection histograms*, including 26 maxima of 29. They differ only after considering **pairwise intersections of the maximizing 7-flats** and the associated intrinsic component polarization.
- The 8,069,620-quotient enumeration is source-checker completeness, not a published symbolic theorem until reviewed. Alternative independent approach requested of Ryev: implement RREF quotient enumeration via a *different* traversal/finite representation and compare a hash of the ordered large-section incidence ledger.
- Lemnis should attack the affine-span/vertical-group argument and check the compatibility of selecting different normalization basepoints with commutativity invariance. For non-bilinear planar functions this argument would need modification; keep it confined to \(x^2,x^4\).

**Decision:** R1/OF-C retained, theorem *conditionally supported by the original large-enumeration certificate*. Independent small-case arithmetic and proof-logic dependencies are now visible; external R2, literature priority, and owner publication remain open. No site status upgrade.
