import ActualSourceEfronStein

/-!
# Q3 finite original-source conditional Efron--Stein (from existing library)

This is the missing Poincare remainder step for the #807 hybrid argument,
proved by reusing the all-degree original-source Efron--Stein theorem on
each fixed fair configuration, then integrating with its true fair
weights. No new axiom or spectral assumption is introduced.

The original-source law is p on a common finite alphabet, coordinate
laws are heterogeneous and zero-mass atoms are allowed. The fair-block
weight ρ is any finite nonnegative measure (normalization not needed).
This statement still needs connecting to SourceTotalVariance's
full-source layout, and does not establish #807's fair-cubic C<220 theorem.
-/

namespace Nightfall.CubicQ3.ConditionalPoincare

open Finset
open Nightfall.Observability.ActualSourceEfronStein
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

/-- All-degree original-law Efron--Stein applied pointwise in an independent
fair block, with the conditional remainder integrated exactly. -/
theorem conditional_original_source_efron_stein
    {ι α β : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Fintype β]
    (p : ι → α → ℝ) (ρ : β → ℝ)
    (f : (ι → α) → β → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hρ : ∀ x, 0 ≤ ρ x) :
    (∑ x : β, ρ x * sourceVariance p (fun a => f a x)) ≤
      (∑ i : ι, ∑ x : β,
        ρ x * sourceInfluence p (fun a => f a x) i) := by
  calc
    (∑ x : β, ρ x * sourceVariance p (fun a => f a x)) ≤
        (∑ x : β, ρ x * (∑ i : ι,
          sourceInfluence p (fun a => f a x) i)) := by
        apply Finset.sum_le_sum
        intro x _
        exact mul_le_mul_of_nonneg_left
          (original_source_all_degree_efron_stein p hp hp1
            (fun a => f a x)) (hρ x)
    _ = (∑ x : β, ∑ i : ι,
          ρ x * sourceInfluence p (fun a => f a x) i) := by
        apply Finset.sum_congr rfl
        intro x _
        rw [Finset.mul_sum]
    _ = (∑ i : ι, ∑ x : β,
        ρ x * sourceInfluence p (fun a => f a x) i) := Finset.sum_comm

end Nightfall.CubicQ3.ConditionalPoincare
