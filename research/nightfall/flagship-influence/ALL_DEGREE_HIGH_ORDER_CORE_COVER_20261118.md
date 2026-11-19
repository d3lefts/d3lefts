# NIGHTFALL: all-degree high-order core cover, genuine original-source C105.416

2026-11-18. Scope: source-exact Lean candidate, pending exact-head integrated Lake CI; not independently reviewed and NOT an unrestricted UE2 result.

## Theorem

For any finite independent original product law p (nonnegative normalized coordinate weights, zero atoms allowed), and any bounded real observable f of ANY Efron–Stein degree, suppose H meets every nonzero canonical Hoeffding interaction S of order at least three. Let k=|H|, B>=0 bound |f|, V=Var_p(f) and M>=max_i I_i(f) (native source influence). Then

  V <= D B sqrt(M) + k M,
  D = 2(1+sqrt(2))*sqrt(3) + 11901/6250,
  D² approx 105.416.

No limit on degree or the number/overlap of interactions. High-degree interactions can be arbitrarily dense, provided all of them touch H.

For M equal to the actual maximum influence, M<=B², so the author-side corollary is V²<=(D+k)² B² M. In degree at most d, if |H|<=d and d>=1, the coefficient is at most (D+1)² d². The polynomial degree-two exponent is certified for this restricted all-degree structural family ONLY. The displayed squared corollary and centered-radius specialization are not separate named Lean declarations in this file.

## Source-owning proof

Let U = univ minus H and g = E_p[f | X_U] using the genuine original-source coordinate conditional expectation. Existing kernel-checked source ANOVA projector identities show that (g)_S equals f_S exactly for S subseteq U and vanishes otherwise. The new Lean lemma high_order_core_projection_degree_two derives that g has Efron–Stein degree <=2, with NO degree restriction on f.

Existing native source lemmas establish pointwise |g|<=B, I_i(g)<=I_i(f), and Var(g)=outsideSourceEnergy(p,f,H). The finite C105.416 original-source Q2 theorem gives Var(g)² <= D² B² M, while the existing source original-cover energy identity gives V-Var(g)<=sum_(i in H)I_i(f)<=kM. The previously certified scalar terminal from CubicTopCoverEnergy closes the stated result.

This is a fully source-derived finite product statement, with no supplied quadratic hypothesis and no phantom replacement probability law.

Lean: research/nightfall/formalization/observability/HighOrderCoreCover105416.lean

Named theorems:
- Nightfall.Observability.HighOrderCoreCover105416.high_order_core_projection_degree_two
- Nightfall.Observability.HighOrderCoreCover105416.original_source_all_degree_high_order_core_105416

Certification plan: exact flat module registered in scripts/generate_nightfall_lake.py and lakefile.toml; imported and audited in Nightfall/Main.lean. Existing CI nightfall-integrated-lake.yml runs generator --check, lake build Nightfall, strict axiom auditor, and lake check. Keep draft until exact-head run success.

## Boundaries and prior art

When H is empty, the covered support must already be degree<=2. When H contains one coordinate, f may have arbitrary higher chaos degrees but every high-order term must use that coordinate.

An arbitrary degree-d hypergraph need not have a hitting set of size polynomial in d. A complete d-uniform support hypergraph on n variables has minimum vertex cover n-d+1. Therefore this family does NOT prove universal N-UE2(6) or N-UE2(2).

The result reuses prior NIGHTFALL finite-source Lean certificates from merged PR #787 (energy decomposition/cover and source projection) and the merged Q2 program #776. Classical ANOVA and Efron–Stein underlie the mechanism, so novelty is NOT claimed. Independent review and dated theorem-level priority comparison remain open.

Discovery graph: higher-order ANOVA support -> bounded core hitting set -> source conditional projection -> exact residual-sector annihilation -> certified quadratic base -> native influence charge -> all-degree scoped degree-two exponent -> still-open unbounded-core and mixed control-switching problem.

Next decisive experiment: replace integer hitting-set cost by a fractionally weighted, amplitude-aware source operator capable of controlling dense high-degree overlap without the support size. The ordinary fractional cover count alone may be unbounded even when functions have bounded amplitude.
