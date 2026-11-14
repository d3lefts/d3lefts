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

end Nightfall.Observability.ActualProductSourceMarginal
