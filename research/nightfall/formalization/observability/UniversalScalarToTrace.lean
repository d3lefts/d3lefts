import Mathlib

/-!
# NIGHTFALL universal spectral transfer: finite signed projection

This is the concrete weighted Cauchy-Schwarz transfer from real vector
resampling increments to a scalar signed projection. It works for every
finite sample and output type and arbitrary nonnegative sample weights.

It is NOT the random-sign exponential-moment theorem. It DOES NOT
establish the sharp rank-to-logarithm transfer, the posterior ANOVA
recursion, or the complete measurable-product universal theorem.
-/

namespace Nightfall.Observability.Universal

open Finset

variable {ξ κ : Type*} [Fintype ξ] [Fintype κ]

/-- Weighted squared influence of a scalar signed projection. -/
def signedEnergy (μ : ξ → ℝ) (w : ξ → κ → ℝ) (ε : κ → ℝ) : ℝ :=
  ∑ x : ξ, μ x * (∑ j : κ, ε j * w x j) ^ 2

/-- Weighted trace influence of the same vector increments. -/
def traceEnergy (μ : ξ → ℝ) (w : ξ → κ → ℝ) : ℝ :=
  ∑ x : ξ, μ x * ∑ j : κ, (w x j) ^ 2

/-- Signed projection: pointwise squared length is at most rank times
the squared Euclidean increment norm. -/
theorem signed_increment_sq_le_rank (ε : κ → ℝ)
    (hε : ∀ j, ε j ^ 2 = 1) (v : κ → ℝ) :
    (∑ j : κ, ε j * v j) ^ 2 ≤
      (Fintype.card κ : ℝ) * ∑ j : κ, (v j) ^ 2 := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ) ε v
  have hεsum : (∑ j : κ, ε j ^ 2) = (Fintype.card κ : ℝ) := by
    simp [hε]
  simpa only [hεsum] using h

/-- Actual weighted increment inequality, not an abstract vector
influence inequality assumed as a hypothesis. -/
theorem signed_energy_le_rank_trace (μ : ξ → ℝ)
    (hμ : ∀ x, 0 ≤ μ x) (w : ξ → κ → ℝ) (ε : κ → ℝ)
    (hε : ∀ j, ε j ^ 2 = 1) :
    signedEnergy μ w ε ≤ (Fintype.card κ : ℝ) * traceEnergy μ w := by
  unfold signedEnergy traceEnergy
  calc
    (∑ x : ξ, μ x * (∑ j : κ, ε j * w x j) ^ 2) ≤
        ∑ x : ξ, μ x * ((Fintype.card κ : ℝ) * ∑ j : κ, (w x j) ^ 2) := by
          apply Finset.sum_le_sum
          intro x _
          exact mul_le_mul_of_nonneg_left
            (signed_increment_sq_le_rank ε hε (w x)) (hμ x)
    _ = (Fintype.card κ : ℝ) *
        (∑ x : ξ, μ x * ∑ j : κ, (w x j) ^ 2) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          ring

/-- Given a separately established scalar lower bound, this derives
the rank-factor trace lower bound for concrete increment samples. -/
theorem exists_trace_coordinate_of_signed_scalar
    {ι : Type*} [Fintype ι]
    (μ : ι → ξ → ℝ) (hμ : ∀ i x, 0 ≤ μ i x)
    (w : ι → ξ → κ → ℝ) (ε : κ → ℝ)
    (hε : ∀ j, ε j ^ 2 = 1) (L : ℝ)
    (hscalar : ∃ i : ι, L ≤ signedEnergy (μ i) (w i) ε) :
    ∃ i : ι, L ≤ (Fintype.card κ : ℝ) * traceEnergy (μ i) (w i) := by
  obtain ⟨i, hi⟩ := hscalar
  exact ⟨i, hi.trans (signed_energy_le_rank_trace (μ i) (hμ i) (w i) ε hε)⟩

end Nightfall.Observability.Universal
