import ActualProductSoftStarEnergy

/-!
# Exact energy of a true-source weighted centered pair star

This module derives an energy partition from the finite original
product law and exact orthogonality of distinct *original* neighbor
coordinates. It does not assume an outside energy oracle or a
positive atom floor.

No global Q2 terminal inequality, greedy matching amplitudes,
fourth-moment closure, or source-f Efron–Stein decomposition is
claimed by these declarations.
-/

namespace Nightfall.Observability.ActualProductSoftStarParseval

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductPairSector
open Nightfall.Observability.ActualProductSoftStarEnergy

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Algebraic energy partition for any finite set of original-law
pairwise orthogonal scalar functions; no probability assumptions
are needed beyond the supplied literal source mass. -/
theorem actual_source_pairwise_orthogonal_energy
    {β : Type*} [Fintype β]
    (p : ι → α → ℝ)
    (F : β → (ι → α) → ℝ)
    (hcross : ∀ j k : β, j ≠ k →
      (∑ x : ι → α,
        originalMass p x * (F j x * F k x)) = 0) :
    (∑ x : ι → α, originalMass p x *
      (∑ j : β, F j x)^2) =
    ∑ j : β, ∑ x : ι → α, originalMass p x * (F j x)^2 := by
  classical
  have hsquare (x : ι → α) :
      (∑ j : β, F j x)^2 =
        ∑ j : β, ∑ k : β, F j x * F k x := by
    calc
      (∑ j : β, F j x)^2 =
        (∑ j : β, F j x) * (∑ k : β, F k x) := by ring
      _ = ∑ j : β, ∑ k : β, F j x * F k x := by
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro j _
          rw [Finset.mul_sum]
  calc
    (∑ x : ι → α, originalMass p x *
      (∑ j : β, F j x)^2) =
      ∑ x : ι → α, ∑ j : β, ∑ k : β,
        originalMass p x * (F j x * F k x) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [hsquare x]
          simp only [Finset.mul_sum]
    _ = ∑ j : β, ∑ k : β, ∑ x : ι → α,
        originalMass p x * (F j x * F k x) := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro j _
          rw [Finset.sum_comm]
    _ = ∑ j : β, ∑ x : ι → α,
        originalMass p x * (F j x)^2 := by
          apply Finset.sum_congr rfl
          intro j _
          calc
            (∑ k : β, ∑ x : ι → α,
              originalMass p x * (F j x * F k x)) =
            ∑ k : β, if k = j then
              (∑ x : ι → α,
                originalMass p x * (F j x)^2) else 0 := by
                  apply Finset.sum_congr rfl
                  intro k _
                  by_cases h : k = j
                  · subst k
                    simp only [ite_true]
                    apply Finset.sum_congr rfl
                    intro x _
                    ring
                  · simp only [if_neg h]
                    exact hcross j k (Ne.symm h)
            _ = ∑ x : ι → α,
                originalMass p x * (F j x)^2 := by simp

/-- Genuine source-star squared energy is the sum of original-law
pair energies, weighted by the **squares** of the soft coefficients.
Distinct-neighbor cross terms vanish by the preceding source-specific
lemma; no synthetic product over neighbor indices is used. -/
theorem actual_source_weighted_centered_star_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (i : ι)
    (w : ι → ℝ) (H : ι → α → α → ℝ)
    (hcenterj : ∀ j, j ≠ i →
      ∀ a : α, (∑ b : α, p j b * H j a b) = 0) :
    (∑ x : ι → α, originalMass p x *
      (∑ j : ι, if j = i then 0 else
        w j * H j (x i) (x j))^2) =
    ∑ j : ι, if j = i then 0 else
      (w j)^2 *
        (∑ a : α, ∑ b : α,
          p i a * p j b * (H j a b)^2) := by
  classical
  let F : ι → (ι → α) → ℝ := fun j x =>
    if j = i then 0 else w j * H j (x i) (x j)
  have hcross (j k : ι) (hjk : j ≠ k) :
      (∑ x : ι → α, originalMass p x *
        (F j x * F k x)) = 0 := by
    by_cases hji : j = i
    · subst j
      simp [F]
    by_cases hki : k = i
    · subst k
      simp [F]
    have hs := actual_source_distinct_pair_neighbors_orthogonal
      p hp1 i j k (Ne.symm hji) hjk (H j) (H k)
      (hcenterj j hji)
    calc
      (∑ x : ι → α, originalMass p x *
        (F j x * F k x)) =
        (w j * w k) *
          (∑ x : ι → α, originalMass p x *
            (H j (x i) (x j) * H k (x i) (x k))) := by
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro x _
              simp [F, hji, hki]
              ring
      _ = 0 := by rw [hs]; ring
  have hpart := actual_source_pairwise_orthogonal_energy p F hcross
  calc
    (∑ x : ι → α, originalMass p x *
      (∑ j : ι, if j = i then 0 else
        w j * H j (x i) (x j))^2) =
      ∑ j : ι, ∑ x : ι → α,
        originalMass p x * (F j x)^2 := hpart
    _ = ∑ j : ι, if j = i then 0 else
      (w j)^2 * (∑ a : α, ∑ b : α,
        p i a * p j b * (H j a b)^2) := by
          apply Finset.sum_congr rfl
          intro j _
          by_cases hji : j = i
          · subst j
            simp [F]
          · simp only [if_neg hji]
            calc
              (∑ x : ι → α, originalMass p x * (F j x)^2) =
              (w j)^2 *
                (∑ x : ι → α, originalMass p x *
                  (H j (x i) (x j))^2) := by
                    rw [Finset.mul_sum]
                    apply Finset.sum_congr rfl
                    intro x _
                    simp only [F, if_neg hji]
                    ring
              _ = (w j)^2 * (∑ a : α, ∑ b : α,
                    p i a * p j b * (H j a b)^2) := by
                    rw [actual_product_two_site_marginal
                      p hp1 i j (Ne.symm hji)
                        (fun a b => (H j a b)^2)]

end Nightfall.Observability.ActualProductSoftStarParseval
