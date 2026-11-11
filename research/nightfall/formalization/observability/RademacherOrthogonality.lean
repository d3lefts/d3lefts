import Mathlib

/-!
# Universal spectral observability: finite signed-ensemble orthogonality

For an arbitrary finite probability/sign ensemble with exact pairwise signed
orthogonality, the signed scalar projection has mean squared energy exactly
equal to the Hilbert-coordinate trace energy. This is the finite algebraic
bridge needed to compress scalar influences into a rank-sensitive trace.

The Rademacher construction of an orthogonal sign ensemble, the exponential
moment bound, and the product-measurable posterior recursion are SEPARATE
open Lean obligations. In particular, this module does not prove the
universal observability theorem.
-/

namespace Nightfall.Observability.Rademacher

open Finset

variable {ξ κ ι : Type*} [Fintype ξ] [Fintype κ] [DecidableEq κ] [Fintype ι]

/-- Every rank-coordinate signed product can be expanded as a double sum. -/
theorem signed_square_expand (σ : ξ → κ → ℝ) (v : κ → ℝ) (x : ξ) :
    (∑ j : κ, σ x j * v j) ^ 2 =
      ∑ j : κ, ∑ k : κ, (σ x j * σ x k) * (v j * v k) := by
  calc
    (∑ j : κ, σ x j * v j) ^ 2 =
        (∑ j : κ, σ x j * v j) * (∑ k : κ, σ x k * v k) := by ring
    _ = ∑ j : κ, ∑ k : κ, (σ x j * σ x k) * (v j * v k) := by
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro j _
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k _
      ring

/-- Weighted orthogonal signed projections preserve exact squared norm. -/
theorem signed_orthogonal_isometry
    (μ : ξ → ℝ) (σ : ξ → κ → ℝ)
    (horth : ∀ j k : κ,
      (∑ x : ξ, μ x * (σ x j * σ x k)) =
        if j = k then 1 else 0)
    (v : κ → ℝ) :
    (∑ x : ξ, μ x * (∑ j : κ, σ x j * v j) ^ 2) =
      ∑ j : κ, v j ^ 2 := by
  calc
    (∑ x : ξ, μ x * (∑ j : κ, σ x j * v j) ^ 2) =
        ∑ x : ξ, ∑ j : κ, ∑ k : κ,
          μ x * ((σ x j * σ x k) * (v j * v k)) := by
      apply Finset.sum_congr rfl
      intro x _
      rw [signed_square_expand σ v x, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      rw [Finset.mul_sum]
    _ = ∑ j : κ, ∑ k : κ, (∑ x : ξ,
          μ x * (σ x j * σ x k)) * (v j * v k) := by
      calc
        (∑ x : ξ, ∑ j : κ, ∑ k : κ,
            μ x * ((σ x j * σ x k) * (v j * v k))) =
          ∑ j : κ, ∑ x : ξ, ∑ k : κ,
            μ x * ((σ x j * σ x k) * (v j * v k)) := Finset.sum_comm
        _ = ∑ j : κ, ∑ k : κ, ∑ x : ξ,
            μ x * ((σ x j * σ x k) * (v j * v k)) := by
          apply Finset.sum_congr rfl
          intro j _
          exact Finset.sum_comm
        _ = _ := by
          apply Finset.sum_congr rfl
          intro j _
          apply Finset.sum_congr rfl
          intro k _
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro x _
          ring
    _ = ∑ j : κ, ∑ k : κ,
          (if j = k then 1 else 0) * (v j * v k) := by
      apply Finset.sum_congr rfl
      intro j _
      apply Finset.sum_congr rfl
      intro k _
      rw [horth]
    _ = ∑ j : κ, v j ^ 2 := by
      simp [pow_two]

/-- Exact signed projection-to-trace identity for arbitrary nonnegative
coordinate sample weights and finite increment samples. The weights need
not be normalized: normalization is built into horth. -/
theorem signed_energy_trace_identity
    (μ : ξ → ℝ) (σ : ξ → κ → ℝ)
    (horth : ∀ j k : κ,
      (∑ x : ξ, μ x * (σ x j * σ x k)) =
        if j = k then 1 else 0)
    (ρ : ι → ℝ)
    (w : ι → κ → ℝ) :
    (∑ x : ξ, μ x * ∑ i : ι,
        ρ i * (∑ j : κ, σ x j * w i j) ^ 2) =
      ∑ i : ι, ρ i * ∑ j : κ, (w i j) ^ 2 := by
  calc
    (∑ x : ξ, μ x * ∑ i : ι,
        ρ i * (∑ j : κ, σ x j * w i j) ^ 2) =
        ∑ i : ι, ρ i * (∑ x : ξ,
          μ x * (∑ j : κ, σ x j * w i j) ^ 2) := by
      calc
        (∑ x : ξ, μ x * ∑ i : ι,
            ρ i * (∑ j : κ, σ x j * w i j) ^ 2) =
          ∑ x : ξ, ∑ i : ι,
            μ x * (ρ i * (∑ j : κ, σ x j * w i j) ^ 2) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
        _ = ∑ i : ι, ∑ x : ξ,
            μ x * (ρ i * (∑ j : κ, σ x j * w i j) ^ 2) := Finset.sum_comm
        _ = ∑ i : ι, ρ i * (∑ x : ξ,
            μ x * (∑ j : κ, σ x j * w i j) ^ 2) := by
            apply Finset.sum_congr rfl
            intro i _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro x _
            ring
    _ = ∑ i : ι, ρ i * ∑ j : κ, (w i j) ^ 2 := by
      apply Finset.sum_congr rfl
      intro i _
      rw [signed_orthogonal_isometry μ σ horth (w i)]

end Nightfall.Observability.Rademacher
