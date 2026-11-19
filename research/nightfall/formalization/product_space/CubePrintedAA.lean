import ProductInfluence
import AaronsonAmbainis.Bridge.PrintedAA
import AaronsonAmbainis.Conjecture

/-!
# The printed Aaronson–Ambainis conjecture as a specialisation of the product-space theorem

The NIGHTFALL product-space chain (`ProductRowBound`, `ProductInfluence`) proves, for a bounded
function of interaction degree at most `d` on any finite product space `ι → α` with any product
law `p` (zero-mass atoms allowed), the influence bound

  `3 Var(f)⁵ ≤ 12500 K⁴ L(f)² Inf_j(f)²`   (`Influence.influence_bound`)

with `K = π² d²` the cost of a fractional-certificate row at every point
(`RowBound.product_row_bound`) and `L(f) = ∑_k E|f(x) - f(x_k := b)|` the total mean resampling
increment. This file specialises it to `α = Bool` with the uniform law `p i b = 1/2`:

* `hasProdDegreeLE_of_hasDegreeLE`: a character expansion of degree `≤ d` is an
  indicator-monomial expansion of interaction degree `≤ d`;
* `pvar_unif`, `pinfl_unif`, `pincr_unif`: the product-law variance and Efron–Stein influence
  are Turturean's `variance` and `inflR`;
* `sum_pincr_unif_le`: `L(f) ≤ 2 d²`, from the product block inequality
  (`RowBound.product_block_inequality`) applied to the `n` single-bit flips at each point
  (`m = 1`, every coordinate is moved by one flip, `1·(1 - cos π) = 2`);
* `mainTheorem_of_productSpace : AaronsonAmbainis.MainTheorem`, i.e.
  `3 Var(f)⁵ ≤ 12500 (π² d²)⁴ (2 d²)² Inf_j(f)² = 50000 π⁸ d¹² Inf_j(f)²`.

Turturean's transport lemmas (`Bridge/PrintedAA.lean`, vendored unchanged) then carry
`MainTheorem` to the Mathlib-only statements of `Conjecture.lean`:

* `printedConjecture : AaronsonAmbainis.PrintedConjecture` — Conjecture 6 of arXiv:0911.0996 as
  printed, `Inf_i[p] ≥ (ε/d)^7`;
* `explicitBound : AaronsonAmbainis.ExplicitBound` — `Inf_i[p] ≥ (8√15/(125π⁴)) ε^{5/2}/d⁶`.

Provenance. The product-space chain is a port of Turturean's argument (arXiv:2611.09773) from the
cube to finite product spaces, and it calls his vendored Chebyshev/Markov cube lemmas inside the
block inequality. These theorems therefore do not give an independent proof of the conjecture.
What they certify is that the NIGHTFALL product-space theorem contains the original conjecture
as the special case `α = Bool`, `p = 1/2`, with Turturean's constant exactly, and that nothing
in this file uses his cube theorem `AaronsonAmbainis.mainTheorem` or his `Chain.lean`.
-/

namespace Nightfall.ProductSpace.CubeAA

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- The uniform law on each bit. -/
noncomputable def unif : ι → Bool → ℝ := fun _ _ => 1 / 2

theorem unif_nonneg : ∀ (i : ι) (b : Bool), 0 ≤ unif i b := fun _ _ => by
  unfold unif; norm_num

theorem unif_sum : ∀ i : ι, ∑ b, unif i b = 1 := fun _ => by
  simp only [unif, Fintype.sum_bool]; norm_num

theorem prodMass_unif (x : ι → Bool) :
    prodMass unif x = 1 / 2 ^ Fintype.card ι := by
  simp only [prodMass, unif, Finset.prod_const, Finset.card_univ, one_div, inv_pow]

theorem sum_inv_two_pow : ∑ _x : ι → Bool, (1 : ℝ) / 2 ^ Fintype.card ι = 1 := by
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fun, Fintype.card_bool, nsmul_eq_mul]
  push_cast
  field_simp

theorem update_not_eq_flipSet (x : ι → Bool) (j : ι) :
    Function.update x j (!x j) = AaronsonAmbainis.flipSet x {j} := by
  funext i
  by_cases h : i = j
  · subst h; simp [AaronsonAmbainis.flipSet]
  · simp [AaronsonAmbainis.flipSet, h]

/-- A sum over the new value of bit `j` sees only the flip. -/
theorem sum_bool_update (x : ι → Bool) (j : ι) (F : (ι → Bool) → ℝ)
    (h0 : F x = 0) :
    ∑ b, F (Function.update x j b) = F (AaronsonAmbainis.flipSet x {j}) := by
  rw [← update_not_eq_flipSet]
  have hx : Function.update x j (x j) = x := Function.update_eq_self j x
  cases hxj : x j
  · rw [Fintype.sum_bool]
    rw [hxj] at hx
    rw [hx, h0]; simp
  · rw [Fintype.sum_bool]
    rw [hxj] at hx
    rw [hx, h0]; simp

theorem pexp_unif (f : (ι → Bool) → ℝ) : pexp unif f = AaronsonAmbainis.mean f := by
  simp only [pexp, prodMass_unif, AaronsonAmbainis.mean]
  rw [Finset.sum_div]
  exact Finset.sum_congr rfl fun x _ => by ring

theorem pvar_unif (f : (ι → Bool) → ℝ) : pvar unif f = AaronsonAmbainis.variance f := by
  simp only [pvar, prodMass_unif, pexp_unif, AaronsonAmbainis.variance]
  rw [Finset.sum_div]
  exact Finset.sum_congr rfl fun x _ => by ring

theorem pinfl_unif (f : (ι → Bool) → ℝ) (j : ι) : pinfl unif f j = AaronsonAmbainis.inflR f j := by
  unfold pinfl AaronsonAmbainis.inflR
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun x _ => ?_
  have := sum_bool_update x j
    (fun y => prodMass unif x * (1 / 2) * ((f x - f y) ^ 2 / 2)) (by simp)
  simp only [unif] at this ⊢
  rw [this, prodMass_unif]
  ring

theorem pincr_unif (f : (ι → Bool) → ℝ) (k : ι) :
    pincr unif f k = ∑ x, 1 / 2 ^ Fintype.card ι * (1 / 2) *
      |f x - f (AaronsonAmbainis.flipSet x {k})| := by
  unfold pincr
  refine Finset.sum_congr rfl fun x _ => ?_
  have := sum_bool_update x k
    (fun y => prodMass unif x * (1 / 2) * |f x - f y|) (by simp)
  simp only [unif] at this ⊢
  rw [this, prodMass_unif]

/-- A character expansion of degree at most `d` is an indicator-monomial expansion of
interaction degree at most `d`. -/
theorem hasProdDegreeLE_of_hasDegreeLE (f : (ι → Bool) → ℝ) (d : ℕ)
    (h : AaronsonAmbainis.HasDegreeLE f d) : HasProdDegreeLE f d := by
  classical
  obtain ⟨c, hc0, hc⟩ := h
  refine ⟨fun S τ => if (∀ i, i ∉ S → τ i = false) then
      c S * ∏ i ∈ S, (if τ i then (-1 : ℝ) else 1) else 0, ?_, ?_⟩
  · intro S hS τ
    simp [hc0 S hS]
  · intro x
    rw [hc x]
    refine Finset.sum_congr rfl fun S _ => ?_
    let τ0 : ι → Bool := fun i => if i ∈ S then x i else false
    have hτ0 : ∀ i, i ∉ S → τ0 i = false := fun i hi => by simp [τ0, hi]
    rw [Finset.sum_eq_single τ0]
    · have hind : indMono S τ0 x = 1 := by
        unfold indMono
        refine Finset.prod_eq_one fun i hi => ?_
        simp [τ0, hi]
      have hchi : ∏ i ∈ S, (if τ0 i then (-1 : ℝ) else 1) = AaronsonAmbainis.chi S x := by
        unfold AaronsonAmbainis.chi
        refine Finset.prod_congr rfl fun i hi => ?_
        simp [τ0, hi]
      dsimp only
      rw [if_pos hτ0, hind, hchi, mul_one]
    · intro τ _ hne
      dsimp only
      by_cases hτ : ∀ i, i ∉ S → τ i = false
      · obtain ⟨i, hi⟩ : ∃ i, τ i ≠ τ0 i := by
          by_contra hcon
          push_neg at hcon
          exact hne (funext hcon)
        have hiS : i ∈ S := by
          by_contra hiS
          exact hi (by rw [hτ i hiS, hτ0 i hiS])
        have hxi : x i ≠ τ i := by
          intro h'
          apply hi
          simp [τ0, hiS, h']
        have : indMono S τ x = 0 := by
          unfold indMono
          exact Finset.prod_eq_zero hiS (by simp [hxi])
        rw [this, mul_zero]
      · rw [if_neg hτ, zero_mul]
    · intro h'
      exact absurd (Finset.mem_univ τ0) h'

/-- `ℓ¹` sensitivity at a point: `∑_k |f(x) - f(x^k)| ≤ 4 d²`, from the product block
inequality with the `n` single flips (`m = 1`). -/
theorem sum_flip_le (f : (ι → Bool) → ℝ) (d : ℕ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → Bool) :
    ∑ k, |f x - f (AaronsonAmbainis.flipSet x {k})| ≤ 4 * (d : ℝ) ^ 2 := by
  have hN : ∀ i, (univ.filter fun b : ι =>
      i ∈ RowBound.disagree x ((fun k => Function.update x k (!x k)) b)).card ≤ 1 := by
    intro i
    refine (Finset.card_le_card (t := {i}) ?_).trans (by simp)
    intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, RowBound.mem_disagree] at hb
    rw [Finset.mem_singleton]
    by_contra hbi
    exact hb (by rw [Function.update_of_ne (Ne.symm hbi)])
  have hNc : ((1 : ℕ) : ℝ) * (1 - Real.cos (Real.pi / ((1 : ℕ) : ℝ))) ≤ 2 := by
    simp only [Nat.cast_one, div_one, Real.cos_pi]; norm_num
  have key := product_block_inequality d f hf hd x
    (fun k => Function.update x k (!x k)) 1 1 one_pos hN hNc
  simp only [update_not_eq_flipSet, Nat.cast_one, one_pow, mul_one] at key
  exact key

theorem sum_pincr_unif_le (f : (ι → Bool) → ℝ) (d : ℕ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) : ∑ k, pincr unif f k ≤ 2 * (d : ℝ) ^ 2 := by
  simp only [pincr_unif]
  rw [Finset.sum_comm]
  calc ∑ x, ∑ k, 1 / 2 ^ Fintype.card ι * (1 / 2) *
        |f x - f (AaronsonAmbainis.flipSet x {k})|
      = ∑ x, 1 / 2 ^ Fintype.card ι * (1 / 2) *
          ∑ k, |f x - f (AaronsonAmbainis.flipSet x {k})| := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [Finset.mul_sum]
    _ ≤ ∑ x : ι → Bool, 1 / 2 ^ Fintype.card ι * (1 / 2) * (4 * (d : ℝ) ^ 2) := by
        refine Finset.sum_le_sum fun x _ => ?_
        exact mul_le_mul_of_nonneg_left (sum_flip_le f d hf hd x) (by positivity)
    _ = (∑ _x : ι → Bool, (1 : ℝ) / 2 ^ Fintype.card ι) * (2 * (d : ℝ) ^ 2) := by
        rw [Finset.sum_mul]
        exact Finset.sum_congr rfl fun _ _ => by ring
    _ = 2 * (d : ℝ) ^ 2 := by rw [sum_inv_two_pow, one_mul]

/-- **Turturean's main theorem, from the product-space chain.** Every `f` on the cube with
`|f| ≤ 1`, degree at most `d` and positive variance has a coordinate `j` with
`3 Var(f)⁵ ≤ 50000 π⁸ d¹² Inf_j(f)²`. -/
theorem mainTheorem_of_productSpace : AaronsonAmbainis.MainTheorem := by
  intro ι _ _ d f hf hdeg hV
  have hd := hasProdDegreeLE_of_hasDegreeLE f d hdeg
  have hrow := fun x => product_row_bound d f hf hd x
  choose a ha0 hacost hacov using hrow
  have hr : RealRow f a := ⟨fun x i => ha0 x i, fun x y => hacov x y⟩
  have hVp : 0 < pvar unif f := by rwa [pvar_unif]
  obtain ⟨j, hj⟩ := influence_bound unif unif_nonneg unif_sum f a hr _ hacost hVp
  refine ⟨j, ?_⟩
  rw [← pvar_unif, ← pinfl_unif]
  have hL0 : 0 ≤ ∑ k, pincr unif f k :=
    Finset.sum_nonneg fun k _ => pincr_nonneg unif unif_nonneg f k
  have hL := sum_pincr_unif_le f d hf hd
  have h2 : (∑ k, pincr unif f k) ^ 2 ≤ (2 * (d : ℝ) ^ 2) ^ 2 := pow_le_pow_left₀ hL0 hL 2
  have h3 := mul_le_mul_of_nonneg_left h2
    (by positivity : (0 : ℝ) ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 4)
  have h4 := mul_le_mul_of_nonneg_right h3 (sq_nonneg (pinfl unif f j))
  calc 3 * pvar unif f ^ 5
      ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 4 * (∑ k, pincr unif f k) ^ 2
          * pinfl unif f j ^ 2 := hj
    _ ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 4 * (2 * (d : ℝ) ^ 2) ^ 2
          * pinfl unif f j ^ 2 := h4
    _ = 50000 * Real.pi ^ 8 * (d : ℝ) ^ 12 * pinfl unif f j ^ 2 := by ring

/-- **Conjecture 6 of Aaronson–Ambainis (arXiv:0911.0996) as printed**, `Inf_i[p] ≥ (ε/d)^7`,
the Mathlib-only statement of `Conjecture.lean`, from the product-space chain. -/
theorem printedConjecture : AaronsonAmbainis.PrintedConjecture :=
  fun N d p hp hrange ε hε hvar =>
    AaronsonAmbainis.Bridge.zo_pow_of_mainTheorem mainTheorem_of_productSpace
      N d p hp hrange ε hε hvar

/-- The conjecture with the explicit bound `Inf_i[p] ≥ (8 √15 / (125 π⁴)) ε^{5/2} / d⁶`. -/
theorem explicitBound : AaronsonAmbainis.ExplicitBound := by
  intro N d p hp hrange ε hε hvar
  rw [AaronsonAmbainis.Bridge.rpow_five_halves hε.le]
  exact AaronsonAmbainis.Bridge.zo_sqrt_of_mainTheorem mainTheorem_of_productSpace
    N d p hp hrange ε hε hvar

end Nightfall.ProductSpace.CubeAA

#print axioms Nightfall.ProductSpace.CubeAA.mainTheorem_of_productSpace
#print axioms Nightfall.ProductSpace.CubeAA.printedConjecture
#print axioms Nightfall.ProductSpace.CubeAA.explicitBound
