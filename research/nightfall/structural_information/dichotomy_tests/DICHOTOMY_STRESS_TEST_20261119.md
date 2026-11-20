# Stress test of Conjecture E (2026-11-19)

Status: Conjecture E survives every family tested. Small exact computations turned out to be
uninformative (finite-size saturation); the informative results are analytic, and in three explicit
families **both directions are proved** by Theorems A and C, with a sharp threshold in `T`.
Not reviewed.

## Exact computations (`sumset_tests.py`, `m ≤ 12`)

`|r·R| / 2^m` and the subspace number `N_r` (exact maximum subspace inside `r·R`):

| Family | m | n | r = 1 | r = 2 | r = 3 |
| --- | --- | --- | --- | --- | --- |
| Gold/APN graph `{(x, x³)}`, `k = 6` | 12 | 63 | 0.02, N=1 | 0.49, N=6 | 1.00, N=12 |
| dual BCH `t = 2`, `k = 6` | 12 | 63 | 0.02, N=1 | 0.49, N=6 | 1.00, N=12 |
| rank-one `a × a`, `a = 3` | 9 | 49 | 0.10, N=3 | 0.67, N=6 | 1.00, N=9 |
| random, `n = 2m` | 12 | 24 | N=2 | N=4 | 0.42, N=6 (r=4: 0.93, N=7) |
| random, `n = m²` | 12 | 143 | N=2 | 0.92, N=7 | 1.00, N=12 |

At `m ≤ 12` almost everything saturates by `r = 3`, so these sizes cannot separate the asymptotic
regimes (e.g. `n = m²` random rows saturate at `r = 3` here but need `r ≈ m / (2 log m)`
asymptotically). They do confirm the analytic claims below at small sizes (APN and BCH: `2·R` has
density ≈ 1/2 and `3·R` is everything; rank-one: `N_r = 3r`).

## Analytic results

**Dual BCH rows `{(x, x³, …, x^{2t−1}) : x ∈ F_{2^k}^*}`, `m = tk`.** Dependencies among rows are
codewords of the primitive BCH code of designed distance `2t + 1`, so the input is `2t`-wise
independent: by Theorem A there is **no advantage** for every `T` with `h(T, ε, δ) ≤ 2t`. The covering
radius of the 2-error-correcting BCH code is 3 (Gorenstein–Peterson–Zierler), and of the
`t`-error-correcting primitive BCH code `2t − 1` for large `k` (Helleseth, Tietäväinen; to be checked
against the literature), so `(2t−1)·R = F_2^m` and by Theorem C a `(2t−1)`-query algorithm has
advantage `m/2`. **Sharp threshold:** no advantage below `T ≈ t / poly(1/ε, log 1/δ)`, advantage
`Θ(m)` at `T = 2t − 1`.

**Gold/APN graph `{(x, x³)}`, `m = 2k`, `n = 2^{m/2}`.** This is the `t = 2` case above: a sparse
(square-root size), algebraically pseudorandom row set whose 3-fold sumset is everything. Advantage
`Θ(m)` with 3 queries; no advantage for `h(T) ≤ 4`.

**Rank-one matrices `{x yᵀ}` in `F_2^{a×a}`, `m = a²`.** `r·R` is the set of matrices of rank `≤ r`,
and by Flanders' theorem the largest subspace of matrices of rank `≤ r` has dimension `r a`. So
`N_r = r a`, and Theorem C gives advantage `≈ r a` with `r` queries. The standard basis is a frame
with `c = a² = m`, `c′ = 1`, so `Λ ≤ m ≤ N_1²`: the two measures are polynomially related, as
Conjecture E predicts.

**Random rows, `n = 2^{m^α}`.** Dual distance `≈ m^{1−α}` (GV), so no advantage while
`h(T) ≲ m^{1−α}`; covering by `r ≈ m^{1−α}` sums, so advantage `Θ(m)` at `T ≈ m^{1−α}`. Threshold
again matched up to polynomial factors.

## What this says

In every family tested, the answer is governed by two classical coding-theory parameters of the
dependency code `C_R = {a ∈ F_2^n : ∑ a_i g_i = 0}`: its **minimum distance** (independence ⇒ no
advantage, Theorem A) and its **covering radius** (short sums cover ⇒ advantage, Theorem C), and these
are polynomially related within each family. Conjecture E would follow for any class of row sets in
which, after merging duplicate structure (frames), minimum distance and covering radius of `C_R` are
polynomially related. Delsarte-type inequalities relating covering radius to the dual weight
distribution are the natural tool for that.

No candidate counterexample found. The dangerous regime remains row sets whose dependency code has
small minimum distance and large covering radius **and** no cheap frame; repeated and local rows
have small distance and large covering radius but are removed by frames.

## Next

1. Prove Conjecture E for row sets whose dependency code has minimum distance and covering radius
   within a polynomial (a "balanced code" class covering every family above), via Theorems A and C
   directly.
2. Attack the general case by reducing to the balanced class with a frame-construction (merging)
   procedure; PFR for the small-doubling part.
