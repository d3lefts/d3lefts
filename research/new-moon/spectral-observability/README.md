# NIGHTFALL — Spectral observability synthesis v4

## 11 November 2026 — v8 homogeneous-cubic bridge (new research checkpoint)

The [v8 theorem and proof note](homogeneous-cubic-v8/THEOREM.md) derives the uniform cubic-level bound \(\|f^{[3]}\|_\infty\le32\|f\|_\infty\), reducing unrestricted degree-three squared-variance influence, up to constants, to bounded homogeneous cubics. Conditional on the unrefereed v5 Q2/Lk arguments, it establishes top-cubic-linearity, layerwise-linearity, and *given* soft-cover spectral prediction statements.

The independent [proof attack](homogeneous-cubic-v8/PROOF_ATTACK.md) constructs exact weighted complete 3-hypergraphs showing that vertex influence-energy budgets and disjoint matching square-root weights **alone** cannot guarantee a small low-residual cubic cover. This is **not** a bounded-cubic function counterexample. [Exact ANOVA/cover checker](homogeneous-cubic-v8/checks/exact_bridge.py), [no-go checker](homogeneous-cubic-v8/checks/weighted_hypergraph_no_go.py) and [review obligations](homogeneous-cubic-v8/REVIEW_GATES.md) accompany the result. All results remain internal; no independent referee, global novelty clearance or unrestricted cubic (2,4) theorem.


**Research status:** working manuscript; internally reviewed, not independently refereed or novelty-certified. **Date:** 2026-11-10 (US Eastern); manuscript dated 2026-11-11 UTC. **Lead:** Devin J. Wright, NIGHTFALL Constellation.

## Principal proposed results

Let independent inputs be queried one whole coordinate at a time, let \(F\) take values in a Hilbert ball of radius \(B\), let \(r\) be covariance rank (or spectral truncation rank), and let \(\eta\) be mean-square prediction error.

1. **Quadratic scalar influence, arbitrary product laws:** for Hoeffding degree at most two, \(|f|\le B\), \(V=\mathrm{Var}(f)\), and \(M=\sup_i I_i(f)\), the manuscript derives \(V\le D B\sqrt M\), \(D=16(1+\sqrt3)\). This is independent of coordinate count, alphabet size and minimum atom mass.
2. **Quadratic adaptive observability:** for covariance eigenvalue tail \(\tau_r\), a deterministic adaptive policy is claimed to attain risk at most \(\tau_r+\eta\) with at most \(\lceil 4D^2B^2/(a_r^2\eta)\rceil\) coordinate queries, where \(a_r=\Gamma(r/2)/(\sqrt\pi\Gamma((r+1)/2))\). For unit-ball rank-\(r\) outputs and \(0<\eta\le1/4\), this yields the matching minimax order \(\Theta(r/\eta)\).
3. **Categorical nonadaptive law:** for fixed degree \(d\), at most \(m\) symbols per coordinate and unit-ball rank-\(r\) outputs, the claimed minimax order is \(\Theta_d(rm^{d-1}/\eta)\). The proof uses a signed-mass proxy, hypercontractivity, Chebyshev extrapolation and an address-family lower construction.
4. **Degree-three frontier:** disjoint top-degree hyperedge matching and a pointwise oscillation budget generalize; repeated coordinate pairs obstruct the naive quadratic fourth-moment argument. The v4 manuscript reports a strengthened logarithmic-loss result for selectors and an exponent-dependent selector-lifting operator. The unrestricted-alphabet cubic variance-squared bound remains open.
5. **General-degree transfer:** a conditional scalar-to-Hilbert result reduces rank dependence from \(r^{5/2}\) to roughly \(r^{3/2}\) times a logarithm; **conditional** is part of the claim, not an unconditional proof of the cubic frontier.

## Mechanism graph

Product independence → Hoeffding interaction decomposition → matching / signed categorical representation → influence certificate → posterior-potential descent → adaptive or fixed-set observation guarantee → matching lower-bound constructions.

## Scope and limitations

- Query cost counts coordinate observations, **not** the computation required to find an optimal policy.
- The sharp quadratic adaptive theorem does **not** establish a uniform nonadaptive law for unrestricted alphabets; the address construction rules that out.
- Covariance rank can be replaced by spectral truncation with additive tail \(\tau_r\).
- General cubic arbitrary-alphabet closure, independent referee review, and a dated originality comparison remain outstanding.
- Source of truth: *NIGHTFALL_Spectral_Observability_Synthesis_v4* and *NIGHTFALL_Degree3_Proof_Supplement_v1* supplied by the research program. This repository checkpoint summarizes those manuscripts; it does not assert a fresh independent proof audit or Lean certification.

## Next decisive research test

Prove or refute the unrestricted-alphabet degree-three fourth-moment certificate under repeated pair overlaps; test the selector obstruction before attempting a general hypergraph transfer. Preserve exact counterexamples and the distinction between theorem, conditional theorem, and conjecture.
