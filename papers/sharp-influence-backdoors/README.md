# Sharp Influence and Adaptive Observation — independent research manuscript

**Wright / NIGHTFALL · 12 November 2026 · manuscript v2.0.** This is the canonical research-source checkpoint for the 22-page standalone paper, not a journal submission or independently refereed theorem.

- [Complete LaTeX source](Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex) (SHA-256 `dba4d747f454959417dde5ae12ea552566220e329ff67ef37318350b980f8f88`).
- [Proof passport with theorem-by-theorem evidence gates](PROOF_PASSPORT.md).
- [Original deliverable README](SOURCE_README_v2.md), [original custody checksum manifest](SOURCE_SHA256SUMS_v2.txt); the PDF from that original snapshot has SHA-256 `4372758b9c4cc4cf02366035aa5bd406d2949cf5db42df2d886de1f2b379b7c6` and **is not imported to this folder**. Build the committed LaTeX locally to generate a fresh PDF (not byte-identical to the original unless the environment reproduces it).
- [Independent 17-page degree-two v1 source](archive/Quadratic_Influence_and_Rank_Optimal_Observation_v1.tex) and [v1 proof passport](archive/PROOF_PASSPORT_v1.md), retained as a historical checkpoint.
- [v9.2 degree-two-first predecessor](../finite-product-influence/NIGHTFALL_Beyond_Boolean_Cube_v9_2.tex), with the already checked-in [v9.2 PDF](../finite-product-influence/NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf).

## Analytic claims and boundaries

Let independent input coordinates have arbitrary product distributions, and write \(V=\operatorname{Var}(f)\), \(M=\sup_i I_i(f)\), \(|f|\le B\), and \(C_2=(10+2\sqrt2)^2(1+\sqrt3)^2\approx1228.356\).

1. **Quadratic degree-two:** \(V^2\le C_2 B^2M\) by a written matching/section-budget/fourth-moment proof. The exponent two is sharp in a disjoint-block family.
2. **Rank-\(r\) Hilbert outputs:** \(V(F)^2\le3C_2rB^2M(F)\), with a complete source-side analytic proof but no end-to-end Lean certificate.
3. **Quadratic adaptive whole-symbol reading:** risk (≤\tau_r(F)+\eta) using at most (\min\{n,\lceil12C_2rB^2/\eta\rceil\}) reads; matching order lower families exist. This is an *information/query* bound, not an efficient running-time statement.
4. **Weak averaging transversal:** if (H), (|H|=t), meets every active Hoeffding support of size (≥3), then (V\le\sqrt{C_2} B\sqrt M+tM). This also applies to arbitrary original interaction degree but **does not** ensure the posterior is quadratic after observing (H).
5. **Strong sectional backdoor:** if every support (S) satisfies (|S\setminus H|\le2), observe (H) first, then apply the rank-(r) quadratic observer. Query budget (t+\lceil12C_2rB^2/\eta\rceil), capped by (n), with risk (≤\tau_r+\eta); a different, strictly stronger hypothesis than point 4.
6. **Independent covered cubic blocks:** an unrestricted number of disjoint independent blocks, each having a degree-three support transversal of size at most (t), satisfies (V^2\le(\sqrt{C_2}+t)^2B^2M) and a scalar degree-three adaptive bound. **Interlocking** dense cubic links are **not** covered.
7. **Quantum application:** the noisy terminal SLD visibility result rests on the separate quantum-ANOVA/SLD transfer argument; it is *not* an adaptive quantum-query theorem.

Turturean's 2026 all-degree uniform-cube theorem appears as prior art only, **not** as a proof dependency. Worldwide originality and categorical tensor-norm comparisons remain unsettled. This work is **not** peer reviewed, not end-to-end Lean certified, and not a proof of unrestricted degree-three exponent two.

The genuinely new unresolved mechanism is documented in the [aggregate-link cubic overlap checkpoint](../../research/nightfall/2026-11-12-cubic-overlap/README.md). Its high-kurtosis spike-tail bound is **open**.

## Local replay

```bash
python3 -I checks/check_quadratic_models.py
python3 -I checks/check_structured_backdoors.py
pdflatex -interaction=nonstopmode -halt-on-error Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex
pdflatex -interaction=nonstopmode -halt-on-error Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex
```

The finite checker covers 1,477 actual posterior-drift tests and 20 exact heterogeneous backdoor models plus sharpness/obstruction examples; no finite test proves the universal results. Check the historical source SHA-256 above rather than running the original manifest in this reorganized folder (its paths refer to the original ZIP root).
