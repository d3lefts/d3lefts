# Priority dossier: Q2 against Grothendieck, decoupling and the November 2026 AA literature

**Dated literature audit, 2026-11-17. Human-led, AI-assisted.** This is a search record, not a priority certificate. It covers the accessible public sources listed below; the two reported Zenodo references were not independently accessible or corroborated. "No prior art found" means none was found in these sources, not that none exists.

## Verdicts by claim

| Claim | Scope | Verdict |
|---|---|---|
| Binary degree-two bound `Var² ≤ 16 K_G² B² max Inf` (coefficient < 51) | `{−1,1}^n`, any product law | **Classical, no NIGHTFALL priority.** This is a corollary of Grothendieck's inequality plus Efron–Stein; the bounded-quadratic ↔ Grothendieck link is in Aaronson–Ambainis–Iraids–Kokainis–Smotrovs (CCC 2016). The repo already labels it a comparator (v8, Prop. `prop:groth`). It is now formalized in Lean, with Grothendieck/Krivine as an explicit premise (`formalization/binary_grothendieck/`). |
| `NF-PS-FINITE-20261110`: general-degree influence bound on heterogeneous finite products, exponents (5/2, 6), no atom-mass dependence | arbitrary finite product laws | **Priority unresolved; external citation requires verification.** Two purported Zenodo records (24051767/24124921), attributed here to Deep Bhattacharjee and a 2026-11-08 product-measure result, could not be retrieved via live access or independently corroborated by exact-title/record-ID search. Their publication dates, author/title, theorem scope, and very existence as matching records are **unverified**. Neither precedence nor originality can be inferred. Obtain dated record metadata and source text, then compare exact hypotheses before updating the verdict. |
| `NF-PS-QUADRATIC-20261110` / Q2: degree ≤ 2, **arbitrary alphabets**, `Var² ≤ C B² max Inf` with a constant independent of alphabet, laws and atoms | arbitrary (finite → infinite) products | **No prior art found; priority unresolved.** See the analysis below. |
| `NF-PS-Q2-INFINITE-LIFT-20261117` | lift of the above to arbitrary products | No novelty claimed: a standard approximation argument. |

## Why Grothendieck does not already give the categorical Q2

- **Binary case:** Grothendieck controls `Σ_i ‖∂_i f‖₂ ≤ 4 K_G B`, a *root-sum* of influences, and Efron–Stein converts that to `Var² ≤ 16K_G² B² M`. This root-sum strategy is exactly what fails for categorical inputs.
- **Exact obstruction (repo, 2026-11-13):** let `A` be uniform on `[m]`, let `Z_1..Z_m` be fair signs, and take `f = Z_A`. This `f` is bounded with degree two, yet `Σ_i √I_i(f₂) = (1+√m)·√(1−1/m) → ∞`. So no alphabet-uniform root-sum bound holds, and the binary Grothendieck proof cannot be transported coordinate-by-coordinate. (`2026-11-quadratic-law-free-audit/Q2_GROTHENDIECK_DECOUPLING_SCOPE_AUDIT_20261113.md`, exact checker `check_q2_decoupling_scope_exact.py`.)
- Grothendieck's theorem for general `L∞(μ)` spaces factors the bilinear form through Hilbert space. It does not by itself relate that factorization to the *coordinate* resampling influences of the original product law, and that relation is the missing step.

## Why decoupling does not already give it

- Decoupling inequalities (de la Peña–Montgomery-Smith; de la Peña–Giné 1999) compare `Σ h_ij(X_i,X_j)` with `Σ h_ij(X_i,X'_j)` in norm or tail with universal constants. Turning that into a bound on `max_i Inf_i` needs one-sided (upper-triangular) truncation of the kernel. Triangular truncation is not bounded in the cut norm in general, so the factor is not a harmless constant (repo audit §A; exact identity `Var(f₂) = E K_right² = ½ E K_sym²`).
- No decoupling paper found states an influence bound of this form.

## November 2026 Aaronson–Ambainis literature (checked)

- **Turturean**, arXiv:2611.09773 (2026-11-06; Lean formalization by PSI): uniform cube; `max_j Inf_j ≥ c·Var^{5/2}/d^6`. §9.5 lists **"best exponents" as open**, including whether α = 2 is attainable for general d. It contains no product-space or degree-two material.
- **Blanc–Docter–Strassle–Tan**, arXiv:2611.11626 (exposition, 2026-11-08): uniform `{0,1}^n`.
- **Huffstutler–Miloschewsky–Podder**, arXiv:2611.12795 (2026-11-09): short proof via the completion framework; uniform setting.
- **Girish–Mittal–Nehoran–Raz**, arXiv:2609.35327 (2026-09-28): the biased-product (fixed p) and slice variants of AA are *equivalent* to the uniform one. Coordinate-dependent biases and non-binary alphabets are not addressed in the abstract.
- **Escudero Gutiérrez**, arXiv:2304.06713: homogeneous **Fourier-completely-bounded** degree-2d polynomials on the uniform cube have `max Inf ≥ Var²`. Its Remark 4.3 says the method does not extend to all bounded polynomials. Uniform measure only.
- **Bansal–Sinha–de Wolf**, CCC 2022: AA for completely bounded block-multilinear forms; uniform cube.
- **Unverified Zenodo lead** (reported 2026-11-08 / 2026-11-11): see the table above; not evidence of an established predecessor.

None of these sources states a degree-two, variance-exponent-two influence bound on **non-binary** product spaces with constants independent of alphabet and atom mass.

## Lean status relevant to priority

- The binary coefficient now has a Lean reduction to Grothendieck (this PR). Grothendieck's inequality and Krivine's bound are not in Mathlib or in any public Lean project found. A 2026 NeurIPS paper (Saha et al.) reports a "partially formalized Lean blueprint" for `K_G < Krivine − 10⁻¹⁷`; it is not a usable dependency.
- The categorical finite Q2 (C ≈ 105.4) is kernel-checked on main (`native_heterogeneous_q2_105416_unconditional`). Lean certifies validity, not priority.

## Recommended catalogue actions (applied in this PR)

1. `NF-PS-FINITE-20261110`: keep `priority: unresolved`; retain the purported Zenodo citation only as an **unverified investigation lead**, not a proven prior-publication gate. Require retrievable dated metadata and a scope-matched full-text review.
2. `NF-PS-QUADRATIC-20261110`: keep `priority: unresolved`, record that no prior art was found in the sources above, and record that the Grothendieck and decoupling routes have documented obstructions.
3. No claim is promoted to `externally-audited`; that tier requires an outside reviewer.

## Sources

- Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 — https://arxiv.org/abs/2611.09773
- Blanc, Docter, Strassle, Tan, *Proof of the Aaronson–Ambainis Conjecture: An Exposition*, arXiv:2611.11626 — https://arxiv.org/abs/2611.11626
- Huffstutler, Miloschewsky, Podder, arXiv:2611.12795 — https://arxiv.org/abs/2611.12795
- Girish, Mittal, Nehoran, Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, arXiv:2609.35327 — https://arxiv.org/abs/2609.35327
- Escudero Gutiérrez, *Influences of Fourier Completely Bounded Polynomials…*, arXiv:2304.06713 — https://arxiv.org/abs/2304.06713
- Bansal, Sinha, de Wolf, CCC 2022, arXiv:2203.00212 — https://arxiv.org/abs/2203.00212
- Unverified claimed Zenodo references (inaccessible in current review; no substantive conclusion drawn): https://zenodo.org/records/24051767 , https://zenodo.org/records/24124921
- Aaronson, Ambainis, Iraids, Kokainis, Smotrovs, CCC 2016, arXiv:1511.08682 — https://arxiv.org/abs/1511.08682
- Braverman, Makarychev, Makarychev, Naor, *The Grothendieck constant is strictly smaller than Krivine's bound* — https://arxiv.org/abs/1103.6161
- Grothendieck-constant improvement, arXiv:2606.03991 — https://arxiv.org/abs/2606.03991
