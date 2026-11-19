# Strong bounded-round simulation over arbitrary product laws, no bias floor (2026-11-19)

Status: complete paper proof, conditional only on BDST Theorem 1 as a black box. Not reviewed,
no Lean. Uses the Hellinger–Bernstein transfer lemma (`HELLINGER_BERNSTEIN_TRANSFER_20261119.md`).

## Theorem

Let `Ω = Σ_1 × ⋯ × Σ_n` with finite alphabets, `K = max_j |Σ_j|`, and `μ = ⊗ μ_j` **any** product
law (masses arbitrary, zeros allowed). Let `Q : Ω → [0,1]` be the acceptance probability of a
quantum algorithm making `t` queries to the value oracle `|j, b⟩ ↦ |j, b + x_j⟩` in `d` rounds.
For `0 < ε, δ < 1/2` there is a deterministic classical decision tree `T` on `x` with

    depth(T) ≤ 2^{O(d²)} · ( t · log(K/δ) / ε )^{O(d)}

and `Pr_{x∼μ} [ |T(x) − Q(x)| > ε ] ≤ δ`.

The bound does not depend on `n` or on any probability in `μ`. It is polylogarithmic in `1/δ`
and in `K` for every fixed `d`.

**Comparison.** BDST (arXiv:2608.19158, Thm 1) prove this for the uniform cube. Composing BDST with
the GMNR gadget (arXiv:2609.35327) gives it for biases in `[a, 1 − a]` with overhead `poly(1/a)`
(`PRIOR_ART_CHECK_20261119.md`, where that composition is recorded as routine, not new). The new
content is the removal of `a` (equivalently the minimum atom mass `c` of the audit's repair 3),
which also covers sparse inputs and `k`-ary alphabets.

## Black box (BDST Thm 1, as recorded in `PRIOR_ART_CHECK_20261119.md`; confirm against the PDF)

`S(t, d, ε, δ) = 2^{O(d²)} (t log(1/δ)/ε)^{O(d)}`: every `t`-query, `d`-round quantum algorithm on
uniform `Y ∈ {0,1}^N` (any `N`) has a deterministic tree `T′` of depth `≤ S` with
`Pr_Y[|T′(Y) − Q′(Y)| > ε] ≤ δ`.

## Proof

**1. Dyadic law.** Fix `m`. For each `j` let `μ′_j` round every mass of `μ_j` down to a multiple of
`2^{-m}` and add the remainder to one atom. Then `TV(μ_j, μ′_j) ≤ K 2^{-m}`, hence
`H²(μ_j, μ′_j) ≤ TV ≤ K 2^{-m}` (with `H² = 1 − BC`), and `θ_j = arccos BC(μ_j, μ′_j) ≤ (π/√2) H`.
So `θ_max ≤ (π/√2) √(K 2^{-m})`. Fix maps `g_j : {0,1}^m → Σ_j` with `|g_j^{-1}(a)| = 2^m μ′_j(a)`;
`g_j` pushes the uniform law to `μ′_j`.

**2. Encoded algorithm.** On `Y = (Y_1, …, Y_n) ∈ ({0,1}^m)^n` uniform, run the original algorithm
with each round replaced by: query the `m` bits of each requested block in parallel, compute
`g_j(Y_j)` into an ancilla, apply the original oracle's action using the ancilla (no query), then
uncompute with a second parallel round. This is exact: `Q′(Y) = Q(g(Y))`, with `≤ 2mt` queries in
`≤ 2d` rounds. BDST gives a deterministic tree `T′` of depth `D = S(2mt, 2d, ε, δ/4)` with
`Pr_U[|T′ − Q′| > ε] ≤ δ/4`.

**3. Simulation on `x`.** Randomized tree `R(x, r)`: run `T′`; when `T′` first asks a bit of block
`j`, query `x_j` once and set `Y_j` uniform in `g_j^{-1}(x_j)` using `r` (or `Y_j = 0` if empty);
answer all bits of block `j` from `Y_j`. Depth `≤ D`. If `x ∼ μ′` then `Y` is uniform and
`g(Y) = x` a.s., so `Pr_{x∼μ′, r}[|R − Q| > ε] ≤ δ/4`. For fixed `r`, `R(·, r)` is a depth-`≤ D`
tree on `x`, so its output has coordinate degree `≤ D`.

**4. Smoothed event.** Let `k_φ = ⌈(2/(9ε⁴)) ln(8/δ)⌉`, `r_φ = ⌊5 k_φ ε² / 2⌋`, and
`φ(z) = Pr[Bin(k_φ, z²) > r_φ]`, a polynomial in `z` of degree `2k_φ`, with `0 ≤ φ ≤ 1` on
`[−1, 1]`. Hoeffding gives `φ ≤ δ/8` when `|z| ≤ ε` and `φ ≥ 1 − δ/8` when `|z| ≥ 2ε`. Put
`G(x) = E_r φ(Q(x) − R(x, r))`. Then `G` maps `Ω` into `[0,1]` and has coordinate degree
`≤ h := 2k_φ · max(2t, D)` (`Q` has coordinate degree `≤ 2t` in the symbol indicators; products of
indicator monomials add coordinate sets). And `E_{μ′} G ≤ δ/4 + δ/8`.

**5. Transfer (Hellinger–Bernstein).** `E_μ G ≤ E_{μ′} G + h θ_max ≤ 3δ/8 + h (π/√2) √(K 2^{-m})`.

**6. Choice of `m`.** `h = h(m)` is polynomial in `m` (through `D`), so there is
`m = O( d² + d log(t log(1/δ)/ε) + log(K/δ) + log(1/ε) )` with `h(m)(π/√2)√(K 2^{-m}) ≤ δ/8`.
Then `E_μ G ≤ δ/2`.

**7. Conclusion.** `Pr_{μ, r}[|R − Q| ≥ 2ε] ≤ E_μ G / (1 − δ/8) < δ`. Averaging over `r`, some fixed
`r*` gives a deterministic tree `T = R(·, r*)` with the same bound. Its depth is
`D = S(2mt, 2d, ε, δ/4) = 2^{O(d²)} (m t log(1/δ)/ε)^{O(d)} = 2^{O(d²)} (t log(K/δ)/ε)^{O(d)}`.
Rescale `ε ↦ ε/2`. ∎

## Where the bias floor went

Every step is exact or measure-free except step 5. With the linear path and Markov's inequality
(GMNR; audit repair 3) step 5 costs `h · γ / c`, `c` the least positive atom. The Hellinger geodesic
keeps every intermediate law a probability law for all real `s`, so Bernstein's inequality applies
on the whole line and the cost is `h θ_max`, with no `c`.

## Open items

1. Confirm BDST Theorem 1's exact statement (oracle model, deterministic tree, `N`-independence).
2. Priority: a quick search found no statement of the Hellinger–Bernstein lemma; a specialist
   should confirm it is not folklore.
3. The `log K` is forced by this encoding (uniform on `K ≫ 2^m` symbols is far from any `m`-bit
   dyadic law); whether it can be removed is open.
4. Mixtures of `M` products (route 1, Mixture-AA) are not covered.
5. Lean: the transfer lemma needs Bernstein's inequality for exponential-type functions, which is
   not in Mathlib as far as we know; the rest is finite combinatorics plus the BDST black box.
