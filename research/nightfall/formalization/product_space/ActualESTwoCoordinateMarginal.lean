import ActualESPairMatchingBridge

/-!
# Genuine source two-coordinate law and canonical pair energy

For two distinct original coordinates i,j, the actual finite product
law has the exact (p_i ⊗ p_j) marginal, including zero-probability atoms.
Consequently the L2 energy of a canonical Efron-Stein pair component
computed on the full source space equals the two-coordinate Hilbert
pair-kernel energy. Both identities are PROVED from source resampling
without an independent energy premise or synthetic copy model.

This is one source/Fubini bridge, not the full owned-neighbor
conditional distribution or final Q2 variance-influence theorem.
-/

namespace Nightfall.Observability.ActualESTwoCoordinateMarginal

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual source product measure has the genuine two-coordinate
marginal, with no positive atom-floor or additional independence axiom. -/
theorem actual_source_two_coordinate_marginal
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (i j : ι) (hij : i ≠ j)
    (F : α → α → ℝ) :
    (∑ x : ι → α, prodMass p x * F (x i) (x j)) =
      ∑ a : α, ∑ b : α,
        p i a * p j b * F a b := by
  classical
  calc
    (∑ x : ι → α, prodMass p x * F (x i) (x j)) =
      ∑ x : ι → α, ∑ a : α,
        prodMass p x * p i a * F a (x j) := by
          rw [← resample_sum p hp1 i
            (fun x => F (x i) (x j))]
          apply Finset.sum_congr rfl
          intro x _
          apply Finset.sum_congr rfl
          intro a _
          simp [Function.update_of_ne hij.symm]
    _ = ∑ a : α, p i a *
          (∑ x : ι → α, prodMass p x * F a (x j)) := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          ring
    _ = ∑ a : α, p i a *
          (∑ b : α, p j b * F a b) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [sum_prodMass_coord p hp1 j (F a)]
    _ = ∑ a : α, ∑ b : α,
          p i a * p j b * F a b := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

/-- L2 energy of an actual canonical source pair, not a supplied
energy object, is exactly its original two-coordinate kernel energy. -/
theorem actual_source_pair_component_energy_eq_two_coord
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i j : ι) (hij : i ≠ j) :
    (∑ x : ι → α, prodMass p x *
      (esComp p ({i,j} : Finset ι) f x)^2) =
      ∑ a : α, ∑ b : α, p i a * p j b *
        (actualPairKernel p f base i j a b)^2 := by
  have hker (x : ι → α) :
      esComp p ({i,j} : Finset ι) f x =
        actualPairKernel p f base i j (x i) (x j) :=
    actual_pair_component_is_kernel p f base x i j hij
  calc
    (∑ x : ι → α, prodMass p x *
        (esComp p ({i,j} : Finset ι) f x)^2) =
      ∑ x : ι → α, prodMass p x *
        (actualPairKernel p f base i j (x i) (x j))^2 := by
          apply Finset.sum_congr rfl
          intro x _
          rw [hker x]
    _ = ∑ a : α, ∑ b : α, p i a * p j b *
        (actualPairKernel p f base i j a b)^2 :=
      actual_source_two_coordinate_marginal p hp1 i j hij
        (fun a b => (actualPairKernel p f base i j a b)^2)

end Nightfall.Observability.ActualESTwoCoordinateMarginal
