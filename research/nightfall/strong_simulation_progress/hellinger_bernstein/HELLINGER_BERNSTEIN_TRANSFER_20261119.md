# Hellinger–Bernstein transfer: removing the bias floor (2026-11-19)

Status: paper proof (short, below) plus a numerical check. Not reviewed, not in Lean, priority
not checked.

## Lemma

Let `μ = ⊗ μ_j`, `μ̄ = ⊗ μ̄_j` be product laws on a finite product `∏ Σ_j` (any alphabets, any
masses, zeros allowed). Let `G : ∏ Σ_j → [0,1]` have coordinate degree `≤ h` (indicator
monomials on `≤ h` coordinates). Put `θ_j = arccos BC(μ_j, μ̄_j)`, `BC(p,q) = ∑_a √(p(a) q(a))`.
Then

    |E_μ G − E_μ̄ G| ≤ h · max_j θ_j ≤ (π/√2) · h · max_j H(μ_j, μ̄_j).

No dependence on `n`, on the alphabet sizes, or on any lower bound on the masses.

## Proof

Write `a_j = √μ̄_j`, a unit vector, and `b_j` the unit vector in the plane of `a_j, √μ_j`
orthogonal to `a_j` with `√μ_j = cos θ_j a_j + sin θ_j b_j`. For real `s` let
`v_j(s) = cos(sθ_j) a_j + sin(sθ_j) b_j`; it is a unit vector, so `μ_j(s) = v_j(s)²` (entrywise)
is a probability vector for **every** real `s`, supported in `supp μ_j ∪ supp μ̄_j`.
`g(s) = E_{⊗ μ_j(s)} G` is therefore in `[0,1]` for all `s ∈ ℝ`. Each `μ_j(s)(τ)` is a combination
of `1, cos 2sθ_j, sin 2sθ_j`, and each monomial of `G` touches `≤ h` coordinates, so `g` is a
trigonometric sum with frequencies in `[−σ, σ]`, `σ = 2h max_j θ_j`. Bernstein's inequality for
`g − ½` (bounded by `½` on `ℝ`) gives `|g′| ≤ σ/2`, so `|g(1) − g(0)| ≤ h max_j θ_j`. Finally
`1 − cos θ = H²` and `θ ≤ π sin(θ/2)` give `θ ≤ (π/√2) H`. ∎

`check_transfer.py`: 20 000 random instances (`n ≤ 3`, alphabets of size 2–3, zero and tiny
masses, `h = n`); max of `|Δ| / (h θ_max)` is `0.99999`, so the constant is sharp.

## Why it matters here

The interpolation step of the strong-simulation route (GMNR gadget / dyadic encoding,
`INDEPENDENT_AUDIT_20261119.md` repair 3) uses a linear path and Markov's inequality, which costs
`h γ / c` with `c` the minimum atom mass. That `1/c` is the "bias floor" listed as open item 1 in
`PRIOR_ART_CHECK_20261119.md`. Replacing the linear path by the Hellinger geodesic and Markov by
Bernstein removes it: dyadic rounding of a `k`-ary law to granularity `2^{-m}` has
`H² ≤ ∑_a |p(a) − p′(a)| ≤ k 2^{-m}`, so the transfer error is `≤ (π/√2) h √(k 2^{-m})` and
`m = O(log(h² k / η²))` suffices, with no `c`.

**Candidate consequence (not proved):** strong bounded-round simulation — `poly(t, 1/ε)·polylog(1/δ)`
for every fixed number of rounds — over arbitrary product laws, any alphabets, no bias floor, by
the BDST + encoding composition with this lemma in place of the linear interpolation. Obligations:
the exact encoding (dyadic blocks with zero atoms), the event approximator degree bookkeeping
(audit repairs 2, 4, 5), and a priority check (is the Bernstein/Hellinger robustness of
bounded low-degree functions known?).

The max-form lemma does **not** settle Lemma H of `mixture_aa/CRUX_FALSIFICATION_20261119.md`,
which needs weights depending only on `(f, μ̄)` so that the max can sit outside the average over
components.
