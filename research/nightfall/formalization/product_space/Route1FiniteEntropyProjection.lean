import Mathlib

/-! Finite Shannon projection inequality for product-component mixtures.
Uses the same negMulLog convention as Route1WynerGeneral. No data-processing
or conditional entropy theorem is assumed. -/
open Finset Real
namespace Nightfall.Route1FiniteEntropyProjection

variable {X Y W : Type*} [Fintype X] [Fintype Y] [Fintype W]

noncomputable def H {T : Type*} [Fintype T] (p : T → ℝ) : ℝ :=
  ∑ t, negMulLog (p t)

/-- Entropy of a product of two normalized finite laws. -/
theorem product_entropy (u : X → ℝ) (v : Y → ℝ)
    (hu : ∑ x, u x = 1) (hv : ∑ y, v y = 1) :
    H (fun z : X × Y => u z.1 * v z.2) = H u + H v := by
  unfold H
  rw [Fintype.sum_prod_type]
  calc
    _ = ∑ x, (negMulLog (u x) + u x * ∑ y, negMulLog (v y)) := by
      apply Finset.sum_congr rfl
      intro x _
      simp only [Real.negMulLog_mul, Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum, hv, one_mul]
    _ = _ := by rw [Finset.sum_add_distrib, ← Finset.sum_mul, hu, one_mul]

/-- Homogeneous entropy concavity for an unnormalized mixture of
normalized probability vectors. Zero total mass is handled separately. -/
theorem entropy_perspective (a : W → ℝ) (v : W → Y → ℝ)
    (ha : ∀ w, 0 ≤ a w) (hv : ∀ w y, 0 ≤ v w y)
    (hv1 : ∀ w, ∑ y, v w y = 1) :
    negMulLog (∑ w, a w) + (∑ w, a w * H (v w)) ≤
      H (fun y => ∑ w, a w * v w y) := by
  classical
  let s : ℝ := ∑ w, a w
  have hs0 : 0 ≤ s := Finset.sum_nonneg fun w _ => ha w
  rcases hs0.eq_or_lt with hs | hs
  · have hz : ∀ w, a w = 0 := by
      intro w
      have hle : a w ≤ s := Finset.single_le_sum (fun w _ => ha w) (mem_univ w)
      linarith [ha w]
    simp [H, hz]
  · let q : Y → ℝ := fun y => ∑ w, (a w / s) * v w y
    have hα : ∀ w, 0 ≤ a w / s := fun w => div_nonneg (ha w) hs.le
    have hα1 : ∑ w, a w / s = 1 := by
      rw [← Finset.sum_div]
      exact div_self hs.ne'
    have hq1 : ∑ y, q y = 1 := by
      unfold q
      rw [Finset.sum_comm]
      simp only [← Finset.mul_sum, hv1, mul_one]
      exact hα1
    have hq : ∀ y, s * q y = ∑ w, a w * v w y := by
      intro y
      unfold q
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro w _
      field_simp
    have hj : ∀ y, (∑ w, (a w / s) * negMulLog (v w y)) ≤ negMulLog (q y) := by
      intro y
      simpa only [smul_eq_mul, q] using
        Real.concaveOn_negMulLog.le_map_sum (t := univ)
          (w := fun w => a w / s) (p := fun w => v w y)
          (fun w _ => hα w) hα1 (fun w _ => hv w y)
    have hp : ∀ y, (∑ w, a w * negMulLog (v w y)) ≤ s * negMulLog (q y) := by
      intro y
      have h := mul_le_mul_of_nonneg_left (hj y) hs.le
      rw [Finset.mul_sum] at h
      convert h using 1
      apply Finset.sum_congr rfl
      intro w _
      field_simp
    have hH : H (fun y => ∑ w, a w * v w y) =
        negMulLog s + s * H q := by
      unfold H
      simp only [← hq, Real.negMulLog_mul, Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum, hq1, one_mul]
    rw [hH]
    apply add_le_add_left
    unfold H
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm (f := fun w y => a w * negMulLog (v w y))]
    exact Finset.sum_le_sum fun y _ => hp y

/-- Joint entropy dominates marginal entropy plus the average other-block
component entropy. This is the Shannon projection inequality needed to
bound the actual information of a latent mixture from either block. -/
theorem joint_entropy_ge_marginal (w : W → ℝ) (u : W → X → ℝ) (v : W → Y → ℝ)
    (hw : ∀ t, 0 ≤ w t) (hu : ∀ t x, 0 ≤ u t x) (hv : ∀ t y, 0 ≤ v t y)
    (hu1 : ∀ t, ∑ x, u t x = 1) (hv1 : ∀ t, ∑ y, v t y = 1) :
    H (fun x => ∑ t, w t * u t x) + (∑ t, w t * H (v t)) ≤
      H (fun z : X × Y => ∑ t, w t * u t z.1 * v t z.2) := by
  classical
  have h := Finset.sum_le_sum (s := (univ : Finset X)) (fun x _ =>
    entropy_perspective (fun t => w t * u t x) v
      (fun t => mul_nonneg (hw t) (hu t x)) hv hv1)
  simp only [H, Finset.sum_add_distrib] at h
  unfold H
  rw [Fintype.sum_prod_type]
  have he : (∑ x : X, ∑ t : W, w t * u t x * H (v t)) =
      ∑ t : W, w t * H (v t) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro t _
    rw [← Finset.sum_mul, ← Finset.mul_sum, hu1 t, mul_one]
  change (∑ x, negMulLog (∑ t, w t * u t x)) +
    (∑ t, w t * H (v t)) ≤ _
  change (∑ x, negMulLog (∑ t, w t * u t x)) +
    (∑ x, ∑ t, w t * u t x * H (v t)) ≤ _ at h
  rw [he] at h
  exact h


/-- Data processing for a product-mixture latent, derived using the actual
joint and marginal entropy formulas, rather than assuming monotonicity. -/
theorem product_mixture_information_ge_marginal
    (w : W → ℝ) (u : W → X → ℝ) (v : W → Y → ℝ)
    (hw : ∀ t, 0 ≤ w t) (hu : ∀ t x, 0 ≤ u t x) (hv : ∀ t y, 0 ≤ v t y)
    (hu1 : ∀ t, ∑ x, u t x = 1) (hv1 : ∀ t, ∑ y, v t y = 1) :
    H (fun x => ∑ t, w t * u t x) - (∑ t, w t * H (u t)) ≤
      H (fun z : X × Y => ∑ t, w t * u t z.1 * v t z.2) -
        (∑ t, w t * H (fun z : X × Y => u t z.1 * v t z.2)) := by
  have h := joint_entropy_ge_marginal w u v hw hu hv hu1 hv1
  have he : (∑ t, w t * H (fun z : X × Y => u t z.1 * v t z.2)) =
      (∑ t, w t * H (u t)) + ∑ t, w t * H (v t) := by
    simp only [product_entropy _ _ (hu1 _) (hv1 _), mul_add, Finset.sum_add_distrib]
  rw [he]
  linarith


/-- Product-rule expansion for negMulLog, valid even at zero atoms. -/
theorem negMulLog_prod {I : Type*} [DecidableEq I] (s : Finset I) (f : I → ℝ) :
    negMulLog (∏ i ∈ s, f i) =
      ∑ j ∈ s, ∏ i ∈ s, if i = j then negMulLog (f i) else f i := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.prod_insert ha, Real.negMulLog_mul, ih, Finset.sum_insert ha]
      have h1 : (∏ i ∈ insert a s, if i = a then negMulLog (f i) else f i) =
          negMulLog (f a) * ∏ i ∈ s, f i := by
        rw [Finset.prod_insert ha, if_pos rfl]
        congr 1
        apply Finset.prod_congr rfl
        intro i hi
        have hne : i ≠ a := fun h => ha (h ▸ hi)
        simp [hne]
      have h2 : (∑ j ∈ s, ∏ i ∈ insert a s, if i = j then negMulLog (f i) else f i) =
          f a * ∑ j ∈ s, ∏ i ∈ s, if i = j then negMulLog (f i) else f i := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j hj
        have hne : a ≠ j := fun h => ha (h.symm ▸ hj)
        rw [Finset.prod_insert ha, if_neg hne]
      rw [h1,h2]
      ring

/-- Entropy of a finite independent family is the sum of coordinate
entropies, with no positive atom assumption. -/
theorem pi_product_entropy {I A : Type*} [Fintype I] [DecidableEq I]
    [Fintype A] [DecidableEq A] (p : I → A → ℝ)
    (hp : ∀ i, ∑ a, p i a = 1) :
    H (fun z : I → A => ∏ i, p i (z i)) = ∑ i, H (p i) := by
  classical
  unfold H
  simp only [negMulLog_prod]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  rw [← Fintype.piFinset_univ, ← Finset.prod_univ_sum]
  simp only [Finset.sum_ite_irrel]
  apply Finset.prod_eq_single j
  · intro i _ hi
    simp [hi, hp i]
  · simp

/-- The actual entropy of a normalized binary law equals the fair-bit
entropy minus psi of its squared signed bias. -/
theorem binary_entropy_bias (p : Bool → ℝ) (hp : ∑ b, p b = 1) :
    H p = Real.log 2 -
      (Real.log 2 - (negMulLog ((1 + Real.sqrt ((p true - p false)^2))/2) +
        negMulLog ((1 - Real.sqrt ((p true - p false)^2))/2))) := by
  have hs : p false + p true = 1 := by simpa [Fintype.sum_bool, add_comm] using hp
  rw [Real.sqrt_sq_eq_abs]
  unfold H
  rw [Fintype.sum_bool]
  rcases le_total (p false) (p true) with h | h
  · rw [abs_of_nonneg (sub_nonneg.mpr h)]
    have he1 : (1 + (p true - p false))/2 = p true := by linarith
    have he2 : (1 - (p true - p false))/2 = p false := by linarith
    rw [he1,he2]
    ring
  · rw [abs_of_nonpos (sub_nonpos.mpr h)]
    have he1 : (1 + -(p true - p false))/2 = p false := by linarith
    have he2 : (1 - -(p true - p false))/2 = p true := by linarith
    rw [he1,he2]
    ring

end Nightfall.Route1FiniteEntropyProjection

#print axioms Nightfall.Route1FiniteEntropyProjection.product_entropy
#print axioms Nightfall.Route1FiniteEntropyProjection.entropy_perspective
#print axioms Nightfall.Route1FiniteEntropyProjection.joint_entropy_ge_marginal

#print axioms Nightfall.Route1FiniteEntropyProjection.product_mixture_information_ge_marginal

#print axioms Nightfall.Route1FiniteEntropyProjection.negMulLog_prod
#print axioms Nightfall.Route1FiniteEntropyProjection.pi_product_entropy
#print axioms Nightfall.Route1FiniteEntropyProjection.binary_entropy_bias
