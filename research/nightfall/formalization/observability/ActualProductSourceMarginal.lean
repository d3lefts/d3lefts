import ActualProductSoftNoise

/-!
# Actual finite-product coordinate marginal and centered source sector

A separate original-source projection bridge toward the Q2 soft-ownership
formalization. No synthetic independent neighbor coordinates are used.

This file proves the genuine marginal law of a coordinate observable
from the literal product mass, then specializes true source conditional
refresh to an actual centered singleton sector. It is not the pair-sector
noise eigenvalue law or terminal Q2 influence inequality.
-/

namespace Nightfall.Observability.ActualProductSourceMarginal

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise

variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

/-- Literal original-product marginal on an actual coordinate, valid
even when some coordinate masses vanish. No abstract probability
distribution or marginal axiom is supplied. -/
theorem actual_product_coordinate_marginal
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ι) (g : α → ℝ) :
    (∑ x : ι → α, originalMass p x * g (x j)) =
      ∑ a : α, p j a * g a := by
  classical
  let Q : ι → α → ℝ := fun i a =>
    if i = j then p i a * g a else p i a
  have hpoint (x : ι → α) :
      originalMass p x * g (x j) =
        ∏ i : ι, Q i (x i) := by
    have hsingle :
        (∏ i : ι, if i = j then g (x i) else (1 : ℝ)) =
          g (x j) := by
      simp
    calc
      originalMass p x * g (x j) =
        (∏ i : ι, p i (x i)) *
          (∏ i : ι, if i = j then g (x i) else (1 : ℝ)) := by
            rw [hsingle]
            rfl
      _ = ∏ i : ι,
          (p i (x i) *
            (if i = j then g (x i) else (1 : ℝ))) := by
            rw [← Finset.prod_mul_distrib]
      _ = ∏ i : ι, Q i (x i) := by
            apply Finset.prod_congr rfl
            intro i _
            by_cases hij : i = j <;> simp [Q, hij]
  have hsum (i : ι) :
      (∑ a : α, Q i a) =
        if i = j then (∑ a : α, p j a * g a) else 1 := by
    by_cases hij : i = j
    · subst i
      simp [Q]
    · simp [Q, hij, hp1 i]
  calc
    (∑ x : ι → α, originalMass p x * g (x j)) =
      ∑ x : ι → α, ∏ i : ι, Q i (x i) := by
        apply Finset.sum_congr rfl
        intro x _
        exact hpoint x
    _ = ∏ i : ι, ∑ a : α, Q i a := by
        rw [← Fintype.prod_sum]
    _ = ∏ i : ι,
        if i = j then (∑ a : α, p j a * g a) else 1 := by
        apply Finset.prod_congr rfl
        intro i _
        exact hsum i
    _ = ∑ a : α, p j a * g a := by
        simp

/-- Genuine coordinate section of a centered singleton Hoeffding
sector either survives if observed or vanishes under original-law
refresh. The source joint law is not replaced by an auxiliary stream. -/
theorem actual_centered_singleton_source_projection
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ι) (g : α → ℝ)
    (hcenter : (∑ a : α, p j a * g a) = 0)
    (S : Finset ι) (x : ι → α) :
    sourceConditional p S (fun z : ι → α => g (z j)) x =
      if j ∈ S then g (x j) else 0 := by
  classical
  by_cases hj : j ∈ S
  · simp only [if_pos hj]
    have hkeep (y : ι → α) :
        (keepSource S x y) j = x j := by
      simp [keepSource, hj]
    unfold sourceConditional
    calc
      (∑ y : ι → α,
        (originalMass p y) • g ((keepSource S x y) j)) =
        ∑ y : ι → α, originalMass p y * g (x j) := by
          apply Finset.sum_congr rfl
          intro y _
          simp [hkeep y, smul_eq_mul]
      _ = g (x j) := by
          rw [← Finset.sum_mul, originalMass_total_one p hp1, one_mul]
  · simp only [if_neg hj]
    have hkeep (y : ι → α) :
        (keepSource S x y) j = y j := by
      simp [keepSource, hj]
    unfold sourceConditional
    calc
      (∑ y : ι → α,
        (originalMass p y) • g ((keepSource S x y) j)) =
        ∑ y : ι → α, originalMass p y * g (y j) := by
          apply Finset.sum_congr rfl
          intro y _
          simp [hkeep y, smul_eq_mul]
      _ = ∑ a : α, p j a * g a :=
          actual_product_coordinate_marginal p hp1 j g
      _ = 0 := hcenter


/-- One-site retention probability, derived from the independently
certified literal product-coordinate marginal (with Bool alphabet).
This is not an assumed Bernoulli sampling oracle. -/
theorem actual_mask_one_site_probability
    (retain : ι → ℝ) (j : ι) :
    (∑ mask : ι → Bool,
       maskWeight retain mask *
         (if mask j then (1 : ℝ) else 0)) = retain j := by
  classical
  let q : ι → Bool → ℝ := fun i b =>
    if b then retain i else (1 - retain i)
  have hq1 (i : ι) : (∑ b : Bool, q i b) = 1 := by
    simp [q, Fintype.sum_bool]
  have hm := actual_product_coordinate_marginal
    q hq1 j (fun b : Bool => if b then (1 : ℝ) else 0)
  have hmass (mask : ι → Bool) :
      originalMass q mask = maskWeight retain mask := by
    rfl
  simpa only [hmass, q, Fintype.sum_bool, ite_true, ite_false,
    mul_zero, mul_one, zero_add, sub_add_cancel] using hm

/-- Correct singleton eigenaction for the actual finite-product noise
operator. This is a real original-source Hoeffding component, not an
assumed synthetic neighbor distribution. -/
theorem actual_soft_noise_centered_singleton_eigen
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (retain : ι → ℝ)
    (j : ι) (g : α → ℝ)
    (hcenter : (∑ a : α, p j a * g a) = 0)
    (x : ι → α) :
    softSourceNoise p retain (fun z : ι → α => g (z j)) x =
      retain j * g (x j) := by
  classical
  have hterm (mask : ι → Bool) :
      sourceConditional p (maskSites mask)
        (fun z : ι → α => g (z j)) x =
      if mask j then g (x j) else 0 := by
    simpa [maskSites] using
      (actual_centered_singleton_source_projection p hp1
        j g hcenter (maskSites mask) x)
  unfold softSourceNoise sourceConditionalMixture
  calc
    (∑ mask : ι → Bool, (maskWeight retain mask) •
      sourceConditional p (maskSites mask)
        (fun z : ι → α => g (z j)) x) =
      ∑ mask : ι → Bool,
        maskWeight retain mask *
          (if mask j then g (x j) else 0) := by
            apply Finset.sum_congr rfl
            intro mask _
            rw [hterm mask]
            rfl
    _ = (∑ mask : ι → Bool,
          maskWeight retain mask *
            (if mask j then (1 : ℝ) else 0)) * g (x j) := by
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro mask _
            cases h : mask j <;> simp [h]
    _ = retain j * g (x j) := by
          rw [actual_mask_one_site_probability retain j]

end Nightfall.Observability.ActualProductSourceMarginal
