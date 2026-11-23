import QuadraticWynerLabelProjection

/-!
# Source-independent Jensen transport of coordinate resampling

This finite theorem is the missing information-preserving operator for the
quadratic Wyner seed-average construction. It works with an arbitrary
nonnegative weight on a finite sample space (not necessarily a probability
law), so it can be used with the actual resampling weight
  μ(u,v) = seedMass κ u * κ j v / 2.
The mixing law π over latent labels is nonnegative and normalized.

It formalizes only the weighted Jensen / finite-Fubini part.
The separate exact coordinatewise seed pushforward into
`pinfl (P θ) g j` and the `GoodW` terminal are not claimed here.
-/

namespace Nightfall.QuadraticWynerJensenTransport

open Finset
open Nightfall.QuadraticWynerLabelProjection

/-- Weighted Jensen commutes with an arbitrary nonnegative finite outer
measure. Exact, even when some latent or sample atoms have zero mass.
This is the source-independent influence comparison before pushing a
component seed resampling back to its original product law. -/
theorem finite_weighted_jensen_transport
    {Θ Ω : Type*} [Fintype Θ] [Fintype Ω]
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (μ : Ω → ℝ) (hμ0 : ∀ ω, 0 ≤ μ ω)
    (D : Θ → Ω → ℝ) :
    (∑ ω, μ ω * (∑ θ, π θ * D θ ω) ^ 2) ≤
      ∑ θ, π θ * (∑ ω, μ ω * (D θ ω) ^ 2) := by
  classical
  calc
    (∑ ω, μ ω * (∑ θ, π θ * D θ ω) ^ 2) ≤
        ∑ ω, μ ω * (∑ θ, π θ * (D θ ω) ^ 2) := by
          apply Finset.sum_le_sum
          intro ω _
          exact mul_le_mul_of_nonneg_left
            (weighted_square_jensen π hπ0 hπ1 (fun θ => D θ ω))
            (hμ0 ω)
    _ = ∑ ω, ∑ θ, π θ * (μ ω * (D θ ω) ^ 2) := by
          apply Finset.sum_congr rfl
          intro ω _
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl (fun θ _ => by ring)
    _ = ∑ θ, ∑ ω, π θ * (μ ω * (D θ ω) ^ 2) :=
          Finset.sum_comm
    _ = ∑ θ, π θ * (∑ ω, μ ω * (D θ ω) ^ 2) := by
          apply Finset.sum_congr rfl
          intro θ _
          exact (Finset.mul_sum).symm

end Nightfall.QuadraticWynerJensenTransport

#print axioms Nightfall.QuadraticWynerJensenTransport.finite_weighted_jensen_transport
