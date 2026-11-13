import ActualESOrthogonalEnergy
import ActualESOwnedEnergy

/-!
# Exact Fubini bridge: source-inner pair energy = true pair table energy

All source coordinates are integrated under their *original product law*.
Two resampling identities remove the unmatched coordinates; no
independently sampled duplicate sites are introduced.

The source expectation of an arbitrary function depending only on the
two selected distinct coordinates is exactly the two-marginal table
expectation. This gives the missing unconditional L2 energy identity
for canonical Efron–Stein pair kernels. The weights may be zero.

This is an exact equality, not an assumed energy bound, Jensen
estimate, influence certificate, or variance theorem.
-/

namespace Nightfall.Observability.ActualESPairEnergyFubini

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESOrthogonalEnergy
open Nightfall.Observability.ActualESOwnedEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact marginalization for any actual source function depending
only on two distinct coordinates. -/
theorem actual_source_two_coordinate_fubini
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (g : (ι → α) → ℝ)
    (i j : ι) (hij : i ≠ j)
    (hdep : DependsOn ({i,j} : Finset ι) g)
    (base : ι → α) :
    (∑ x : ι → α, prodMass p x * g x) =
      ∑ a : α, ∑ b : α,
        p i a * p j b *
          g (Function.update (Function.update base i a) j b) := by
  classical
  have hfixed (x : ι → α) (a b : α) :
      g (Function.update (Function.update x j b) i a) =
        g (Function.update (Function.update base i a) j b) := by
    rw [Function.update_comm hij]
    apply hdep
    intro k hk
    have hk' : k = i ∨ k = j := by simpa using hk
    rcases hk' with rfl | rfl
    · simp [hij]
    · simp
  have hres (a : α) :
      (∑ x : ι → α, prodMass p x *
        g (Function.update x i a)) =
      ∑ x : ι → α, ∑ b : α,
        prodMass p x * p j b *
          g (Function.update (Function.update x j b) i a) := by
    exact (resample_sum p hp1 j
      (fun y => g (Function.update y i a))).symm
  have hinner (a : α) :
      (∑ x : ι → α, prodMass p x *
        g (Function.update x i a)) =
      (∑ b : α, p j b *
        g (Function.update (Function.update base i a) j b)) := by
    rw [hres]
    calc
      (∑ x : ι → α, ∑ b : α,
        prodMass p x * p j b *
          g (Function.update (Function.update x j b) i a)) =
        ∑ x : ι → α, prodMass p x *
          (∑ b : α, p j b *
            g (Function.update (Function.update base i a) j b)) := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro b _
              rw [hfixed x a b]
              ring
      _ = ∑ b : α, p j b *
        g (Function.update (Function.update base i a) j b) := by
          rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]
  calc
    (∑ x : ι → α, prodMass p x * g x) =
      ∑ x : ι → α, ∑ a : α,
        prodMass p x * p i a * g (Function.update x i a) :=
      (resample_sum p hp1 i g).symm
    _ = ∑ a : α, p i a *
        (∑ x : ι → α, prodMass p x *
          g (Function.update x i a)) := by
            rw [Finset.sum_comm]
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro x _
            ring
    _ = ∑ a : α, p i a *
        (∑ b : α, p j b *
          g (Function.update (Function.update base i a) j b)) := by
            apply Finset.sum_congr rfl
            intro a _
            rw [hinner]
    _ = ∑ a : α, ∑ b : α,
        p i a * p j b *
          g (Function.update (Function.update base i a) j b) := by
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            ring

/-- The exact original-source pair energy used by the greedily owned
graph is the canonical Efron–Stein L2 energy under the FULL law.
No source pair energy budget is assumed. -/
theorem actual_source_pair_energy_eq_canonical_inner
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i j : ι) (hij : i ≠ j) :
    sourcePairEnergy p f base i j =
      sourceInner p (esComp p ({i,j} : Finset ι) f)
        (esComp p ({i,j} : Finset ι) f) := by
  classical
  let g : (ι → α) → ℝ :=
    fun x => (esComp p ({i,j} : Finset ι) f x)^2
  have hdep : DependsOn ({i,j} : Finset ι) g := by
    intro x y hxy
    exact congrArg (fun t : ℝ => t^2)
      (esComp_dependsOn p ({i,j} : Finset ι) f x y hxy)
  have h := actual_source_two_coordinate_fubini
    p hp1 g i j hij hdep base
  unfold sourcePairEnergy sourceInner
  simpa only [g, actualPairKernel, pow_two] using h.symm

end Nightfall.Observability.ActualESPairEnergyFubini
