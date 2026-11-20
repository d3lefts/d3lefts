# One query: additive multiplicity controls simulation; subcube parities have no 1-query advantage (2026-11-19)

Status: Theorem I proved on paper (any linear distribution); Proposition J (subcube multiplicity
`2L + 2`) proved via Kruskal uniqueness and checked exactly for `L ≤ 5`
(`dichotomy_tests/pair_multiplicity.py`); Proposition K extends Theorem H to all linear exact local
representations. Not reviewed.

## Theorem I (one-query simulation by pair multiplicity)

Let `x = Gs` be a linear distribution with rows `R`, and set `R₀ = R ∪ {0}` (the "no query" branch).
Define the **pair multiplicity**

    μ(R) = max_{v ≠ 0} #{(g, g′) ∈ R₀ × R₀ : g ≠ g′, g + g′ = v}.

Every 1-query quantum algorithm has a **non-adaptive** classical simulation with at most
`2μ / (ε² δ)` row queries, error `≤ ε` except with probability `δ`.

*Proof.* With `y_g = (−1)^{⟨g, s⟩}` the acceptance probability is `Q = yᵀ K y`, where
`K = D_ᾱ M D_α`, `α` is the query amplitude vector (`‖α‖ = 1`) and `M` is the Gram matrix of the
post-measurement vectors (`‖M‖_op ≤ 1`). Call `g` heavy if `|α_g|² ≥ η`; there are at most `1/η`
heavy rows. Query them all and output `Q_H + c`, where `Q_H = y_Hᵀ K_HH y_H` and
`c = ∑_{g light} K_gg`.

The remainder `A = Q − Q_H − c` is a combination of characters `χ_{g+g′}` over pairs with at least one
light row and `g + g′ ≠ 0` (pairs with `g + g′ = 0` are constants, absorbed in `c`). Under uniform `s`
distinct characters are orthonormal, so

    E A² = ∑_{v≠0} (∑_{g+g′=v, one light} K_{gg′})² ≤ μ ∑_{one light} |K_{gg′}|² ≤ 2μ ‖K_{·ℓ}‖_F² ≤ 2μ η,

using `‖K_{·ℓ}‖_F ≤ ‖D_α‖_F ‖M‖_op max_{ℓ}|α_ℓ| ≤ √η`. Chebyshev with `η = ε²δ/(2μ)` gives
`Pr[|A| > ε] ≤ δ`. ∎

Checks: independent rows have `μ ≤ 2` (cost `O(1/(ε²δ))`). Bernstein–Vazirani has `μ ≈ 2^m`, so the
bound is vacuous there, as it must be. A subspace `V ⊆ R` of dimension `k` forces `μ ≥ 2^k − 2`, so
`μ ≥ 2^{N_1} − 2`. Theorem I is a sufficiency bound in terms of additive energy, exponentially weaker
than `N` on Bernstein–Vazirani-type inputs, but sharp where energy is low.

## Proposition J (subcube multiplicity)

For the subcube rows of `{0,1}^L`, `μ = 2L + 2`.

*Proof.* Rows are rank-one tensors `⊗u_i`, `u_i ∈ {e₀, e₁, f = e₀ + e₁}`. If `v = ⊗u + ⊗u′` is itself
rank one (`v = ⊗w`), the representations are `(v, 0)`, `(0, v)`, and, for each mode `i`, the two
ordered pairs that agree with `w` off mode `i` and whose `i`-th factors are the two vectors summing to
`w_i`: `2 + 2L` in all. If `v` has rank 2, the modes where the two terms differ are determined by
the mode flattenings. If they differ in at least 3 modes, Kruskal's uniqueness theorem (valid over
any field) makes the decomposition unique up to order; if in exactly 2, `v` is a rank-one tensor times
a rank-2 `2×2` matrix, which has at most 6 ordered decompositions with factors in `{e₀, e₁, f}`.
Exact enumeration gives `μ = 4, 6, 8, 10, 12` for `L = 1, …, 5`. ∎

**Corollary.** Subcube parities have **no 1-query advantage**: every 1-query algorithm is simulated
with `(4L + 4)/(ε²δ) = O(log m /(ε²δ))` row queries, matching the prediction of the subspace number
(`N_r = O(r log m)`), and by a simulator that is not a frame or representation (Theorem H and
Proposition K below rule those out).

## Proposition K (no cheap linear exact representation)

Let `x′` consist of linear symbols `σ_j = A_j s ∈ F_2^{k_j}` whose row spaces are `h`-wise independent
(any `≤ h` of them form a direct sum), with every subcube row a linear function of at most `c` symbols
(`3c < h`) and every symbol computable from at most `c′` rows. Then `c · c′ ≥ (4/3)^L`.

*Proof.* As in Theorem H, independence forces the decomposition `1_C = ∑_j w_j(C)` to be additive under
halving, so `w_j(C) = L_j(1_C)` for linear maps `L_j` with `∑_j L_j = id`. Hence `∑_j rank L_j ≥ m`, and
since `rank L_j ≤ k_j ≤ c′`, at least `m / c′` maps are nonzero. A nonzero `L_j` has a functional `λ`
with `λ ∘ L_j = ⟨1_Z, ·⟩`, `Z ≠ ∅`, so it is nonzero on at least `2^L` subcubes (input-code distance).
Counting `∑_j #{C : L_j(1_C) ≠ 0} ≤ c · 3^L` gives `(m/c′) · 2^L ≤ c · 3^L`. ∎

This covers the merged-symbol representations of Theorem M, so no exact linear local representation
simulates subcube parities cheaply, yet Theorem I does at `T = 1`.

## Status of the subcube question and next step

* `T = 1`: settled, no advantage, by a new kind of simulator (heavy-row truncation plus additive
  energy).
* General `T`: open. The natural generalization replaces `μ` by the **`T`-fold multiplicity**
  `μ_T(R) = max_{v≠0} #{(p, p′) : p, p′ sums of ≤ T rows (as sequences), v(p) + v(p′) = v}` and needs an
  adaptive version of the heavy-row step (heavy query paths are not single rows). For subcubes,
  tensor-rank uniqueness should give `μ_T ≤ (cL)^{O(T)}`, which would rule out any advantage with
  `T = o(log m / log log m)` queries. Writing the adaptive `T`-query version is the next target.
* Conceptually, Theorems H, I and K show that the classical side of a characterization needs
  **energy-based (analytic) simulators**, not only exact representations.


## Independent B-side replay: exact finite check and the T=2 failure boundary

Theorem I and Proposition J above were **already developed by Claude**. An independent derivation and checker, now archived in [PROOF_PASSPORT_SUBCUBE_T1_20261119.md](PROOF_PASSPORT_SUBCUBE_T1_20261119.md) and \`scripts/check_subcube_one_query.py\`, reproduce the same \(2\mu/(\varepsilon^2\delta)\) theorem with a quantum-positive-contraction matrix and preserve the omitted diagonal contribution exactly. The separate exact checker exhausts XOR pair-fibers for \(L=1,\dots,5\), all secret assignments for finite \(L=1,2,3\) under explicit normalized one-query projectors, and rational Parseval/Frobenius estimates; it is **finite reproduction**, not an independent proof of all \(L\) or a Lean/human review.

**Explicit obstruction to a naïve T=2 extension.** Let \(a,b\) be distinct available row vectors. Use the ordinary bit oracle in its phase eigenbasis on a two-dimensional answer register, with phase \(D_r=\operatorname{diag}(1,\chi_r(s))\). Start in \((|0\rangle+|1\rangle)/\sqrt2\), query \(a\), apply \(U=\left(\begin{smallmatrix}3/5&-4/5\\4/5&3/5\end{smallmatrix}\right)\), and query \(b\). The resulting normalized state is
\[
|\psi_s\rangle=\frac{(3-4\chi_a)|0\rangle+
 \chi_b(4+3\chi_a)|1\rangle}{5\sqrt2}.
\]
The Fourier-state components at frequencies \(0\) and \(a\) are parallel, with inner product \(-6/25\); likewise for \(b\) and \(a+b\). Hence frequency-sector orthogonality, the essential T=1 step in Theorem I, is false for general T=2 processes. Measurement in the \(|+\rangle\) basis has exact acceptance probability
\[
\Pr(+\mid s)=\tfrac12-\tfrac7{50}\chi_{a+b}(s),
\]
verified for all four parity assignments with exact rational arithmetic. This does **not** establish any quantum advantage and does **not** disprove a different \(T=2\) simulator. It rules out copying the T=1 orthogonal-frequency matrix estimate without a new operator inequality.

**Status of this addendum:** independent exact finite replay + author-side elementary T2 falsifier. No new general-T bound or novelty claim.
