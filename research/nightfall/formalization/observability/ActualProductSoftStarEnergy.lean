import ActualProductSoftStar

/-!
# Genuine-product source orthogonality of distinct pair neighbors

The original source law, not a synthetic independent-neighbor sampler,
annihilates cross terms of pair kernels anchored at the same coordinate.
This is the source-energy bridge required by the Q2 soft-star mechanism.

This is not a terminal Q2 variance–influence theorem. The complete
energy partition, matching cover, fourth moment and final scalar
closure are separate obligations.
-/

namespace Nightfall.Observability.ActualProductSoftStarEnergy

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourceMarginal

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Original-source orthogonality of pairs with the same owner i and
distinct actual neighbors j,k. Only the j-center of the first kernel
is needed. No atom positivity, synthetic neighbor embedding,
or independent Hilbert stream is assumed. -/
theorem actual_source_distinct_pair_neighbors_orthogonal
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (i j k : ι) (hij : i ≠ j) (hjk : j ≠ k)
    (H J : α → α → ℝ)
    (hcenterj : ∀ a : α, (∑ b : α, p j b * H a b) = 0) :
    (∑ x : ι → α,
      originalMass p x *
        (H (x i) (x j) * J (x i) (x k))) = 0 := by
  classical
  let S : Finset ι := Finset.univ.erase j
  have hiS : i ∈ S := by simp [S, hij]
  have hjS : j ∉ S := by simp [S]
  have hkS : k ∈ S := by simp [S, hjk.symm]
  let F : (ι → α) → ℝ := fun x =>
    H (x i) (x j) * J (x i) (x k)
  have hpoint (x : ι → α) : sourceConditional p S F x = 0 := by
    unfold sourceConditional
    calc
      (∑ y : ι → α, originalMass p y •
        F (keepSource S x y)) =
      ∑ y : ι → α,
        originalMass p y *
          (H (x i) (y j) * J (x i) (x k)) := by
            apply Finset.sum_congr rfl
            intro y _
            simp [F, keepSource, hiS, hjS, hkS, smul_eq_mul]
      _ = ∑ a : α, p j a *
        (H (x i) a * J (x i) (x k)) :=
          actual_product_coordinate_marginal p hp1 j
            (fun a => H (x i) a * J (x i) (x k))
      _ = (∑ a : α, p j a * H (x i) a) *
        J (x i) (x k) := by
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro a _
          ring
      _ = 0 := by rw [hcenterj (x i)]; ring
  have htower := actual_source_conditional_stationary p hp1 S F
  calc
    (∑ x : ι → α,
      originalMass p x * (H (x i) (x j) * J (x i) (x k))) =
      ∑ x : ι → α, originalMass p x * F x := by rfl
    _ = ∑ x : ι → α,
       originalMass p x * sourceConditional p S F x := htower.symm
    _ = 0 := by simp [hpoint]

end Nightfall.Observability.ActualProductSoftStarEnergy
