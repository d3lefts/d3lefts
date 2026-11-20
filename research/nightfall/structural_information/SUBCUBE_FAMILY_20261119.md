# Subcube parities refute Conjecture E in its frame form (2026-11-19)

Status: Theorem H proved on paper, with an exact check of the code distance for `L ≤ 4`
(`dichotomy_tests/subcube_code_distance.py`). Not reviewed. The question whether the family has a
quantum advantage is **not** settled; it is sharpened below.

Family: rows are the `3^L` subcube indicators `1_C` of `{0,1}^L`, acting on `S ∈ F_2^{2^L}`
(`m = 2^L`). Equivalently, rows are the rank-one tensors `v_1 ⊗ ⋯ ⊗ v_L` with `v_i ∈ F_2^2 ∖ 0`.

## Theorem H

1. **Small subspace number.** `N_r ≤ r log₂(3^L + 1) = O(r log m)` (at-most-r counting, with the zero option included; see `TOWERS_20261119.md`).
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

## Next

1. Extend Theorem H's counting to merged-symbol representations (Theorem F type), to see whether any
   exact local representation can be cheap here.
2. Attack the advantage question directly for `T = 1`: the acceptance probability is a PSD quadratic
   form `yᵀKy` (`tr K ≤ 1`) in the signs `y_C = (−1)^{x_C}`, which are pairwise independent with
   dependencies of weight 3 only from halving. A degree-2 influence argument under this law is the
   cleanest test of whether a non-representation simulator exists.
