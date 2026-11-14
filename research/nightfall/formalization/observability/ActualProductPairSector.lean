import ActualProductSourceMarginal

/-!
# Genuine product-law two-site marginal — next Q2 bridge

All mass is taken from the actual finite coordinate product, and
zero-mass atoms are allowed. This event identity is the first step
toward separately centered pair-kernel soft-refresh eigenaction.

This module does not state or assume the Q2 variance–influence theorem.
-/

namespace Nightfall.Observability.ActualProductPairSector

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourceMarginal

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual law assigns a prescribed distinct-coordinate event
exactly the product of its original coordinate masses. No
independence premise is postulated separately. -/
theorem actual_product_two_site_event
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j k : ι) (hjk : j ≠ k) (a b : α) :
    (∑ x : ι → α, originalMass p x *
      (if x j = a ∧ x k = b then (1 : ℝ) else 0)) =
      p j a * p k b := by
  classical
  let w : ι → α → ℝ := fun i v =>
    p i v *
      (if i = j then (if v = a then 1 else 0) else 1) *
      (if i = k then (if v = b then 1 else 0) else 1)
  have hJ (x : ι → α) :
      (∏ i : ι,
        if i = j then (if x i = a then (1 : ℝ) else 0) else 1) =
        (if x j = a then (1 : ℝ) else 0) := by
    simp
  have hK (x : ι → α) :
      (∏ i : ι,
        if i = k then (if x i = b then (1 : ℝ) else 0) else 1) =
        (if x k = b then (1 : ℝ) else 0) := by
    simp
  have hweight (x : ι → α) :
      (∏ i : ι, w i (x i)) =
        originalMass p x *
          (if x j = a ∧ x k = b then (1 : ℝ) else 0) := by
    simp only [w, Finset.prod_mul_distrib]
    rw [hJ x, hK x]
    unfold originalMass
    by_cases ha : x j = a <;> by_cases hb : x k = b <;>
      simp [ha, hb]
  have hsum (i : ι) :
      (∑ v : α, w i v) =
        if i = j then p j a else if i = k then p k b else 1 := by
    by_cases hij : i = j
    · subst i
      simp [w, hjk]
    · by_cases hik : i = k
      · subst i
        simp [w, hij]
      · simp [w, hij, hik, hp1 i]
  calc
    (∑ x : ι → α, originalMass p x *
      (if x j = a ∧ x k = b then (1 : ℝ) else 0)) =
      ∑ x : ι → α, ∏ i : ι, w i (x i) := by
        apply Finset.sum_congr rfl
        intro x _
        exact (hweight x).symm
    _ = ∏ i : ι, ∑ v : α, w i v := by
        rw [← Fintype.prod_sum]
    _ = ∏ i : ι,
        (if i = j then p j a else if i = k then p k b else 1) := by
        apply Finset.prod_congr rfl
        intro i _
        exact hsum i
    _ = (∏ i : ι,
          (if i = j then p j a else 1) *
            (if i = k then p k b else 1)) := by
        apply Finset.prod_congr rfl
        intro i _
        by_cases hij : i = j
        · subst i
          simp [hjk]
        · simp [hij]
    _ = (∏ i : ι, if i = j then p j a else 1) *
        (∏ i : ι, if i = k then p k b else 1) := by
        rw [Finset.prod_mul_distrib]
    _ = p j a * p k b := by simp


/-- Exact two-coordinate marginal for an arbitrary source pair kernel.
This is derived from the point-event theorem rather than supplied
as an independence oracle or as a positive-mass conditional law. -/
theorem actual_product_two_site_marginal
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j k : ι) (hjk : j ≠ k)
    (H : α → α → ℝ) :
    (∑ x : ι → α, originalMass p x * H (x j) (x k)) =
      ∑ a : α, ∑ b : α, p j a * p k b * H a b := by
  classical
  have hcollapse (x : ι → α) :
      (∑ a : α, ∑ b : α,
        if x j = a ∧ x k = b then H a b else 0) =
      H (x j) (x k) := by
    have hinner (a : α) :
        (∑ b : α,
          if x j = a ∧ x k = b then H a b else 0) =
        if x j = a then H a (x k) else 0 := by
      by_cases h : x j = a <;> simp [h]
    calc
      (∑ a : α, ∑ b : α,
        if x j = a ∧ x k = b then H a b else 0) =
          ∑ a : α, if x j = a then H a (x k) else 0 := by
          apply Finset.sum_congr rfl
          intro a _
          exact hinner a
      _ = H (x j) (x k) := by simp
  calc
    (∑ x : ι → α, originalMass p x * H (x j) (x k)) =
      ∑ x : ι → α, ∑ a : α, ∑ b : α,
        originalMass p x *
          (if x j = a ∧ x k = b then H a b else 0) := by
        apply Finset.sum_congr rfl
        intro x _
        calc
          originalMass p x * H (x j) (x k) =
            originalMass p x *
              (∑ a : α, ∑ b : α,
                if x j = a ∧ x k = b then H a b else 0) := by
                rw [hcollapse x]
          _ = ∑ a : α, ∑ b : α,
                originalMass p x *
                  (if x j = a ∧ x k = b then H a b else 0) := by
                simp only [Finset.mul_sum]
    _ = ∑ a : α, ∑ b : α, ∑ x : ι → α,
          originalMass p x *
            (if x j = a ∧ x k = b then H a b else 0) := by
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro a _
        rw [Finset.sum_comm]
    _ = ∑ a : α, ∑ b : α, p j a * p k b * H a b := by
        apply Finset.sum_congr rfl
        intro a _
        apply Finset.sum_congr rfl
        intro d _
        calc
          (∑ x : ι → α, originalMass p x *
            (if x j = a ∧ x k = d then H a d else 0)) =
          (∑ x : ι → α, originalMass p x *
            (if x j = a ∧ x k = d then (1 : ℝ) else 0)) *
              H a d := by
                rw [Finset.sum_mul]
                apply Finset.sum_congr rfl
                intro x _
                by_cases h : x j = a ∧ x k = d <;> simp [h]
          _ = p j a * p k d * H a d := by
                rw [actual_product_two_site_event p hp1 j k hjk a d]

end Nightfall.Observability.ActualProductPairSector
