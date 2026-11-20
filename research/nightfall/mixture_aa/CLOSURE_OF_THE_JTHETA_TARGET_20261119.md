# Closing the `J_Θ` target: the information-routing lemma is the Key Lemma of #928 (2026-11-19)

Status: paper proof (unreviewed), with a step-by-step verification and a Monte Carlo check of the
inequality chain. Responds to an outside analysis (pasted ChatGPT note, 2026-11-19 19:04) that lists
the general-`T`, `log M` theorem as open and names the missing result as

    J_Θ ≤ poly(T) · (max_i I(Θ; X_i))^γ,

where `J_Θ` is the expected absolute change in the acceptance probability when the hidden
component is resampled with the coordinate seeds held fixed. That note predates #928.

## The target is proved, with `γ = 1/3` and `poly(T) = O(T²)`

`ROUTE1_PROOF_20261119.md` (Key Lemma): for every `η ∈ (0,1]`,

    E_θ E_u |f(h(θ,u)) − f(h̄(u))| ≤ π² d² · (π²/4) · I*/η² + 8 d² η,     I* = max_j I(θ; x_j).

With `η = (I*)^{1/3}` and the triangle inequality through the reference `h̄(u)`:

    J_Θ ≤ 2 (π⁴/4 + 8) d² · (I*)^{1/3},     d = 2T.

Constants do not depend on `M`, `n`, alphabets or masses.

## Why no adaptive query-weight argument is needed

The outside note proposes routing *adaptively shifting quantum query weights*, because fixed
per-algorithm query weights need not exist for `T ≥ 2` and the categorical (pointwise) FUR has a
degree-2 counterexample (#923). The proof uses neither. It uses only that the acceptance
probability `f` is a `[0,1]`-valued function of coordinate degree `≤ 2T`, and two certified facts that
hold for **every** such function:

1. **Rows at a point** (`RowBound.product_row_bound`): `|f(x) − f(y)| ≤ ∑_{j: x_j ≠ y_j} a_j(x)`,
   `∑_j a_j(x) ≤ π² d²`. Rows may depend on `x_j`; no fiber-invariance is required.
2. **Single-coordinate sensitivity** (`product_block_inequality`, `m = 1`):
   `∑_j osc_j(z) ≤ 4 d²` pointwise.

The fiber issue that made FUR necessary in earlier attempts is avoided because the coordinates
charged to rows form a **deterministic** set `L_θ = {j : φ_{θ,j} > η}` (Hellinger angle above the
threshold), not the seed-dependent mismatch set. So the row at the single anchor `h̄(u)` is
averaged over `θ` against `Pr_θ[j ∈ L_θ]`, which does not depend on `u`, and the max over coordinates
lands outside the component average. The small-angle coordinates are handled for each `θ`
separately by the switching lemma, at cost `8d²η`, with no information needed.

## Step-by-step verification

| Step | Claim | Justification |
| --- | --- | --- |
| 1 | `E_θ φ_{θ,j}² ≤ (π²/4) I_j` | `φ ≤ π sin(φ/2)`, `sin²(φ/2) = H²/2`, `H² ≤ −ln BC ≤ KL/2` (Rényi-½ ≤ KL), `E_θ KL(μ_{θ,j} ‖ ν̄_j) = I_j` |
| 2 | `Pr_θ[j ∈ L_θ] ≤ (π²/4) I_j / η²` | Markov on step 1 |
| 3 | `E_θ |f(x̄) − f(z^θ)| ≤ π²d² max_j Pr_θ[j ∈ L_θ]` for every `u` | `z^θ` differs from `x̄ = h̄(u)` only inside `L_θ`; row at `x̄`; `L_θ` deterministic |
| 4 | `Pr[h_j(θ,u_j) ≠ h̄_j(u_j)] ≤ 2 TV ≤ 2 sin φ ≤ 2η` off `L_θ` | consistent sampling (mismatch `≤ 2TV/(1+TV)`), `TV ≤ √(1 − BC²)` |
| 5 | `E_u |f(z^θ) − f(h(θ,u))| ≤ 4d² · 2η` | Lemma S: pairs independent across `j` (functions of `u_j`); jump at `j` ≤ `1[mismatch] osc_j(z(t))` with `z(t)_{−j}` independent of the pair; `∫ ∑_j E osc_j(z(t)) dt ≤ 4d²` |
| 6 | Key Lemma | steps 2, 3, 5 |
| 7 | Crux: `E_π L_j ≥ 2γ` or `I_j ≥ (γ/c_d)³` | lift `G(θ,u)`, Efron–Stein degree `≤ d+1`, `infinitePi_aa_product` gives `Inf ≥ γ(τ,d+1)`; `Inf_c ≤ ½ E|G − G^{(c)}|`; seed increment `= E_π L_j^{μ_θ}`; `θ`-increment `≤ J_Θ` |
| 8 | Simulator | `Φ = E_π ∑_i L_i ≤ 2d²` drops by exactly `E_π L_j` per query (posterior update + Fubini); `H(π) ≤ ln M` drops by `I(θ; x_j | ρ)`; Chebyshev at leaves, Markov on depth |

Resulting depth: `O((d⁸ τ^{-5/2} + d²⁴ τ^{-15/2} ln M)/δ)` with `τ = ε²δ/2`, i.e.
`poly(T, 1/ε, 1/δ) · (1 + log M)` whole-symbol queries.

## Monte Carlo check (`keylemma_check.py`)

Exact LP rows (`K_f`), exact pointwise `S_f = max_x ∑_j osc_j`, consistent sampling, `n = 5` bits,
`M = 24` spiky components (each moves a random 2-set strongly, small noise elsewhere), four
thresholds `η`, two seeds: the instance-specific chain
`E_θ E_u |f(h^θ) − f(h̄)| ≤ K_f · max_j Pr[j ∈ L_θ] + S_f · max_{j ∉ L_θ} Pr[mismatch]` held in all
8 runs (LHS 0.16–0.18, RHS 0.97–2.03). This checks the logic, not the constants' sharpness.

## Remaining before calling it a theorem

1. Independent review of steps 3–5 and 7 (the lifting must use one consistent-sampling seed per
   coordinate for all components and the reference simultaneously).
2. Priority search on product-mixture simulation.
3. Lean: steps 1–6 are finite and elementary given the certified row bound and block inequality;
   step 7 needs the lifted product with continuous seeds (or a finite-seed coupling with exact
   marginals); step 8 reuses `Phi_sum` and needs a finite entropy chain rule.

PR #924 (FUR(2) via quadratic transition remainder) and the adaptive-routing programme are not
needed for this theorem; they remain of independent interest.
