# Subcube parities refute Conjecture E in its frame form (2026-11-19)

Status: Theorem H proved on paper, with an exact check of the code distance for `L ≤ 4`
(`dichotomy_tests/subcube_code_distance.py`). Not reviewed. The question whether the family has a
quantum advantage is **not** settled; it is sharpened below.

Family: rows are the `3^L` subcube indicators `1_C` of `{0,1}^L`, acting on `S ∈ F_2^{2^L}`
(`m = 2^L`). Equivalently, rows are the rank-one tensors `v_1 ⊗ ⋯ ⊗ v_L` with `v_i ∈ F_2^2 ∖ 0`.

## Theorem H

1. **Small subspace number.** `N_r ≤ (log₂ 3) · L · r = O(r log m)` (counting, `TOWERS_20261119.md`).
2. **No cheap frame.** Every `(c, c′, h)`-frame with `h > 3c` has `c ≥ (4/3)^L = m^{log₂(4/3)} ≈ m^{0.415}`.

Hence for any polynomials `a, b`, Conjecture E as stated (`N_{a(T)} ≤ k ⇒ Λ_T ≤ b(k, T)`) fails for
large `L`: `N_{a(T)} = O(a(T) log m)` while `Λ_T ≥ m^{0.415}`. Frames in Theorem B always have
`h = h(2cT) ≥ 4k_φ cT > 3c`, so the hypothesis `h > 3c` is automatic.

## Proof of 2

*Additivity.* Let `B` be a frame and `rep(C) ⊆ B`, `|rep(C)| ≤ c`, with `∑_{b ∈ rep(C)} b = 1_C`. If `C` is
split into halves `C_0, C_1`, then `1_C + 1_{C_0} + 1_{C_1} = 0`, so the elements of
`rep(C) Δ rep(C_0) Δ rep(C_1)` (at most `3c < h` of them) sum to zero; by `h`-independence the set is
empty. By induction on dimension, `rep(C) = Δ_{z ∈ C} rep({z})`.

*Dual sets.* For `b ∈ B` let `Z_b = {z : b ∈ rep({z})}`. Then `b ∈ rep(C)` iff `|Z_b ∩ C|` is odd, so

    ∑_b #{C : |Z_b ∩ C| odd} = ∑_C |rep(C)| ≤ c · 3^L.

Since `∑_{b ∈ rep(z)} b = 1_z` for every point, the vectors `1_{Z_b}` determine every function, so they
span `F_2^{2^L}`. Hence at least `2^L` of the `Z_b` are nonempty.

*Code distance.* `#{C : |Z ∩ C| odd}` is the Hamming weight of the input codeword `(⟨1_C, 1_Z⟩)_C`. The
input code is the `L`-fold tensor power of the `[3, 2, 2]` simplex code (`(s_0, s_1, s_0 + s_1)`), so its
minimum distance is `2^L` (product codes multiply distances; checked exactly for `L ≤ 4`). So every
nonempty `Z_b` contributes at least `2^L`, giving `2^L · 2^L ≤ c · 3^L`, i.e. `c ≥ (4/3)^L`. ∎

## What is and is not settled

* **Settled:** frames (and the frame cost `Λ_T`) cannot be the sufficiency side of a characterization
  by the subspace number. The small-doubling, dense, direct-sum and bounded-depth results stand, since
  they are proved directly.
* **Not settled:** whether subcube parities give a quantum advantage. Two outcomes remain.
  * *No advantage* (simulation cost `poly(T, log m)`). Then the subspace number may still characterize
    advantage, but the classical simulator must come from somewhere other than an exact local
    representation. Theorem H rules out frames; the merged-symbol representations of Theorem F are
    not yet ruled out.
  * *Advantage.* Then the subspace number is not the right measure, and the answer must see
    recursive (tensor) structure.
* **Evidence for no advantage.** Each query returns a state in a `3^L`-dimensional space, so a
  `T`-query algorithm gains at most `T L log₂ 3` bits (Holevo), and the exact recovery probability is
  `|T·R|/2^m ≤ 3^{LT}/2^{2^L}` (`SECRET_RECOVERY_SUMSETS`).


## Theorem H′ (merged-symbol representations are no better; proved)

Consider any exact **linear** local representation of the subcube input of the kind used in
Theorems B and F: symbols `σ_j = M_j S ∈ F_2^{k_j}` (any sizes, so frames and merged blocks are both
included), such that

* every row `⟨1_C, S⟩` is a function of at most `c` symbols (quantum direction),
* every symbol is computed from at most `c′` rows (classical direction; in particular `k_j ≤ c′`),
* any `h > 3c` symbols are independent and uniform (what Theorem A needs).

Then `c · c′ ≥ (4/3)^L = m^{0.415}`.

*Proof.* Write `W_j` for the row space of `M_j`. Independence of any `h` symbols means any `h` of the
`W_j` form a direct sum. A row that is a function of the symbols in `J_C` (`|J_C| ≤ c`) is a linear
functional on them, so `1_C = ∑_{j ∈ J_C} π_j(C)` with `π_j(C) ∈ W_j`. For halves,
`1_C + 1_{C_0} + 1_{C_1} = 0` involves at most `3c < h` of the `W_j`, so by directness
`π_j(C) = π_j(C_0) + π_j(C_1)` for every `j`. By induction each `π_j` extends to a linear map on
`F_2^{2^L}` with `π_j(1_C) = ∑_{z ∈ C} π_j(1_z)`, and `∑_j π_j = id`.

If `π_j ≠ 0`, pick a functional `λ` with `λ ∘ π_j ≠ 0` and let `Z` be its support on points. Then
`π_j(1_C) ≠ 0` whenever `|Z ∩ C|` is odd, which happens for at least `2^L` subcubes (code distance).
Since `∑_j rank π_j ≥ 2^L` and `rank π_j ≤ k_j ≤ c′`, at least `2^L / c′` maps are nonzero. Counting
pairs `(j, C)` with `π_j(1_C) ≠ 0`:

    (2^L / c′) · 2^L ≤ ∑_C |J_C| ≤ c · 3^L,   so   c · c′ ≥ (4/3)^L. ∎

**Consequence.** Every simulation route built so far for linear inputs (frames, merged balanced
blocks, towers of merges) is an exact linear local representation followed by Theorem A, and all of
them cost `m^{Ω(1)}` on subcube parities, against a subspace number `O(T log m)`. So for this family
**either there is a quantum advantage, or the classical simulator must be of a new kind**:
nonlinear, approximate, or adaptive in a way no fixed representation captures.

## One-query evidence (heuristic, not a proof)

Embed rows as nonzero rank-one tensors and add the zero tensor (phase 1, no query). One query then
gives the state `∑_v (−1)^{g_S(v)} |v⟩` over `v ∈ (F_2^2)^L`, where `g_S(v_1, …, v_L) = S(v_1, …, v_L)` is
the random `L`-linear form, and a Fourier transform samples `w` with probability `ĝ_S(w)²`. For a
subspace `A` with annihilator `U`,

    ∑_{w ∈ A} ĝ_S(w)² = |A| · E_{v, u ∈ U} (−1)^{g_S(v) + g_S(v + u)},

an average of derivatives of `g_S`: a bias, or analytic-rank-type, statistic of a random tensor. For
the natural choices of `U`, for example one coordinate block, giving `Pr_{v_{<L}}[S(v_1, …, v_{L−1}, ·) = 0]`,
these concentrate around their means for random `S`, so a classical simulator can output a constant.
A proof for all one-query algorithms would need a concentration theorem for every such statistic
that is not determined by few rows. That is the precise target for settling the family.

## Next

1. (Done: Theorem H′.)
2. Attack the advantage question directly for `T = 1`: the acceptance probability is a PSD quadratic
   form `yᵀKy` (`tr K ≤ 1`) in the signs `y_C = (−1)^{x_C}`, which are pairwise independent with
   dependencies of weight 3 only from halving. A degree-2 influence argument under this law is the
   cleanest test of whether a non-representation simulator exists.
