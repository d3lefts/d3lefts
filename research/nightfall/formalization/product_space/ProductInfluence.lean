import ProductSpaceTwoSidedBridge
import ProductRowBound
import AaronsonAmbainis.Level.Integral
import AaronsonAmbainis.TwoSided.CauchySchwarz

/-!
# NIGHTFALL: a bias-free influence theorem on finite product spaces

This module ports the level-set and averaging chain of David Turturean's Lean proof of the
Aaronson–Ambainis conjecture (arXiv:2611.09773; repository
`physical-superintelligence/aaronson-ambainis`, pinned commit
`2a6ceaef872ae993708950f951989134084b851a`, files `Level/*.lean` and `Average/*.lean`) from the
uniform Boolean cube to an arbitrary finite product space `ι → α` with coordinate laws
`p i : α → ℝ`, `p i a ≥ 0`, `∑ a, p i a = 1`. Zero-mass atoms are allowed and no lower bound on
the masses enters any constant.

Inputs (all kernel-checked, no new assumptions):

* `Transfer.weighted_product_reciprocal` (product-space all-pairs inequality; merged PR #295/#298),
  which itself rests on Turturean's antipodal inequality (his Theorem 4.3);
* `RowBound.product_row_bound` (Lemma B on products: a fractional certificate row of cost at most
  `π² d²` at every point; PR #310);
* Turturean's real-variable lemmas `Level.level_integration` (his Lemma 7.3) and `abstract_cs`
  (his Lemma 5.3), which contain no cube.

Product-space analogues proved here (Turturean's numbering in brackets):

* `integrated_incr`   [Prop 7.4]  integrated all-pairs inequality with resampling increments;
* `third_moment`      [Thm 7.6]   `E[((f-r)⁺)³]·P[f ≤ r] ≤ 3 K² M`;
* `exists_median`, `weighted_sq_cube` [Lemmas 7.8, 7.9] for probability weights;
* `mean_increment`    [Thm 7.10]  `Var(f)³ ≤ 144 K⁴ L_j²` for some `j`;
* `pvar_avg`, `pinfl_avg_le`, `pincr_avg_le`, `rows_avg` [Lemma 8.1] for the conditional
  expectation over one coordinate;
* `exists_avg_set`    [Lemma 8.2];
* `influence_bound`   [Thm 8.3]   `3 Var⁵ ≤ 12500 K⁴ L² Inf_j²`;
* `product_influence` the composed theorem: if `|f| ≤ 1` and `f` has indicator-monomial degree at
  most `d`, then some coordinate has
  `3 Var(f)⁵ ≤ 12500 (π² d²)⁶ Inf_j(f)²`, i.e. `Inf_j(f) ≥ √(3/12500) Var(f)^{5/2} / (π⁶ d⁶)`.

Here `Inf_j f = ½ E_{x, b ~ p_j} (f x - f (x with x_j := b))²` is the Efron–Stein influence
`E[Var(f | x_{-j})]`, `L_j f = E_{x,b} |f x - f (x with x_j := b)|`, and expectations are under the
product law. The constants differ from the cube because one-coordinate *resampling* replaces the
flip; the exponents `(5/2, 6)` are those of Turturean's Theorem 1.1 route.
-/

namespace Nightfall.ProductSpace.Influence

open Finset
open Nightfall.ProductSpace.Transfer

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-! ## 1. The product law and one-coordinate resampling -/

theorem prodMass_nonneg' (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (x : ι → α) :
    0 ≤ prodMass p x :=
  Finset.prod_nonneg fun i _ => hp i (x i)

theorem sum_prodMass (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) :
    ∑ x : ι → α, prodMass p x = 1 := by
  have h : ∑ x : ι → α, ∏ i, p i (x i) = ∏ i, ∑ a, p i a :=
    (Fintype.prod_sum (fun i (a : α) => p i a)).symm
  unfold prodMass
  rw [h]
  simp [hp1]

theorem prodMass_mul_swap (p : ι → α → ℝ) (x : ι → α) (j : ι) (b : α) :
    prodMass p x * p j b = prodMass p (Function.update x j b) * p j (x j) := by
  unfold prodMass
  have h1 : ∏ i, p i (x i) = p j (x j) * ∏ i ∈ univ.erase j, p i (x i) :=
    (Finset.mul_prod_erase univ (fun i => p i (x i)) (mem_univ j)).symm
  have h2 : ∏ i, p i (Function.update x j b i) =
      p j (Function.update x j b j) * ∏ i ∈ univ.erase j, p i (Function.update x j b i) :=
    (Finset.mul_prod_erase univ (fun i => p i (Function.update x j b i)) (mem_univ j)).symm
  have h3 : ∏ i ∈ univ.erase j, p i (Function.update x j b i) =
      ∏ i ∈ univ.erase j, p i (x i) := by
    apply Finset.prod_congr rfl
    intro i hi
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hi)]
  have h4 : Function.update x j b j = b := by simp
  rw [h1, h2, h3, h4]
  ring

/-- The involution `(x, b) ↦ (x with x_j := b, x_j)`. -/
def swapEquiv (j : ι) : (ι → α) × α ≃ (ι → α) × α where
  toFun z := (Function.update z.1 j z.2, z.1 j)
  invFun z := (Function.update z.1 j z.2, z.1 j)
  left_inv z := by
    obtain ⟨x, b⟩ := z
    simp
  right_inv z := by
    obtain ⟨x, b⟩ := z
    simp

/-- Exchangeability of a point and its one-coordinate resample. -/
theorem swap_sum (p : ι → α → ℝ) (j : ι) (G : (ι → α) → (ι → α) → ℝ) :
    ∑ x, ∑ b, prodMass p x * p j b * G x (Function.update x j b) =
      ∑ x, ∑ b, prodMass p x * p j b * G (Function.update x j b) x := by
  have e := Fintype.sum_equiv (swapEquiv (α := α) j)
    (fun z : (ι → α) × α => prodMass p z.1 * p j z.2 * G z.1 (Function.update z.1 j z.2))
    (fun z : (ι → α) × α => prodMass p z.1 * p j z.2 * G (Function.update z.1 j z.2) z.1)
    (by
      rintro ⟨x, b⟩
      have h1 : Function.update (Function.update x j b) j (x j) = x := by simp
      show prodMass p x * p j b * G x (Function.update x j b) =
        prodMass p (Function.update x j b) * p j (x j) *
          G (Function.update (Function.update x j b) j (x j)) (Function.update x j b)
      rw [h1, prodMass_mul_swap p x j b])
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type] at e
  exact e

/-- Resampling one coordinate preserves the product law. -/
theorem resample_sum (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι)
    (F : (ι → α) → ℝ) :
    ∑ x, ∑ b, prodMass p x * p j b * F (Function.update x j b) = ∑ x, prodMass p x * F x := by
  have h : ∑ x, ∑ b, prodMass p x * p j b * F (Function.update x j b) =
      ∑ x, ∑ b, prodMass p x * p j b * F x := swap_sum p j (fun _ y => F y)
  rw [h]
  apply Finset.sum_congr rfl
  intro x _
  rw [← Finset.sum_mul, ← Finset.mul_sum, hp1, mul_one]

theorem sum_b_const (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι) (x : ι → α)
    (C : ℝ) : ∑ b, prodMass p x * p j b * C = prodMass p x * C := by
  rw [← Finset.sum_mul, ← Finset.mul_sum, hp1, mul_one]

theorem sum_prodMass_coord (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι)
    (H : α → ℝ) : ∑ y, prodMass p y * H (y j) = ∑ b, p j b * H b := by
  have h : ∑ x, ∑ b, prodMass p x * p j b * H (Function.update x j b j) =
      ∑ x, prodMass p x * H (x j) := resample_sum p hp1 j (fun y => H (y j))
  rw [← h]
  have h2 : ∀ x : ι → α, ∑ b, prodMass p x * p j b * H (Function.update x j b j) =
      prodMass p x * ∑ b, p j b * H b := by
    intro x
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro b _
    have hu : Function.update x j b j = b := by simp
    rw [hu]
    ring
  rw [Finset.sum_congr rfl (fun x _ => h2 x), ← Finset.sum_mul, sum_prodMass p hp1, one_mul]

theorem replaceFromSecond_eq (z : PairSample ι α) (j : ι) :
    replaceFromSecond z j = Function.update z.1 j (z.2 j) := by
  funext i
  unfold replaceFromSecond
  by_cases h : i = j
  · subst h
    simp
  · simp [h]

/-- Two independent draws, then the second draw's `j`-th coordinate: one-coordinate resampling. -/
theorem sum_pairMass_replace (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι)
    (H : (ι → α) → α → ℝ) :
    ∑ z : PairSample ι α, pairMass p z * H z.1 (z.2 j) =
      ∑ x, ∑ b, prodMass p x * p j b * H x b := by
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro x _
  have h1 : ∀ y : ι → α, pairMass p (x, y) * H (x, y).1 ((x, y).2 j) =
      prodMass p x * (prodMass p y * H x (y j)) := by
    intro y
    rw [pairMass_eq_prodMass]
    ring
  rw [Finset.sum_congr rfl (fun y _ => h1 y), ← Finset.mul_sum,
    sum_prodMass_coord p hp1 j (H x), Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  ring

/-! ## 2. Expectation, variance, increments, influences, averaging -/

/-- Expectation under the product law. -/
noncomputable def pexp (p : ι → α → ℝ) (f : (ι → α) → ℝ) : ℝ := ∑ x, prodMass p x * f x

/-- Variance under the product law. -/
noncomputable def pvar (p : ι → α → ℝ) (f : (ι → α) → ℝ) : ℝ :=
  ∑ x, prodMass p x * (f x - pexp p f) ^ 2

/-- Mean absolute resampling increment `L_j f = E_{x, b ~ p_j} |f x - f (x_j := b)|`. -/
noncomputable def pincr (p : ι → α → ℝ) (f : (ι → α) → ℝ) (j : ι) : ℝ :=
  ∑ x, ∑ b, prodMass p x * p j b * |f x - f (Function.update x j b)|

/-- Efron–Stein influence `Inf_j f = ½ E_{x, b ~ p_j} (f x - f (x_j := b))² = E[Var(f | x_{-j})]`. -/
noncomputable def pinfl (p : ι → α → ℝ) (f : (ι → α) → ℝ) (j : ι) : ℝ :=
  ∑ x, ∑ b, prodMass p x * p j b * ((f x - f (Function.update x j b)) ^ 2 / 2)

/-- Conditional expectation over coordinate `j` (averaging out `x_j`). -/
noncomputable def pavg (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ b, p j b * f (Function.update x j b)

/-- `a x` is a fractional certificate row of the real function `f` at every point `x`. -/
def RealRow (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) : Prop :=
  (∀ x j, 0 ≤ a x j) ∧ ∀ x y, |f x - f y| ≤ ∑ j ∈ disagree x y, a x j

theorem pincr_nonneg (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ) (j : ι) :
    0 ≤ pincr p f j :=
  Finset.sum_nonneg fun x _ => Finset.sum_nonneg fun b _ =>
    mul_nonneg (mul_nonneg (prodMass_nonneg' p hp x) (hp j b)) (abs_nonneg _)

theorem pinfl_nonneg (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ) (j : ι) :
    0 ≤ pinfl p f j :=
  Finset.sum_nonneg fun x _ => Finset.sum_nonneg fun b _ =>
    mul_nonneg (mul_nonneg (prodMass_nonneg' p hp x) (hp j b))
      (div_nonneg (sq_nonneg _) (by norm_num))

theorem pvar_nonneg (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ) :
    0 ≤ pvar p f :=
  Finset.sum_nonneg fun x _ => mul_nonneg (prodMass_nonneg' p hp x) (sq_nonneg _)

theorem sum_sq_shift (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ) (c : ℝ) :
    ∑ x, prodMass p x * (f x - c) ^ 2 = pvar p f + (pexp p f - c) ^ 2 := by
  unfold pvar
  have h : ∀ x, prodMass p x * (f x - c) ^ 2 =
      prodMass p x * (f x - pexp p f) ^ 2 + (2 * (pexp p f - c)) * (prodMass p x * f x) -
        (pexp p f ^ 2 - c ^ 2) * prodMass p x := by
    intro x
    ring
  rw [Finset.sum_congr rfl (fun x _ => h x), Finset.sum_sub_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, sum_prodMass p hp1]
  rw [show (∑ x, prodMass p x * f x) = pexp p f from rfl]
  ring

theorem pvar_le_shift (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ) (c : ℝ) :
    pvar p f ≤ ∑ x, prodMass p x * (f x - c) ^ 2 := by
  rw [sum_sq_shift p hp1 f c]
  exact le_add_of_nonneg_right (sq_nonneg _)

theorem pvar_eq (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ) :
    pvar p f = ∑ x, prodMass p x * f x ^ 2 - pexp p f ^ 2 := by
  have h := sum_sq_shift p hp1 f 0
  simp only [sub_zero] at h
  linarith

/-! ## 3. Level functions and the integrated all-pairs inequality -/

/-- The level function `1_{f > t}`. -/
noncomputable def levBool (f : (ι → α) → ℝ) (t : ℝ) (x : ι → α) : Bool := decide (t < f x)

/-- The level row `a x / |f x - t|`, and the all-ones row on the level itself. -/
noncomputable def levRow (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (t : ℝ) (x : ι → α)
    (j : ι) : ℝ :=
  if f x = t then 1 else a x j / |f x - t|

theorem levRow_isProductRow (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a)
    (t : ℝ) : IsProductRow (levBool f t) (levRow f a t) := by
  constructor
  · intro x j
    unfold levRow
    split_ifs
    · norm_num
    · exact div_nonneg (hr.1 x j) (abs_nonneg _)
  · intro x y hchange
    by_cases hx : f x = t
    · have hxy : x ≠ y := by
        intro hxy
        exact hchange (by rw [hxy])
      obtain ⟨i, hi⟩ : ∃ i, x i ≠ y i := by
        by_contra hcon
        push_neg at hcon
        exact hxy (funext hcon)
      have hmem : i ∈ disagree x y := by simp [disagree, hi]
      have hsum : ∑ j ∈ disagree x y, levRow f a t x j = ((disagree x y).card : ℝ) := by
        simp [levRow, hx]
      rw [hsum]
      have hc : 1 ≤ (disagree x y).card := Finset.card_pos.mpr ⟨i, hmem⟩
      exact_mod_cast hc
    · have hgap : 0 < |f x - t| := abs_pos.mpr (sub_ne_zero.mpr hx)
      have hcross : (t < f x ∧ f y ≤ t) ∨ (f x ≤ t ∧ t < f y) := by
        by_cases h1 : t < f x
        · by_cases h2 : t < f y
          · exact (hchange (by simp [levBool, h1, h2])).elim
          · exact Or.inl ⟨h1, le_of_not_gt h2⟩
        · by_cases h2 : t < f y
          · exact Or.inr ⟨le_of_not_gt h1, h2⟩
          · exact (hchange (by simp [levBool, h1, h2])).elim
      have hdiff : |f x - t| ≤ |f x - f y| := by
        rcases hcross with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · rw [abs_of_pos (show 0 < f x - t by linarith),
            abs_of_pos (show 0 < f x - f y by linarith)]
          linarith
        · have hlt : f x < t := lt_of_le_of_ne h1 hx
          rw [abs_of_neg (show f x - t < 0 by linarith),
            abs_of_neg (show f x - f y < 0 by linarith)]
          linarith
      have hbound : |f x - t| ≤ ∑ j ∈ disagree x y, a x j := le_trans hdiff (hr.2 x y)
      simp only [levRow, if_neg hx]
      rw [← Finset.sum_div, le_div_iff₀ hgap]
      linarith

/-- Total weighted cost of a crossing pair. -/
noncomputable def pairCost (w : ι → ℝ) (a : (ι → α) → ι → ℝ) (x y : ι → α) : ℝ :=
  ∑ j ∈ disagree x y, w j * a x j * a y j

theorem pairCost_nonneg (w : ι → ℝ) (hw : ∀ j, 0 < w j) (a : (ι → α) → ι → ℝ)
    (ha : ∀ x j, 0 ≤ a x j) (x y : ι → α) : 0 ≤ pairCost w a x y :=
  Finset.sum_nonneg fun j _ => mul_nonneg (mul_nonneg (hw j).le (ha x j)) (ha y j)

theorem cross_eval (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (w : ι → ℝ) (t : ℝ) (x y : ι → α)
    (hx : t < f x) (hy : f y < t) :
    ∑ j ∈ disagree x y, w j * levRow f a t x j * levRow f a t y j =
      pairCost w a x y / ((f x - t) * (t - f y)) := by
  have hx' : f x ≠ t := ne_of_gt hx
  have hy' : f y ≠ t := ne_of_lt hy
  have hax : |f x - t| = f x - t := abs_of_pos (by linarith)
  have hay : |f y - t| = t - f y := by
    rw [abs_of_neg (show f y - t < 0 by linarith)]
    ring
  unfold pairCost
  rw [← div_div, Finset.sum_div, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  simp only [levRow, if_neg hx', if_neg hy', hax, hay]
  ring

theorem crossTerm_nonneg' (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (w : ι → ℝ) (hw : ∀ j, 0 < w j) (z : PairSample ι α) :
    0 ≤ crossTerm g lam w z := by
  unfold crossTerm
  split_ifs
  · apply inv_nonneg.mpr
    apply Finset.sum_nonneg
    intro j _
    exact mul_nonneg (mul_nonneg (hw j).le (hlam _ j)) (hlam _ j)
  · exact le_refl 0

theorem level_pointwise (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ)
    (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (w : ι → ℝ) (hw : ∀ j, 0 < w j) (t : ℝ)
    (x y : ι → α) :
    prodMass p x * prodMass p y / pairCost w a x y * (max (f x - t) 0 * max (t - f y) 0) ≤
      pairMass p (x, y) * crossTerm (levBool f t) (levRow f a t) w (x, y) := by
  have hcn : 0 ≤ crossTerm (levBool f t) (levRow f a t) w (x, y) :=
    crossTerm_nonneg' _ _ (levRow_isProductRow f a hr t).1 w hw _
  have hpm : 0 ≤ pairMass p (x, y) := pairMass_nonneg p hp (x, y)
  by_cases hx : t < f x
  · by_cases hy : f y < t
    · have hgx : levBool f t x = true := by simp [levBool, hx]
      have hgy : levBool f t y = false := by simp [levBool, not_lt.mpr hy.le, hy.le]
      have hc : crossTerm (levBool f t) (levRow f a t) w (x, y) =
          (f x - t) * (t - f y) / pairCost w a x y := by
        unfold crossTerm
        rw [if_pos (show levBool f t (x, y).1 = true ∧ levBool f t (x, y).2 = false from
          ⟨hgx, hgy⟩)]
        show (∑ j ∈ disagree x y, w j * levRow f a t x j * levRow f a t y j)⁻¹ = _
        rw [cross_eval f a w t x y hx hy, inv_div]
      rw [hc, pairMass_eq_prodMass, max_eq_left (show (0:ℝ) ≤ f x - t by linarith),
        max_eq_left (show (0:ℝ) ≤ t - f y by linarith)]
      show prodMass p x * prodMass p y / pairCost w a x y * ((f x - t) * (t - f y)) ≤
        prodMass p x * prodMass p y * ((f x - t) * (t - f y) / pairCost w a x y)
      apply le_of_eq
      ring
    · have h0 : max (t - f y) 0 = 0 := max_eq_right (by linarith [not_lt.mp hy])
      rw [h0, mul_zero, mul_zero]
      exact mul_nonneg hpm hcn
  · have h0 : max (f x - t) 0 = 0 := max_eq_right (by linarith [not_lt.mp hx])
    rw [h0, zero_mul, mul_zero]
    exact mul_nonneg hpm hcn

theorem edgeCross_lev (f : (ι → α) → ℝ) (t : ℝ) (j : ι) (z : PairSample ι α) :
    edgeCross (levBool f t) j z =
      if f (Function.update z.1 j (z.2 j)) ≤ t ∧ t < f z.1 then (1 : ℝ) else 0 := by
  unfold edgeCross
  rw [replaceFromSecond_eq]
  by_cases h1 : t < f z.1 <;> by_cases h2 : t < f (Function.update z.1 j (z.2 j))
  · simp [levBool, h1, h2, not_le.mpr h2]
  · simp [levBool, h1, h2, le_of_not_gt h2]
  · simp [levBool, h1, h2]
  · simp [levBool, h1, h2]

/-- The all-pairs inequality at a single level `t` (product-space transfer of Turturean's
antipodal inequality applied to `1_{f > t}`). -/
theorem level_sum (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (w : ι → ℝ)
    (hw : ∀ j, 0 < w j) (t : ℝ) :
    ∑ z ∈ (univ : Finset (PairSample ι α)),
        prodMass p z.1 * prodMass p z.2 / pairCost w a z.1 z.2 *
          (max (f z.1 - t) 0 * max (t - f z.2) 0) ≤
      ∑ k ∈ (univ : Finset (ι × (ι → α) × α)),
        prodMass p k.2.1 * p k.1 k.2.2 / w k.1 *
          (if f (Function.update k.2.1 k.1 k.2.2) ≤ t ∧ t < f k.2.1 then (1 : ℝ) else 0) := by
  calc _ ≤ ∑ z : PairSample ι α,
          pairMass p z * crossTerm (levBool f t) (levRow f a t) w z := by
        apply Finset.sum_le_sum
        intro z _
        exact level_pointwise p hp f a hr w hw t z.1 z.2
    _ ≤ ∑ j, (∑ z, pairMass p z * edgeCross (levBool f t) j z) / w j :=
        weighted_product_reciprocal p hp (levBool f t) (levRow f a t)
          (levRow_isProductRow f a hr t) w hw
    _ = _ := by
        rw [Fintype.sum_prod_type]
        apply Finset.sum_congr rfl
        intro j _
        have he : ∑ z : PairSample ι α, pairMass p z * edgeCross (levBool f t) j z =
            ∑ x, ∑ b, prodMass p x * p j b *
              (if f (Function.update x j b) ≤ t ∧ t < f x then (1 : ℝ) else 0) := by
          rw [← sum_pairMass_replace p hp1 j
            (fun x b => if f (Function.update x j b) ≤ t ∧ t < f x then (1 : ℝ) else 0)]
          apply Finset.sum_congr rfl
          intro z _
          rw [edgeCross_lev]
        rw [he, Fintype.sum_prod_type, Finset.sum_div]
        apply Finset.sum_congr rfl
        intro x _
        rw [Finset.sum_div]
        apply Finset.sum_congr rfl
        intro b _
        dsimp only
        ring

set_option maxHeartbeats 1000000 in
theorem integrated (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (w : ι → ℝ)
    (hw : ∀ j, 0 < w j) :
    ∑ z ∈ (univ : Finset (PairSample ι α)),
        prodMass p z.1 * prodMass p z.2 / pairCost w a z.1 z.2 *
          (max (f z.1 - f z.2) 0 ^ 3 / 6) ≤
      ∑ k ∈ (univ : Finset (ι × (ι → α) × α)),
        prodMass p k.2.1 * p k.1 k.2.2 / w k.1 *
          max (f k.2.1 - f (Function.update k.2.1 k.1 k.2.2)) 0 :=
  AaronsonAmbainis.Level.level_integration (univ : Finset (PairSample ι α))
    (univ : Finset (ι × (ι → α) × α))
    (fun z : PairSample ι α => prodMass p z.1 * prodMass p z.2 / pairCost w a z.1 z.2)
    (fun z : PairSample ι α => f z.1) (fun z : PairSample ι α => f z.2)
    (fun k : ι × (ι → α) × α => prodMass p k.2.1 * p k.1 k.2.2 / w k.1)
    (fun k : ι × (ι → α) × α => f (Function.update k.2.1 k.1 k.2.2))
    (fun k : ι × (ι → α) × α => f k.2.1)
    (fun t => level_sum p hp hp1 f a hr w hw t)

theorem posPart_incr (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) :
    ∑ x, ∑ b, prodMass p x * p j b * max (f x - f (Function.update x j b)) 0 =
      pincr p f j / 2 := by
  have hs : ∑ x, ∑ b, prodMass p x * p j b * max (f x - f (Function.update x j b)) 0 =
      ∑ x, ∑ b, prodMass p x * p j b * max (f (Function.update x j b) - f x) 0 :=
    swap_sum p j (fun u v => max (f u - f v) 0)
  have hsum : ∑ x, ∑ b, prodMass p x * p j b * max (f x - f (Function.update x j b)) 0 +
      ∑ x, ∑ b, prodMass p x * p j b * max (f (Function.update x j b) - f x) 0 =
      pincr p f j := by
    unfold pincr
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro x _
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro b _
    rw [← mul_add]
    congr 1
    rcases le_total 0 (f x - f (Function.update x j b)) with h | h
    · rw [max_eq_left h, max_eq_right (show f (Function.update x j b) - f x ≤ 0 by linarith),
        abs_of_nonneg h]
      ring
    · rw [max_eq_right h, max_eq_left (show (0:ℝ) ≤ f (Function.update x j b) - f x by linarith),
        abs_of_nonpos h]
      ring
  rw [← hs] at hsum
  linarith

/-- Integrated all-pairs inequality on a finite product space (Turturean's Proposition 7.4 with
one-coordinate resampling in place of the flip). -/
theorem integrated_incr (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (w : ι → ℝ)
    (hw : ∀ j, 0 < w j) :
    ∑ x, ∑ y, prodMass p x * prodMass p y / pairCost w a x y * (max (f x - f y) 0 ^ 3 / 6) ≤
      ∑ j, pincr p f j / (2 * w j) := by
  have h := integrated p hp hp1 f a hr w hw
  have hL : ∑ z ∈ (univ : Finset (PairSample ι α)),
        prodMass p z.1 * prodMass p z.2 / pairCost w a z.1 z.2 *
          (max (f z.1 - f z.2) 0 ^ 3 / 6) =
      ∑ x, ∑ y, prodMass p x * prodMass p y / pairCost w a x y *
          (max (f x - f y) 0 ^ 3 / 6) :=
    Fintype.sum_prod_type (fun z : (ι → α) × (ι → α) =>
      prodMass p z.1 * prodMass p z.2 / pairCost w a z.1 z.2 * (max (f z.1 - f z.2) 0 ^ 3 / 6))
  have hR : ∑ k ∈ (univ : Finset (ι × (ι → α) × α)),
        prodMass p k.2.1 * p k.1 k.2.2 / w k.1 *
          max (f k.2.1 - f (Function.update k.2.1 k.1 k.2.2)) 0 =
      ∑ j, pincr p f j / (2 * w j) := by
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro j _
    rw [Fintype.sum_prod_type]
    have h3 : ∑ x, ∑ b, prodMass p x * p j b / w j * max (f x - f (Function.update x j b)) 0 =
        (∑ x, ∑ b, prodMass p x * p j b * max (f x - f (Function.update x j b)) 0) / w j := by
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro b _
      ring
    calc _ = ∑ x, ∑ b, prodMass p x * p j b / w j *
          max (f x - f (Function.update x j b)) 0 := rfl
      _ = _ := by
        rw [h3, posPart_incr]
        ring
  calc _ = _ := hL.symm
    _ ≤ _ := h
    _ = _ := hR

/-! ## 4. Removing the weights: the third-moment inequality -/

/-- Weighted form of Turturean's weight-removal lemma `abstract_cs` (his Lemma 5.3). -/
theorem weighted_cs {β γ κ : Type*} [Fintype κ] (O : Finset β) (N : Finset γ)
    (m : β → ℝ) (n : γ → ℝ) (hm0 : ∀ x, 0 ≤ m x) (hn0 : ∀ y, 0 ≤ n y)
    (hm : ∀ x ∈ O, 0 < m x) (hn : ∀ y ∈ N, 0 < n y)
    (A : β → κ → ℝ) (B : γ → κ → ℝ) (hA : ∀ x j, 0 ≤ A x j) (hB : ∀ y j, 0 ≤ B y j)
    (D : β → γ → Finset κ) (C : ℝ) (hC : 0 ≤ C)
    (hpos : ∀ x ∈ O, ∀ y ∈ N, ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      0 < ∑ j ∈ D x y, w j * A x j * B y j)
    (hpairs : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∑ x ∈ O, ∑ y ∈ N, m x * n y * (∑ j ∈ D x y, w j * A x j * B y j)⁻¹ ≤
        C * ∑ j, (w j)⁻¹) :
    (∑ x ∈ O, m x * (∑ j, A x j)⁻¹) * (∑ y ∈ N, n y * (∑ j, B y j)⁻¹) ≤ C := by
  have he : ∀ (x : β) (y : γ) (w : κ → ℝ), ∑ j ∈ D x y, w j * (A x j / m x) * (B y j / n y) =
      (∑ j ∈ D x y, w j * A x j * B y j) / (m x * n y) := by
    intro x y w
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    ring
  have key := AaronsonAmbainis.abstract_cs O N (fun x j => A x j / m x) (fun y j => B y j / n y)
    (fun x j => div_nonneg (hA x j) (hm0 x)) (fun y j => div_nonneg (hB y j) (hn0 y)) D C hC
    (by
      intro x hx y hy w hw
      beta_reduce
      rw [he x y w]
      exact div_pos (hpos x hx y hy w hw) (mul_pos (hm x hx) (hn y hy)))
    (by
      intro w hw
      refine le_trans (le_of_eq ?_) (hpairs w hw)
      apply Finset.sum_congr rfl
      intro x _
      apply Finset.sum_congr rfl
      intro y _
      beta_reduce
      rw [he x y w, inv_div]
      ring)
  refine le_trans (le_of_eq ?_) key
  congr 1
  · apply Finset.sum_congr rfl
    intro x _
    beta_reduce
    rw [← Finset.sum_div, inv_div]
    ring
  · apply Finset.sum_congr rfl
    intro y _
    beta_reduce
    rw [← Finset.sum_div, inv_div]
    ring

/-- Points strictly above `r` with positive mass. -/
noncomputable def upSet (p : ι → α → ℝ) (f : (ι → α) → ℝ) (r : ℝ) : Finset (ι → α) :=
  univ.filter (fun x => r < f x ∧ 0 < prodMass p x)

/-- Points at or below `r` with positive mass. -/
noncomputable def lowSet (p : ι → α → ℝ) (f : (ι → α) → ℝ) (r : ℝ) : Finset (ι → α) :=
  univ.filter (fun y => f y ≤ r ∧ 0 < prodMass p y)

theorem factor_up (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ) (r : ℝ) :
    ∑ x, prodMass p x * max (f x - r) 0 ^ 3 =
      ∑ x ∈ upSet p f r, prodMass p x * (f x - r) ^ 3 := by
  unfold upSet
  rw [Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro x _
  split_ifs with h
  · rw [max_eq_left (show (0:ℝ) ≤ f x - r by linarith [h.1])]
  · rcases not_and_or.mp h with h1 | h1
    · rw [max_eq_right (show f x - r ≤ 0 by linarith [not_lt.mp h1])]
      ring
    · have h0 : prodMass p x = 0 := le_antisymm (not_lt.mp h1) (prodMass_nonneg' p hp x)
      rw [h0]
      ring

theorem factor_low (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (f : (ι → α) → ℝ) (r : ℝ) :
    ∑ y ∈ univ.filter (fun y => f y ≤ r), prodMass p y =
      ∑ y ∈ lowSet p f r, prodMass p y := by
  unfold lowSet
  rw [Finset.sum_filter, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro y _
  by_cases h1 : f y ≤ r
  · by_cases h2 : 0 < prodMass p y
    · simp [h1, h2]
    · have h0 : prodMass p y = 0 := le_antisymm (not_lt.mp h2) (prodMass_nonneg' p hp y)
      simp [h1, h0]
  · simp [h1]

/-- Crossing pairs have positive weighted cost (from Turturean's positivity bridge, transferred). -/
theorem pairCost_pos (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a)
    (w : ι → ℝ) (hw : ∀ j, 0 < w j) (x y : ι → α) (hxy : f y < f x) :
    0 < pairCost w a x y := by
  obtain ⟨t, ht1, ht2⟩ : ∃ t, f y < t ∧ t < f x := ⟨(f x + f y) / 2, by linarith, by linarith⟩
  have hgx : levBool f t x = true := by simp [levBool, ht2]
  have hgy : levBool f t y = false := by simp [levBool, not_lt.mpr ht1.le, ht1.le]
  have h := cross_pair_cost_pos (levBool f t) (levRow f a t) (levRow_isProductRow f a hr t) w hw
    (x, y) ⟨hgx, hgy⟩
  have h' : 0 < ∑ j ∈ disagree x y, w j * levRow f a t x j * levRow f a t y j := h
  rw [cross_eval f a w t x y ht2 ht1] at h'
  have hAB : 0 < (f x - t) * (t - f y) := mul_pos (by linarith) (by linarith)
  exact (div_pos_iff_of_pos_right hAB).mp h'

theorem final_alg {P Q K M X Y : ℝ} (hK : 0 < K) (hP0 : 0 ≤ P) (hQ0 : 0 ≤ Q)
    (hX : P / K ≤ X) (hY : Q / K ≤ Y) (hXY : X * Y ≤ 3 * M) : P * Q ≤ 3 * K ^ 2 * M := by
  have h1 : P / K * (Q / K) ≤ X * Y :=
    mul_le_mul hX hY (div_nonneg hQ0 hK.le) (le_trans (div_nonneg hP0 hK.le) hX)
  have h2 : K ^ 2 * (P / K * (Q / K)) = P * Q * (K / K) ^ 2 := by ring
  rw [div_self hK.ne', one_pow, mul_one] at h2
  have h3 : K ^ 2 * (P / K * (Q / K)) ≤ K ^ 2 * (3 * M) :=
    mul_le_mul_of_nonneg_left (h1.trans hXY) (sq_nonneg K)
  rw [h2] at h3
  linarith

/-- **Third-moment inequality on a finite product space** (Turturean's Theorem 7.6):
`E[((f - r)⁺)³] · P[f ≤ r] ≤ 3 K² M` when every point has a row of cost at most `K` and every
mean absolute resampling increment is at most `M`. -/
theorem third_moment (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (M : ℝ) (hM0 : 0 ≤ M) (hM : ∀ j, pincr p f j ≤ M) (r : ℝ) :
    (∑ x, prodMass p x * max (f x - r) 0 ^ 3) *
        (∑ y ∈ univ.filter (fun y => f y ≤ r), prodMass p y) ≤ 3 * K ^ 2 * M := by
  rw [factor_up p hp f r, factor_low p hp f r]
  have h3M : 0 ≤ 3 * K ^ 2 * M := mul_nonneg (by positivity) hM0
  by_cases hOe : (upSet p f r).Nonempty
  swap
  · rw [Finset.not_nonempty_iff_eq_empty.mp hOe, Finset.sum_empty, zero_mul]
    exact h3M
  by_cases hNe : (lowSet p f r).Nonempty
  swap
  · rw [Finset.not_nonempty_iff_eq_empty.mp hNe, Finset.sum_empty, mul_zero]
    exact h3M
  obtain ⟨x0, hx0⟩ := hOe
  obtain ⟨y0, hy0⟩ := hNe
  have memO : ∀ x, x ∈ upSet p f r ↔ r < f x ∧ 0 < prodMass p x := by
    intro x
    simp [upSet]
  have memN : ∀ y, y ∈ lowSet p f r ↔ f y ≤ r ∧ 0 < prodMass p y := by
    intro y
    simp [lowSet]
  have rowpos : ∀ x y, f x ≠ f y → 0 < ∑ j, a x j := by
    intro x y hxy
    have h1 := hr.2 x y
    have h2 : ∑ j ∈ disagree x y, a x j ≤ ∑ j, a x j :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun j _ _ => hr.1 x j)
    have h3 : 0 < |f x - f y| := abs_pos.mpr (sub_ne_zero.mpr hxy)
    linarith
  have hx0' := (memO x0).mp hx0
  have hy0' := (memN y0).mp hy0
  have hKpos : 0 < K :=
    lt_of_lt_of_le (rowpos x0 y0 (ne_of_gt (show f y0 < f x0 by linarith))) (hK x0)
  have hAx : ∀ x ∈ upSet p f r, ∀ (y : ι → α) (w : ι → ℝ),
      ∑ j ∈ disagree x y, w j * (a x j / max (f x - r) 0 ^ 3) * a y j =
        pairCost w a x y / (f x - r) ^ 3 := by
    intro x hx y w
    rw [max_eq_left (show (0:ℝ) ≤ f x - r by linarith [((memO x).mp hx).1])]
    unfold pairCost
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    ring
  have term_nonneg : ∀ (w : ι → ℝ), (∀ j, 0 < w j) → ∀ x y : ι → α,
      0 ≤ 6 * (prodMass p x * prodMass p y / pairCost w a x y * (max (f x - f y) 0 ^ 3 / 6)) := by
    intro w hw x y
    have hmn : 0 ≤ prodMass p x * prodMass p y :=
      mul_nonneg (prodMass_nonneg' p hp x) (prodMass_nonneg' p hp y)
    exact mul_nonneg (by norm_num) (mul_nonneg
      (div_nonneg hmn (pairCost_nonneg w hw a hr.1 x y))
      (div_nonneg (pow_nonneg (le_max_right _ _) 3) (by norm_num)))
  have key : (∑ x ∈ upSet p f r, prodMass p x * (∑ j, a x j / max (f x - r) 0 ^ 3)⁻¹) *
      (∑ y ∈ lowSet p f r, prodMass p y * (∑ j, a y j)⁻¹) ≤ 3 * M :=
    weighted_cs (upSet p f r) (lowSet p f r) (prodMass p) (prodMass p)
      (prodMass_nonneg' p hp) (prodMass_nonneg' p hp)
      (fun x hx => ((memO x).mp hx).2) (fun y hy => ((memN y).mp hy).2)
      (fun x j => a x j / max (f x - r) 0 ^ 3) a
      (fun x j => div_nonneg (hr.1 x j) (pow_nonneg (le_max_right _ _) 3)) hr.1
      disagree (3 * M) (by linarith)
      (by
        intro x hx y hy w hw
        beta_reduce
        rw [hAx x hx y w]
        have hxr := (memO x).mp hx
        have hyr := (memN y).mp hy
        exact div_pos (pairCost_pos f a hr w hw x y (by linarith))
          (pow_pos (by linarith) 3))
      (by
        intro w hw
        have hI := integrated_incr p hp hp1 f a hr w hw
        calc ∑ x ∈ upSet p f r, ∑ y ∈ lowSet p f r, prodMass p x * prodMass p y *
              (∑ j ∈ disagree x y, w j * (a x j / max (f x - r) 0 ^ 3) * a y j)⁻¹
            ≤ ∑ x ∈ upSet p f r, ∑ y ∈ lowSet p f r, 6 * (prodMass p x * prodMass p y /
                pairCost w a x y * (max (f x - f y) 0 ^ 3 / 6)) := by
              apply Finset.sum_le_sum
              intro x hx
              apply Finset.sum_le_sum
              intro y hy
              rw [hAx x hx y w, inv_div]
              have hxr := (memO x).mp hx
              have hyr := (memN y).mp hy
              have hS : 0 < pairCost w a x y := pairCost_pos f a hr w hw x y (by linarith)
              rw [max_eq_left (show (0:ℝ) ≤ f x - f y by linarith)]
              have hc : (f x - r) ^ 3 ≤ (f x - f y) ^ 3 :=
                pow_le_pow_left₀ (by linarith) (by linarith) 3
              have hmn : 0 ≤ prodMass p x * prodMass p y :=
                mul_nonneg (prodMass_nonneg' p hp x) (prodMass_nonneg' p hp y)
              have hd : (f x - r) ^ 3 / pairCost w a x y ≤ (f x - f y) ^ 3 / pairCost w a x y := by
                rw [div_eq_mul_inv, div_eq_mul_inv]
                exact mul_le_mul_of_nonneg_right hc (inv_nonneg.mpr hS.le)
              calc prodMass p x * prodMass p y * ((f x - r) ^ 3 / pairCost w a x y)
                  ≤ prodMass p x * prodMass p y * ((f x - f y) ^ 3 / pairCost w a x y) :=
                    mul_le_mul_of_nonneg_left hd hmn
                _ = _ := by ring
          _ ≤ ∑ x, ∑ y, 6 * (prodMass p x * prodMass p y /
                pairCost w a x y * (max (f x - f y) 0 ^ 3 / 6)) := by
              apply le_trans (Finset.sum_le_sum (fun x _ =>
                Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ (lowSet p f r))
                  (fun y _ _ => term_nonneg w hw x y)))
              exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ (upSet p f r))
                (fun x _ _ => Finset.sum_nonneg (fun y _ => term_nonneg w hw x y))
          _ = 6 * ∑ x, ∑ y, prodMass p x * prodMass p y /
                pairCost w a x y * (max (f x - f y) 0 ^ 3 / 6) := by
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.mul_sum]
          _ ≤ 6 * ∑ j, pincr p f j / (2 * w j) := mul_le_mul_of_nonneg_left hI (by norm_num)
          _ ≤ 3 * M * ∑ j, (w j)⁻¹ := by
              rw [Finset.mul_sum, Finset.mul_sum]
              apply Finset.sum_le_sum
              intro j _
              calc 6 * (pincr p f j / (2 * w j)) = (3 * pincr p f j) * (w j)⁻¹ := by ring
                _ ≤ (3 * M) * (w j)⁻¹ :=
                  mul_le_mul_of_nonneg_right (by linarith [hM j]) (inv_nonneg.mpr (hw j).le))
  have hP : (∑ x ∈ upSet p f r, prodMass p x * (f x - r) ^ 3) / K ≤
      ∑ x ∈ upSet p f r, prodMass p x * (∑ j, a x j / max (f x - r) 0 ^ 3)⁻¹ := by
    rw [Finset.sum_div]
    apply Finset.sum_le_sum
    intro x hx
    have hxr := (memO x).mp hx
    have hpos : 0 < ∑ j, a x j := rowpos x y0 (ne_of_gt (show f y0 < f x by linarith))
    rw [max_eq_left (show (0:ℝ) ≤ f x - r by linarith), ← Finset.sum_div, inv_div]
    have h3 : 0 ≤ prodMass p x * (f x - r) ^ 3 :=
      mul_nonneg (prodMass_nonneg' p hp x) (pow_nonneg (by linarith) 3)
    have hinv : 1 / K ≤ 1 / ∑ j, a x j := one_div_le_one_div_of_le hpos (hK x)
    calc prodMass p x * (f x - r) ^ 3 / K = prodMass p x * (f x - r) ^ 3 * (1 / K) := by ring
      _ ≤ prodMass p x * (f x - r) ^ 3 * (1 / ∑ j, a x j) := mul_le_mul_of_nonneg_left hinv h3
      _ = _ := by ring
  have hQ : (∑ y ∈ lowSet p f r, prodMass p y) / K ≤
      ∑ y ∈ lowSet p f r, prodMass p y * (∑ j, a y j)⁻¹ := by
    rw [Finset.sum_div]
    apply Finset.sum_le_sum
    intro y hy
    have hyr := (memN y).mp hy
    have hpos : 0 < ∑ j, a y j := rowpos y x0 (ne_of_lt (show f y < f x0 by linarith))
    have hinv : 1 / K ≤ 1 / ∑ j, a y j := one_div_le_one_div_of_le hpos (hK y)
    calc prodMass p y / K = prodMass p y * (1 / K) := by ring
      _ ≤ prodMass p y * (1 / ∑ j, a y j) :=
          mul_le_mul_of_nonneg_left hinv (prodMass_nonneg' p hp y)
      _ = _ := by ring
  have hP0 : 0 ≤ ∑ x ∈ upSet p f r, prodMass p x * (f x - r) ^ 3 := by
    apply Finset.sum_nonneg
    intro x hx
    have hxr := (memO x).mp hx
    exact mul_nonneg (prodMass_nonneg' p hp x) (pow_nonneg (by linarith) 3)
  have hQ0 : 0 ≤ ∑ y ∈ lowSet p f r, prodMass p y :=
    Finset.sum_nonneg (fun y _ => prodMass_nonneg' p hp y)
  exact final_alg hKpos hP0 hQ0 hP hQ key

/-! ## 5. Median, a power mean, and the bound for the increments -/

theorem exists_median (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ) :
    ∃ m : ℝ, 1 / 2 ≤ ∑ x ∈ univ.filter (fun x => f x ≤ m), prodMass p x ∧
      1 / 2 ≤ ∑ x ∈ univ.filter (fun x => m ≤ f x), prodMass p x := by
  have htot := sum_prodMass p hp1
  have hne : (univ : Finset (ι → α)).Nonempty := by
    by_contra h
    rw [Finset.not_nonempty_iff_eq_empty] at h
    rw [h, Finset.sum_empty] at htot
    norm_num at htot
  obtain ⟨xs, -, hxs⟩ := Finset.exists_max_image univ f hne
  have hxsS : xs ∈ univ.filter (fun x : ι → α =>
      (1 : ℝ) / 2 ≤ ∑ y ∈ univ.filter (fun y => f y ≤ f x), prodMass p y) := by
    refine Finset.mem_filter.mpr ⟨mem_univ _, ?_⟩
    rw [Finset.filter_true_of_mem (fun y _ => hxs y (mem_univ y)), htot]
    norm_num
  obtain ⟨x0, hx0S, hx0min⟩ := Finset.exists_min_image _ f ⟨xs, hxsS⟩
  refine ⟨f x0, (Finset.mem_filter.mp hx0S).2, ?_⟩
  have hsplit : ∑ x ∈ univ.filter (fun x => f x0 ≤ f x), prodMass p x +
      ∑ x ∈ univ.filter (fun x => ¬ f x0 ≤ f x), prodMass p x = ∑ x, prodMass p x :=
    Finset.sum_filter_add_sum_filter_not _ _ _
  rw [htot] at hsplit
  have hlow : ∑ x ∈ univ.filter (fun x => ¬ f x0 ≤ f x), prodMass p x ≤ 1 / 2 := by
    by_cases hT : (univ.filter (fun x : ι → α => ¬ f x0 ≤ f x)).Nonempty
    · obtain ⟨x1, hx1T, hx1max⟩ := Finset.exists_max_image _ f hT
      have hx1lt : f x1 < f x0 := not_le.mp (Finset.mem_filter.mp hx1T).2
      have heq : univ.filter (fun x : ι → α => ¬ f x0 ≤ f x) =
          univ.filter (fun x => f x ≤ f x1) := by
        ext x
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        constructor
        · intro hx
          exact hx1max x (Finset.mem_filter.mpr ⟨mem_univ x, hx⟩)
        · intro hx
          exact not_le.mpr (by linarith)
      have hnot : ¬ (1 : ℝ) / 2 ≤ ∑ y ∈ univ.filter (fun y => f y ≤ f x1), prodMass p y := by
        intro h
        have h1 := hx0min x1 (Finset.mem_filter.mpr ⟨mem_univ x1, h⟩)
        linarith
      rw [heq]
      linarith [not_le.mp hnot]
    · rw [Finset.not_nonempty_iff_eq_empty.mp hT, Finset.sum_empty]
      norm_num
  linarith

/-- `(E z²)³ ≤ (E |z|³)²` for probability weights. -/
theorem weighted_sq_cube {β : Type*} [Fintype β] (μ z : β → ℝ) (hμ : ∀ x, 0 ≤ μ x)
    (h1 : ∑ x, μ x = 1) :
    (∑ x, μ x * z x ^ 2) ^ 3 ≤ (∑ x, μ x * |z x| ^ 3) ^ 2 := by
  have hA : 0 ≤ ∑ x, μ x * z x ^ 2 :=
    Finset.sum_nonneg (fun x _ => mul_nonneg (hμ x) (sq_nonneg _))
  have h1' : (∑ x, μ x * z x ^ 2) ^ 2 ≤ (∑ x, μ x * |z x|) * (∑ x, μ x * |z x| ^ 3) :=
    Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul univ
      (fun x _ => mul_nonneg (hμ x) (abs_nonneg _))
      (fun x _ => mul_nonneg (hμ x) (pow_nonneg (abs_nonneg _) 3))
      (fun x _ => le_of_eq (by rw [← sq_abs (z x)]; ring))
  have h2' : (∑ x, μ x * |z x|) ^ 2 ≤ (∑ x, μ x) * (∑ x, μ x * z x ^ 2) :=
    Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul univ
      (fun x _ => hμ x)
      (fun x _ => mul_nonneg (hμ x) (sq_nonneg _))
      (fun x _ => le_of_eq (by rw [mul_pow, sq_abs]; ring))
  rw [h1, one_mul] at h2'
  rcases hA.eq_or_lt with h0 | hpos
  · rw [← h0]
    have h00 : (0 : ℝ) ^ 3 = 0 := by norm_num
    rw [h00]
    exact sq_nonneg _
  · have h3 : ((∑ x, μ x * z x ^ 2) ^ 2) ^ 2 ≤
        ((∑ x, μ x * |z x|) * (∑ x, μ x * |z x| ^ 3)) ^ 2 :=
      pow_le_pow_left₀ (sq_nonneg _) h1' 2
    have h4 : ((∑ x, μ x * |z x|) * (∑ x, μ x * |z x| ^ 3)) ^ 2 ≤
        (∑ x, μ x * z x ^ 2) * (∑ x, μ x * |z x| ^ 3) ^ 2 := by
      rw [mul_pow]
      exact mul_le_mul_of_nonneg_right h2' (sq_nonneg _)
    have h5 : (∑ x, μ x * z x ^ 2) * (∑ x, μ x * z x ^ 2) ^ 3 ≤
        (∑ x, μ x * z x ^ 2) * (∑ x, μ x * |z x| ^ 3) ^ 2 := by
      calc (∑ x, μ x * z x ^ 2) * (∑ x, μ x * z x ^ 2) ^ 3
          = ((∑ x, μ x * z x ^ 2) ^ 2) ^ 2 := by ring
        _ ≤ _ := h3.trans h4
    exact le_of_mul_le_mul_left h5 hpos

theorem pincr_neg (p : ι → α → ℝ) (f : (ι → α) → ℝ) (j : ι) :
    pincr p (fun x => -f x) j = pincr p f j := by
  unfold pincr
  apply Finset.sum_congr rfl
  intro x _
  apply Finset.sum_congr rfl
  intro b _
  beta_reduce
  rw [show -f x - -f (Function.update x j b) = -(f x - f (Function.update x j b)) by ring,
    abs_neg]

theorem abs_cube_le (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (M : ℝ) (hM0 : 0 ≤ M) (hM : ∀ j, pincr p f j ≤ M) (m : ℝ)
    (hlow : 1 / 2 ≤ ∑ x ∈ univ.filter (fun x => f x ≤ m), prodMass p x)
    (hup : 1 / 2 ≤ ∑ x ∈ univ.filter (fun x => m ≤ f x), prodMass p x) :
    ∑ x, prodMass p x * |f x - m| ^ 3 ≤ 12 * K ^ 2 * M := by
  have h1 := third_moment p hp hp1 f a hr K hK M hM0 hM m
  have hrn : RealRow (fun x => -f x) a := by
    refine ⟨hr.1, fun x y => ?_⟩
    have h := hr.2 x y
    beta_reduce
    rwa [show -f x - -f y = -(f x - f y) by ring, abs_neg]
  have hMn : ∀ j, pincr p (fun x => -f x) j ≤ M := by
    intro j
    rw [pincr_neg]
    exact hM j
  have h2 : (∑ x, prodMass p x * max (-f x - -m) 0 ^ 3) *
      (∑ y ∈ univ.filter (fun y => -f y ≤ -m), prodMass p y) ≤ 3 * K ^ 2 * M :=
    third_moment p hp hp1 (fun x => -f x) a hrn K hK M hM0 hMn (-m)
  have hf2 : univ.filter (fun y : ι → α => -f y ≤ -m) = univ.filter (fun y => m ≤ f y) := by
    ext y
    simp
  rw [hf2] at h2
  have hX1 : 0 ≤ ∑ x, prodMass p x * max (f x - m) 0 ^ 3 :=
    Finset.sum_nonneg (fun x _ => mul_nonneg (prodMass_nonneg' p hp x)
      (pow_nonneg (le_max_right _ _) 3))
  have hX2 : 0 ≤ ∑ x, prodMass p x * max (-f x - -m) 0 ^ 3 :=
    Finset.sum_nonneg (fun x _ => mul_nonneg (prodMass_nonneg' p hp x)
      (pow_nonneg (le_max_right _ _) 3))
  have e1 := mul_le_mul_of_nonneg_left hlow hX1
  have e2 := mul_le_mul_of_nonneg_left hup hX2
  have hsplit : ∑ x, prodMass p x * |f x - m| ^ 3 =
      ∑ x, prodMass p x * max (f x - m) 0 ^ 3 + ∑ x, prodMass p x * max (-f x - -m) 0 ^ 3 := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro x _
    rcases le_total 0 (f x - m) with h | h
    · rw [abs_of_nonneg h, max_eq_left h, max_eq_right (show -f x - -m ≤ 0 by linarith)]
      ring
    · rw [abs_of_nonpos h, max_eq_right h, max_eq_left (show (0:ℝ) ≤ -f x - -m by linarith)]
      ring
  rw [hsplit]
  linarith

theorem variance_cube_le (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (M : ℝ) (hM0 : 0 ≤ M) (hM : ∀ j, pincr p f j ≤ M) :
    pvar p f ^ 3 ≤ 144 * K ^ 4 * M ^ 2 := by
  obtain ⟨m, hlow, hup⟩ := exists_median p hp1 f
  have hE := abs_cube_le p hp hp1 f a hr K hK M hM0 hM m hlow hup
  have hpm : (∑ x, prodMass p x * (f x - m) ^ 2) ^ 3 ≤
      (∑ x, prodMass p x * |f x - m| ^ 3) ^ 2 :=
    weighted_sq_cube (prodMass p) (fun x => f x - m) (prodMass_nonneg' p hp) (sum_prodMass p hp1)
  have hv : pvar p f ≤ ∑ x, prodMass p x * (f x - m) ^ 2 := pvar_le_shift p hp1 f m
  have hv0 : 0 ≤ pvar p f := pvar_nonneg p hp f
  have hE0 : 0 ≤ ∑ x, prodMass p x * |f x - m| ^ 3 :=
    Finset.sum_nonneg (fun x _ => mul_nonneg (prodMass_nonneg' p hp x)
      (pow_nonneg (abs_nonneg _) 3))
  calc pvar p f ^ 3 ≤ (∑ x, prodMass p x * (f x - m) ^ 2) ^ 3 := pow_le_pow_left₀ hv0 hv 3
    _ ≤ (∑ x, prodMass p x * |f x - m| ^ 3) ^ 2 := hpm
    _ ≤ (12 * K ^ 2 * M) ^ 2 := pow_le_pow_left₀ hE0 hE 2
    _ = 144 * K ^ 4 * M ^ 2 := by ring

/-- **Bound for the mean absolute increments on a finite product** (Turturean's Theorem 7.10). -/
theorem mean_increment (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (hV : 0 < pvar p f) :
    ∃ j, pvar p f ^ 3 ≤ 144 * K ^ 4 * pincr p f j ^ 2 := by
  rcases isEmpty_or_nonempty ι with hι | hι
  · exfalso
    have h := variance_cube_le p hp hp1 f a hr K hK 0 le_rfl (fun j => (IsEmpty.false j).elim)
    have h3 : 0 < pvar p f ^ 3 := pow_pos hV 3
    linarith
  · obtain ⟨j, -, hj⟩ := Finset.exists_max_image univ (pincr p f) univ_nonempty
    exact ⟨j, variance_cube_le p hp hp1 f a hr K hK (pincr p f j) (pincr_nonneg p hp f j)
      (fun k => hj k (mem_univ k))⟩

/-! ## 6. Averaging over a coordinate (Turturean's Lemma 8.1 on products) -/

theorem pavg_update (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) (x : ι → α) (c : α) :
    pavg p j f (Function.update x j c) = pavg p j f x := by
  unfold pavg
  simp only [Function.update_idem]

theorem pinfl_avg_self (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) :
    pinfl p (pavg p j f) j = 0 := by
  unfold pinfl
  simp [pavg_update]

theorem pincr_avg_self (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) :
    pincr p (pavg p j f) j = 0 := by
  unfold pincr
  simp [pavg_update]

theorem pavg_sub (p : ι → α → ℝ) {j k : ι} (hkj : k ≠ j) (f : (ι → α) → ℝ) (x : ι → α)
    (b : α) :
    pavg p j f x - pavg p j f (Function.update x k b) =
      ∑ c, p j c * (f (Function.update x j c) -
        f (Function.update (Function.update x j c) k b)) := by
  unfold pavg
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro c _
  rw [Function.update_comm hkj b c x, mul_sub]

theorem transport (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j k : ι)
    (Ψ : (ι → α) → α → ℝ) :
    ∑ x, ∑ b, prodMass p x * p k b * ∑ c, p j c * Ψ (Function.update x j c) b =
      ∑ x, ∑ b, prodMass p x * p k b * Ψ x b := by
  have h1 : ∀ x, ∑ b, prodMass p x * p k b * ∑ c, p j c * Ψ (Function.update x j c) b =
      ∑ b, ∑ c, prodMass p x * p j c * (p k b * Ψ (Function.update x j c) b) := by
    intro x
    apply Finset.sum_congr rfl
    intro b _
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro c _
    ring
  have h2 : ∀ b, ∑ x, ∑ c, prodMass p x * p j c * (p k b * Ψ (Function.update x j c) b) =
      ∑ x, prodMass p x * (p k b * Ψ x b) :=
    fun b => resample_sum p hp1 j (fun y => p k b * Ψ y b)
  calc ∑ x, ∑ b, prodMass p x * p k b * ∑ c, p j c * Ψ (Function.update x j c) b
      = ∑ x, ∑ b, ∑ c, prodMass p x * p j c * (p k b * Ψ (Function.update x j c) b) :=
        Finset.sum_congr rfl (fun x _ => h1 x)
    _ = ∑ b, ∑ x, ∑ c, prodMass p x * p j c * (p k b * Ψ (Function.update x j c) b) :=
        Finset.sum_comm
    _ = ∑ b, ∑ x, prodMass p x * (p k b * Ψ x b) := Finset.sum_congr rfl (fun b _ => h2 b)
    _ = ∑ x, ∑ b, prodMass p x * (p k b * Ψ x b) := Finset.sum_comm
    _ = ∑ x, ∑ b, prodMass p x * p k b * Ψ x b := by
        apply Finset.sum_congr rfl
        intro x _
        apply Finset.sum_congr rfl
        intro b _
        ring

theorem jensen_sq {β : Type*} [Fintype β] (w Δ : β → ℝ) (hw : ∀ c, 0 ≤ w c)
    (h1 : ∑ c, w c = 1) : (∑ c, w c * Δ c) ^ 2 ≤ ∑ c, w c * Δ c ^ 2 := by
  have h : (∑ c, w c * Δ c) ^ 2 ≤ (∑ c, w c) * ∑ c, w c * Δ c ^ 2 :=
    Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul univ (fun c _ => hw c)
      (fun c _ => mul_nonneg (hw c) (sq_nonneg _)) (fun c _ => le_of_eq (by ring))
  rw [h1, one_mul] at h
  exact h

theorem jensen_abs {β : Type*} [Fintype β] (w Δ : β → ℝ) (hw : ∀ c, 0 ≤ w c) :
    |∑ c, w c * Δ c| ≤ ∑ c, w c * |Δ c| :=
  (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq (Finset.sum_congr rfl (fun c _ => by
    rw [abs_mul, abs_of_nonneg (hw c)])))

theorem pinfl_avg_le (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (j k : ι) (f : (ι → α) → ℝ) : pinfl p (pavg p j f) k ≤ pinfl p f k := by
  by_cases hkj : k = j
  · rw [hkj, pinfl_avg_self]
    exact pinfl_nonneg p hp f j
  · unfold pinfl
    calc ∑ x, ∑ b, prodMass p x * p k b *
          ((pavg p j f x - pavg p j f (Function.update x k b)) ^ 2 / 2)
        ≤ ∑ x, ∑ b, prodMass p x * p k b * ∑ c, p j c *
          ((f (Function.update x j c) - f (Function.update (Function.update x j c) k b)) ^ 2 / 2) := by
          apply Finset.sum_le_sum
          intro x _
          apply Finset.sum_le_sum
          intro b _
          apply mul_le_mul_of_nonneg_left _ (mul_nonneg (prodMass_nonneg' p hp x) (hp k b))
          rw [pavg_sub p hkj f x b]
          have hJ : (∑ c, p j c * (f (Function.update x j c) -
                f (Function.update (Function.update x j c) k b))) ^ 2 ≤
              ∑ c, p j c * (f (Function.update x j c) -
                f (Function.update (Function.update x j c) k b)) ^ 2 :=
            jensen_sq (p j) _ (hp j) (hp1 j)
          have hD : (∑ c, p j c * (f (Function.update x j c) -
                f (Function.update (Function.update x j c) k b)) ^ 2) / 2 =
              ∑ c, p j c * ((f (Function.update x j c) -
                f (Function.update (Function.update x j c) k b)) ^ 2 / 2) := by
            rw [Finset.sum_div]
            apply Finset.sum_congr rfl
            intro c _
            ring
          rw [← hD]
          linarith
      _ = ∑ x, ∑ b, prodMass p x * p k b * ((f x - f (Function.update x k b)) ^ 2 / 2) :=
          transport p hp1 j k (fun y b => (f y - f (Function.update y k b)) ^ 2 / 2)

theorem pincr_avg_le (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (j k : ι) (f : (ι → α) → ℝ) : pincr p (pavg p j f) k ≤ pincr p f k := by
  by_cases hkj : k = j
  · rw [hkj, pincr_avg_self]
    exact pincr_nonneg p hp f j
  · unfold pincr
    calc ∑ x, ∑ b, prodMass p x * p k b *
          |pavg p j f x - pavg p j f (Function.update x k b)|
        ≤ ∑ x, ∑ b, prodMass p x * p k b * ∑ c, p j c *
          |f (Function.update x j c) - f (Function.update (Function.update x j c) k b)| := by
          apply Finset.sum_le_sum
          intro x _
          apply Finset.sum_le_sum
          intro b _
          apply mul_le_mul_of_nonneg_left _ (mul_nonneg (prodMass_nonneg' p hp x) (hp k b))
          rw [pavg_sub p hkj f x b]
          exact jensen_abs (p j) _ (hp j)
      _ = ∑ x, ∑ b, prodMass p x * p k b * |f x - f (Function.update x k b)| :=
          transport p hp1 j k (fun y b => |f y - f (Function.update y k b)|)

/-- The averaged row: `(avgRow a) x = E_c a (x_j := c)`. -/
noncomputable def avgRow (p : ι → α → ℝ) (j : ι) (a : (ι → α) → ι → ℝ) (x : ι → α)
    (i : ι) : ℝ :=
  ∑ c, p j c * a (Function.update x j c) i

theorem disagree_update_subset (x y : ι → α) (j : ι) (c : α) :
    disagree (Function.update x j c) (Function.update y j c) ⊆ disagree x y := by
  intro i hi
  simp only [disagree, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  by_cases hij : i = j
  · rw [hij] at hi
    simp at hi
  · rwa [Function.update_of_ne hij, Function.update_of_ne hij] at hi

theorem rows_avg (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ i, a x i ≤ K) :
    RealRow (pavg p j f) (avgRow p j a) ∧ ∀ x, ∑ i, avgRow p j a x i ≤ K := by
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro x i
    unfold avgRow
    exact Finset.sum_nonneg (fun c _ => mul_nonneg (hp j c) (hr.1 _ i))
  · intro x y
    unfold pavg avgRow
    rw [← Finset.sum_sub_distrib]
    calc |∑ c, (p j c * f (Function.update x j c) - p j c * f (Function.update y j c))|
        ≤ ∑ c, |p j c * f (Function.update x j c) - p j c * f (Function.update y j c)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ c, p j c * ∑ i ∈ disagree x y, a (Function.update x j c) i := by
          apply Finset.sum_le_sum
          intro c _
          rw [← mul_sub, abs_mul, abs_of_nonneg (hp j c)]
          apply mul_le_mul_of_nonneg_left _ (hp j c)
          exact (hr.2 _ _).trans (Finset.sum_le_sum_of_subset_of_nonneg
            (disagree_update_subset x y j c) (fun i _ _ => hr.1 _ i))
      _ = ∑ i ∈ disagree x y, ∑ c, p j c * a (Function.update x j c) i := by
          simp_rw [Finset.mul_sum]
          exact Finset.sum_comm
  · intro x
    unfold avgRow
    rw [Finset.sum_comm]
    calc ∑ c, ∑ i, p j c * a (Function.update x j c) i =
          ∑ c, p j c * ∑ i, a (Function.update x j c) i := by
          apply Finset.sum_congr rfl
          intro c _
          rw [Finset.mul_sum]
      _ ≤ ∑ c, p j c * K := Finset.sum_le_sum (fun c _ => mul_le_mul_of_nonneg_left (hK _) (hp j c))
      _ = K := by rw [← Finset.sum_mul, hp1 j, one_mul]

theorem pexp_avg (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι) (f : (ι → α) → ℝ) :
    pexp p (pavg p j f) = pexp p f := by
  unfold pexp pavg
  rw [← resample_sum p hp1 j f]
  apply Finset.sum_congr rfl
  intro x _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  ring

theorem factor_b (p : ι → α → ℝ) (j : ι) (f : (ι → α) → ℝ) (x : ι → α) (C : ℝ) :
    ∑ b, prodMass p x * p j b * (f (Function.update x j b) * C) =
      prodMass p x * C * pavg p j f x := by
  unfold pavg
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  ring

/-- **Efron–Stein step**: `Var f = Var (E_j f) + Inf_j f` (Turturean's Lemma 8.1, first item). -/
theorem pvar_avg (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι) (f : (ι → α) → ℝ) :
    pvar p f = pvar p (pavg p j f) + pinfl p f j := by
  have hEf := pvar_eq p hp1 f
  have hEg := pvar_eq p hp1 (pavg p j f)
  have hexp := pexp_avg p hp1 j f
  rw [hexp] at hEg
  have hfg : ∑ x, prodMass p x * (f x * pavg p j f x) =
      ∑ x, prodMass p x * pavg p j f x ^ 2 := by
    have h : ∑ x, ∑ b, prodMass p x * p j b *
          (f (Function.update x j b) * pavg p j f (Function.update x j b)) =
        ∑ x, prodMass p x * (f x * pavg p j f x) :=
      resample_sum p hp1 j (fun y => f y * pavg p j f y)
    rw [← h]
    apply Finset.sum_congr rfl
    intro x _
    simp only [pavg_update]
    rw [factor_b]
    ring
  have hinfl : pinfl p f j =
      ∑ x, prodMass p x * f x ^ 2 - ∑ x, prodMass p x * (f x * pavg p j f x) := by
    unfold pinfl
    have e1 : ∀ x, ∑ b, prodMass p x * p j b * ((f x - f (Function.update x j b)) ^ 2 / 2) =
        (∑ b, prodMass p x * p j b * f x ^ 2) / 2 -
          ∑ b, prodMass p x * p j b * (f (Function.update x j b) * f x) +
          (∑ b, prodMass p x * p j b * f (Function.update x j b) ^ 2) / 2 := by
      intro x
      rw [Finset.sum_div, Finset.sum_div, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro b _
      ring
    rw [Finset.sum_congr rfl (fun x _ => e1 x), Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.sum_div, ← Finset.sum_div]
    have hA : ∑ x, ∑ b, prodMass p x * p j b * f x ^ 2 = ∑ x, prodMass p x * f x ^ 2 := by
      apply Finset.sum_congr rfl
      intro x _
      exact sum_b_const p hp1 j x (f x ^ 2)
    have hC : ∑ x, ∑ b, prodMass p x * p j b * f (Function.update x j b) ^ 2 =
        ∑ x, prodMass p x * f x ^ 2 := resample_sum p hp1 j (fun y => f y ^ 2)
    have hB : ∑ x, ∑ b, prodMass p x * p j b * (f (Function.update x j b) * f x) =
        ∑ x, prodMass p x * (f x * pavg p j f x) := by
      apply Finset.sum_congr rfl
      intro x _
      rw [factor_b]
      ring
    rw [hA, hC, hB]
    ring
  linarith

/-- Averaging over a set of coordinates (Turturean's Lemma 8.2 on products). -/
theorem exists_avg_set (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ i, a x i ≤ K) (R : Finset ι) :
    ∃ (g : (ι → α) → ℝ) (b : (ι → α) → ι → ℝ), RealRow g b ∧ (∀ x, ∑ i, b x i ≤ K) ∧
      pvar p f ≤ pvar p g + ∑ j ∈ R, pinfl p f j ∧
      (∀ k, pinfl p g k ≤ pinfl p f k) ∧ (∀ k, pincr p g k ≤ pincr p f k) ∧
      (∀ j ∈ R, pincr p g j = 0) := by
  induction R using Finset.induction_on with
  | empty =>
    exact ⟨f, a, hr, hK, by simp, fun k => le_rfl, fun k => le_rfl,
      fun j hj => by simp at hj⟩
  | @insert j R hjR ih =>
    obtain ⟨g, b, hgb, hbK, hvar, hinf, hinc, hzero⟩ := ih
    obtain ⟨hrow', hK'⟩ := rows_avg p hp hp1 j g b hgb K hbK
    refine ⟨pavg p j g, avgRow p j b, hrow', hK', ?_, ?_, ?_, ?_⟩
    · rw [Finset.sum_insert hjR]
      have h1 := pvar_avg p hp1 j g
      have h2 := hinf j
      linarith
    · intro k
      exact (pinfl_avg_le p hp hp1 j k g).trans (hinf k)
    · intro k
      exact (pincr_avg_le p hp hp1 j k g).trans (hinc k)
    · intro i hi
      rcases Finset.mem_insert.mp hi with h | h
      · rw [h]
        exact pincr_avg_self p j g
      · exact le_antisymm ((pincr_avg_le p hp hp1 j i g).trans (le_of_eq (hzero i h)))
          (pincr_nonneg p hp _ i)

/-! ## 7. The influence bound -/

/-- **Influence bound on a finite product space** (Turturean's Theorem 8.3): if `f` has a row of
cost at most `K` at every point and `Var f > 0`, some coordinate has
`3 Var(f)⁵ ≤ 12500 K⁴ L(f)² Inf_j(f)²`, where `L(f) = ∑_k L_k(f)`. -/
theorem influence_bound (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (hV : 0 < pvar p f) :
    ∃ j, 3 * pvar p f ^ 5 ≤ 12500 * K ^ 4 * (∑ k, pincr p f k) ^ 2 * pinfl p f j ^ 2 := by
  obtain ⟨j0, hj0⟩ := mean_increment p hp hp1 f a hr K hK hV
  have hL0 : ∀ k, 0 ≤ pincr p f k := fun k => pincr_nonneg p hp f k
  have hj0pos : 0 < pincr p f j0 := by
    rcases (hL0 j0).eq_or_lt with h | h
    · rw [← h] at hj0
      have h3 : 0 < pvar p f ^ 3 := pow_pos hV 3
      linarith
    · exact h
  have hLpos : 0 < ∑ k, pincr p f k :=
    lt_of_lt_of_le hj0pos (Finset.single_le_sum (fun k _ => hL0 k) (mem_univ j0))
  obtain ⟨L, hLdef⟩ : ∃ L, L = ∑ k, pincr p f k := ⟨_, rfl⟩
  rw [← hLdef] at hLpos ⊢
  obtain ⟨g, b, hgb, hbK, hvar, hinf, hinc, hzero⟩ := exists_avg_set p hp hp1 f a hr K hK
    (univ.filter (fun j => 5 * L * pinfl p f j < 2 * pvar p f * pincr p f j))
  have hRsum : 5 * L *
      ∑ j ∈ univ.filter (fun j => 5 * L * pinfl p f j <
        2 * pvar p f * pincr p f j), pinfl p f j ≤ 2 * pvar p f * L := by
    rw [Finset.mul_sum]
    calc ∑ j ∈ univ.filter (fun j => 5 * L * pinfl p f j <
            2 * pvar p f * pincr p f j), 5 * L * pinfl p f j
        ≤ ∑ j ∈ univ.filter (fun j => 5 * L * pinfl p f j <
            2 * pvar p f * pincr p f j), 2 * pvar p f * pincr p f j :=
          Finset.sum_le_sum (fun j hj => le_of_lt (Finset.mem_filter.mp hj).2)
      _ = 2 * pvar p f * ∑ j ∈ univ.filter (fun j => 5 * L * pinfl p f j <
            2 * pvar p f * pincr p f j), pincr p f j := by rw [Finset.mul_sum]
      _ ≤ 2 * pvar p f * L := by
          rw [hLdef]
          exact mul_le_mul_of_nonneg_left (Finset.sum_le_sum_of_subset_of_nonneg
            (Finset.subset_univ _) (fun k _ _ => hL0 k)) (by linarith)
  have hS : ∑ j ∈ univ.filter (fun j => 5 * L * pinfl p f j <
      2 * pvar p f * pincr p f j), pinfl p f j ≤ 2 / 5 * pvar p f := by
    by_contra hcon
    push_neg at hcon
    have h1 := mul_lt_mul_of_pos_left hcon (show 0 < 5 * L by linarith)
    linarith
  have hVg : 3 / 5 * pvar p f ≤ pvar p g := by linarith
  have hVgpos : 0 < pvar p g := by linarith
  obtain ⟨j, hj⟩ := mean_increment p hp hp1 g b hgb K hbK hVgpos
  have hjpos : 0 < pincr p g j := by
    rcases (pincr_nonneg p hp g j).eq_or_lt with h | h
    · rw [← h] at hj
      have h3 : 0 < pvar p g ^ 3 := pow_pos hVgpos 3
      linarith
    · exact h
  have hjle : 2 * pvar p f * pincr p f j ≤ 5 * L * pinfl p f j := by
    by_contra hcon
    push_neg at hcon
    have hmem := hzero j (Finset.mem_filter.mpr ⟨mem_univ j, hcon⟩)
    linarith
  refine ⟨j, ?_⟩
  have h1 : (3 / 5 * pvar p f) ^ 3 ≤ pvar p g ^ 3 := pow_le_pow_left₀ (by linarith) hVg 3
  have h3 : pincr p g j ^ 2 ≤ pincr p f j ^ 2 := pow_le_pow_left₀ (pincr_nonneg p hp g j) (hinc j) 2
  have h4 : (2 * pvar p f * pincr p f j) ^ 2 ≤ (5 * L * pinfl p f j) ^ 2 :=
    pow_le_pow_left₀ (mul_nonneg (by linarith) (hL0 j)) hjle 2
  have hK4 : (0 : ℝ) ≤ 144 * K ^ 4 := by positivity
  have h5 : (3 / 5 * pvar p f) ^ 3 ≤ 144 * K ^ 4 * pincr p f j ^ 2 :=
    h1.trans (hj.trans (mul_le_mul_of_nonneg_left h3 hK4))
  have h6 : (0 : ℝ) ≤ 4 * pvar p f ^ 2 := by positivity
  have h7 := mul_le_mul_of_nonneg_left h5 h6
  have h8 := mul_le_mul_of_nonneg_left h4 hK4
  calc 3 * pvar p f ^ 5 = 125 / 36 * (4 * pvar p f ^ 2 * (3 / 5 * pvar p f) ^ 3) := by ring
    _ ≤ 125 / 36 * (4 * pvar p f ^ 2 * (144 * K ^ 4 * pincr p f j ^ 2)) := by linarith
    _ = 125 / 36 * (144 * K ^ 4 * (2 * pvar p f * pincr p f j) ^ 2) := by ring
    _ ≤ 125 / 36 * (144 * K ^ 4 * (5 * L * pinfl p f j) ^ 2) := by linarith
    _ = 12500 * K ^ 4 * L ^ 2 * pinfl p f j ^ 2 := by ring

theorem disagree_update_single (x : ι → α) (k : ι) (b : α) :
    disagree x (Function.update x k b) ⊆ {k} := by
  intro i hi
  simp only [disagree, Finset.mem_filter, Finset.mem_univ, true_and] at hi
  rw [Finset.mem_singleton]
  by_contra hik
  exact hi (by rw [Function.update_of_ne hik])

/-- `L(f) = ∑_k L_k(f) ≤ K` when every point has a row of cost at most `K`. -/
theorem sum_pincr_le (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) : ∑ k, pincr p f k ≤ K := by
  unfold pincr
  rw [Finset.sum_comm]
  calc ∑ x, ∑ k, ∑ b, prodMass p x * p k b * |f x - f (Function.update x k b)|
      ≤ ∑ x, prodMass p x * K := by
        apply Finset.sum_le_sum
        intro x _
        calc ∑ k, ∑ b, prodMass p x * p k b * |f x - f (Function.update x k b)|
            ≤ ∑ k, ∑ b, prodMass p x * p k b * a x k := by
              apply Finset.sum_le_sum
              intro k _
              apply Finset.sum_le_sum
              intro b _
              apply mul_le_mul_of_nonneg_left _ (mul_nonneg (prodMass_nonneg' p hp x) (hp k b))
              exact (hr.2 x _).trans ((Finset.sum_le_sum_of_subset_of_nonneg
                (disagree_update_single x k b) (fun i _ _ => hr.1 x i)).trans
                (le_of_eq (Finset.sum_singleton _ _)))
          _ = prodMass p x * ∑ k, a x k := by
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro k _
              exact sum_b_const p hp1 k x (a x k)
          _ ≤ prodMass p x * K := mul_le_mul_of_nonneg_left (hK x) (prodMass_nonneg' p hp x)
    _ = K := by rw [← Finset.sum_mul, sum_prodMass p hp1, one_mul]

/-- Influence bound with the cost alone: `3 Var(f)⁵ ≤ 12500 K⁶ Inf_j(f)²`. -/
theorem influence_cost (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) (hr : RealRow f a) (K : ℝ)
    (hK : ∀ x, ∑ j, a x j ≤ K) (hV : 0 < pvar p f) :
    ∃ j, 3 * pvar p f ^ 5 ≤ 12500 * K ^ 6 * pinfl p f j ^ 2 := by
  obtain ⟨j, hj⟩ := influence_bound p hp hp1 f a hr K hK hV
  refine ⟨j, hj.trans ?_⟩
  have hL := sum_pincr_le p hp hp1 f a hr K hK
  have hL0 : 0 ≤ ∑ k, pincr p f k := Finset.sum_nonneg (fun k _ => pincr_nonneg p hp f k)
  have h2 : (∑ k, pincr p f k) ^ 2 ≤ K ^ 2 := pow_le_pow_left₀ hL0 hL 2
  have h3 := mul_le_mul_of_nonneg_left h2 (by positivity : (0 : ℝ) ≤ 12500 * K ^ 4)
  have h4 := mul_le_mul_of_nonneg_right h3 (sq_nonneg (pinfl p f j))
  calc 12500 * K ^ 4 * (∑ k, pincr p f k) ^ 2 * pinfl p f j ^ 2
      ≤ 12500 * K ^ 4 * K ^ 2 * pinfl p f j ^ 2 := h4
    _ = 12500 * K ^ 6 * pinfl p f j ^ 2 := by ring

/-- **Bias-free influence theorem on finite products, exponents `(5/2, 6)`.**
Let `ι → α` carry a product law with coordinate masses `p i a ≥ 0`, `∑ₐ p i a = 1` (zero-mass
atoms allowed; no lower bound on the masses). If `|f| ≤ 1` everywhere and `f` is a combination of
indicator monomials `∏_{i ∈ T} 1[x_i = τ_i]` with `|T| ≤ d`, and `Var f > 0`, then some coordinate
`j` has `3 Var(f)⁵ ≤ 12500 (π² d²)⁶ Inf_j(f)²`. -/
theorem product_influence (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : RowBound.HasProdDegreeLE f d) (hV : 0 < pvar p f) :
    ∃ j, 3 * pvar p f ^ 5 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * pinfl p f j ^ 2 := by
  have hrow := fun x => RowBound.product_row_bound d f hf hd x
  choose a ha0 hacost hacov using hrow
  have hr : RealRow f a := ⟨fun x i => ha0 x i, fun x y => hacov x y⟩
  exact influence_cost p hp hp1 f a hr _ hacost hV

end Nightfall.ProductSpace.Influence
