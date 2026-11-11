import Mathlib

/-!
# NIGHTFALL v7: pointwise diagonal-covariance sign transfer

The merged Rademacher-orthogonality module proves an ensemble-average
isometry.  This separate theorem establishes the DIFFERENT fact needed by
the scalar influence premise: every individual sign projection has the
full variance whenever the active covariance is diagonal in the chosen
basis.  A finite coherence interface then passes a scalar influential
coordinate to a trace-influential coordinate.

This is a finite algebraic bridge.  The scalar influence premise,
posterior covariance diagonalization, and measurable Hilbert extension
are not asserted to be kernel-certified by this file.
-/

namespace Nightfall.Observability.V7

open Finset

variable {Ω J : Type*} [Fintype Ω] [Fintype J] [DecidableEq J]

/-- Each sign projection has full trace energy, not merely the average
over the sign ensemble, if the covariance cross-terms vanish. -/
theorem diagonal_signed_variance
    (μ : Ω → ℝ) (g : Ω → J → ℝ) (ε : J → ℝ)
    (hε : ∀ j, ε j ^ 2 = 1)
    (hdiag : ∀ j k : J, j ≠ k →
      (∑ x : Ω, μ x * (g x j * g x k)) = 0) :
    (∑ x : Ω, μ x * (∑ j : J, ε j * g x j) ^ 2) =
      ∑ j : J, ∑ x : Ω, μ x * (g x j) ^ 2 := by
  classical
  have hpoint (x : Ω) :
      (∑ j : J, ε j * g x j) ^ 2 =
        ∑ j : J, ∑ k : J,
          (ε j * ε k) * (g x j * g x k) := by
    calc
      (∑ j : J, ε j * g x j) ^ 2 =
          (∑ j : J, ε j * g x j) * (∑ k : J, ε k * g x k) := by ring
      _ = ∑ j : J, ∑ k : J,
          (ε j * ε k) * (g x j * g x k) := by
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro j _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro k _
            ring
  have hreorder :
      (∑ x : Ω, μ x * (∑ j : J, ε j * g x j) ^ 2) =
        ∑ j : J, ∑ k : J,
          (ε j * ε k) *
            (∑ x : Ω, μ x * (g x j * g x k)) := by
    calc
      (∑ x : Ω, μ x * (∑ j : J, ε j * g x j) ^ 2) =
          ∑ x : Ω, μ x *
            (∑ j : J, ∑ k : J,
              (ε j * ε k) * (g x j * g x k)) := by
                apply Finset.sum_congr rfl
                intro x _
                rw [hpoint x]
      _ = ∑ x : Ω, ∑ j : J, ∑ k : J,
            μ x * ((ε j * ε k) * (g x j * g x k)) := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro j _
              rw [Finset.mul_sum]
      _ = ∑ j : J, ∑ k : J, ∑ x : Ω,
            μ x * ((ε j * ε k) * (g x j * g x k)) := by
              calc
                _ = ∑ j : J, ∑ x : Ω, ∑ k : J,
                      μ x * ((ε j * ε k) * (g x j * g x k)) :=
                        Finset.sum_comm
                _ = ∑ j : J, ∑ k : J, ∑ x : Ω,
                      μ x * ((ε j * ε k) * (g x j * g x k)) := by
                        apply Finset.sum_congr rfl
                        intro j _
                        exact Finset.sum_comm
      _ = ∑ j : J, ∑ k : J,
            (ε j * ε k) *
              (∑ x : Ω, μ x * (g x j * g x k)) := by
              apply Finset.sum_congr rfl
              intro j _
              apply Finset.sum_congr rfl
              intro k _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro x _
              ring
  rw [hreorder]
  calc
    (∑ j : J, ∑ k : J, (ε j * ε k) *
        (∑ x : Ω, μ x * (g x j * g x k))) =
      ∑ j : J, ∑ k : J,
        if j = k then (∑ x : Ω, μ x * (g x j) ^ 2) else 0 := by
          apply Finset.sum_congr rfl
          intro j _
          apply Finset.sum_congr rfl
          intro k _
          by_cases hjk : j = k
          · subst k
            simp only [if_pos rfl]
            have he : ε j * ε j = (1 : ℝ) := by nlinarith [hε j]
            rw [he, one_mul]
            apply Finset.sum_congr rfl
            intro x _
            ring
          · rw [if_neg hjk, hdiag j k hjk]
            ring
    _ = ∑ j : J, ∑ x : Ω, μ x * (g x j) ^ 2 := by simp

/-- Compose diagonal covariance, a supplied scalar influence theorem,
and a posterior-uniform coherence bound.  Neither analytical premise
is concealed in the formal conclusion. -/
theorem scalar_to_trace_with_coherence
    {I : Type*} [Fintype I]
    (μ : Ω → ℝ) (g : Ω → J → ℝ)
    (ν : I → Ω → ℝ) (w : I → Ω → J → ℝ)
    (C L : ℝ)
    (hdiag : ∀ j k : J, j ≠ k →
      (∑ x : Ω, μ x * (g x j * g x k)) = 0)
    (hscalar : ∀ ε : J → ℝ, (∀ j, ε j ^ 2 = 1) →
      (∑ x : Ω, μ x * (∑ j : J, ε j * g x j) ^ 2) =
        (∑ j : J, ∑ x : Ω, μ x * (g x j) ^ 2) →
      ∃ i : I, L ≤
        (∑ x : Ω, ν i x * (∑ j : J, ε j * w i x j) ^ 2))
    (hcoh : ∀ i : I, ∀ ε : J → ℝ, (∀ j, ε j ^ 2 = 1) →
      (∑ x : Ω, ν i x * (∑ j : J, ε j * w i x j) ^ 2) ≤
        C * (∑ x : Ω, ν i x * ∑ j : J, (w i x j) ^ 2)) :
    ∃ i : I, L ≤
      C * (∑ x : Ω, ν i x * ∑ j : J, (w i x j) ^ 2) := by
  let ε : J → ℝ := fun _ => 1
  have hε : ∀ j, ε j ^ 2 = 1 := by intro j; norm_num [ε]
  have hvar := diagonal_signed_variance μ g ε hε hdiag
  obtain ⟨i, hi⟩ := hscalar ε hε hvar
  exact ⟨i, hi.trans (hcoh i ε hε)⟩

end Nightfall.Observability.V7
