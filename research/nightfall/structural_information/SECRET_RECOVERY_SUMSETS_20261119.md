# Secret recovery on linear inputs: sumset size is exact, and it is known (2026-11-19)

Status: paper argument; the main formula is a special case of published work. Not reviewed.

## The formula

For `x = Gs` with `s` uniform in `F_2^m` and row set `R`, the optimal probability that a `T`-query
quantum algorithm outputs `s` is

    P*_T = |T·R| / 2^m,     T·R = sums of at most T rows (including 0).

*Upper bound.* The final state is `∑_{v ∈ T·R} (−1)^{⟨v, s⟩} |φ_v⟩` for fixed vectors `φ_v`, so all
`2^m` final states lie in a space of dimension `≤ |T·R|`; identifying one of `N` equiprobable pure
states in dimension `D` succeeds with probability `≤ D/N`.
*Achievability.* Fix a decomposition of each `v ∈ T·R` into `≤ T` rows, prepare
`|T·R|^{-1/2} ∑_v (−1)^{⟨v,s⟩}|v⟩` with `T` phase queries, and measure in the Fourier basis of
`F_2^m`: the overlap with `|ŝ⟩` is `|T·R| / √(|T·R| 2^m)`.

**Prior work.** This is the abelian case of Copeland–Pommersheim, *Quantum query complexity of
symmetric oracle problems*, Quantum 5, 403 (2021), arXiv:1812.09428: for oracles forming a group, the
optimal `t`-query success probability is given by the irreducible characters occurring in the `t`-th
tensor power, here the characters indexed by `T·R`. It must be cited, not claimed.

## How it relates to the computational question

Classical algorithms recover `s` with probability `≤ 2^{T}/2^m` after `T` parity queries. So for
recovery with constant success:

* quantum cost = the **covering index** `κ(R) = min{T : |T·R| ≥ c 2^m}`;
* classical cost = `rank(R) − O(1)`.

**Bridge to Boolean tasks (via Bogolyubov–Ruzsa).** If `|T·R| ≥ 2^m / K`, Sanders' lemma puts a
subspace of codimension `O(log⁴ K)` inside `4T·R`. Theorem C then gives a `4T`-query algorithm for a
0/1 function needing `(m − O(log⁴ K))/2` classical queries. So near-covering for recovery implies a
Boolean advantage at a constant-factor cost in queries, and the subspace number `N_r` of
`LINEAR_NECESSITY` and the covering index agree in the near-covering regime.

**Where sumset size does not suffice.** In the sparse regime, `|T·R|/2^T` can be huge while both
success probabilities are exponentially small. With `n = m²` random rows, `|T·R| ≈ m^{2T}/T!` against
classical `2^T`, but both are `≪ 2^{-m/2}` for `T = o(m / log m)`. That ratio is not a computational
advantage. The Boolean, average-case question (approximating an acceptance probability) still needs
the subspace structure of `T·R`, not just its size. Sumset size is exact for one task (recovery);
Conjecture E is still what a characterization of all tasks needs.
