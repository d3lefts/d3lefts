import Mathlib

/-!
# Conditional-mixture influence: finite weighted variance comparison

This module formalizes the nontrivial local inequality used to transfer
coordinate influences from conditionally independent latent components
to their correlated mixture. It does not require an everywhere-positive
joint density, or any density ratio bound.

The final AA exponent bound also uses the separately checked product AA
premise, convexity of t↦t^(5/2), and a finite witness-pigeonhole argument;
that composition is not yet established by this module.
-/

namespace Nightfall.LatentMixture

open Finset

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- The weighted mean of a function under a normalized finite law. -/
noncomputable def mean (p : A → ℝ) (g : A → ℝ) : ℝ :=
  ∑ a, p a * g a

/-- A normalized finite measure minimizes weighted squared loss at its mean. -/
theorem mean_minimizes_squared_loss
    (p : A → ℝ) (g : A → ℝ)
    (hp : (∑ a, p a) = 1) (hp0 : ∀ a, 0 ≤ p a)
    (z : ℝ) :
    (∑ a, p a * (g a - mean p g) ^ 2) ≤
      (∑ a, p a * (g a - z) ^ 2) := by
  let m := mean p g
  have hcent : (∑ a, p a * (g a - m)) = 0 := by
    calc
      _ = ∑ a, (p a * g a - m * p a) := by
        apply Finset.sum_congr rfl
        intro a ha
        ring
      _ = (∑ a, p a * g a) - ∑ a, m * p a := by
        rw [Finset.sum_sub_distrib]
      _ = m - m * (∑ a, p a) := by
        rw [← Finset.mul_sum]
        rfl
      _ = 0 := by rw [hp]; simp [m, mean]
  have hexact : (∑ a, p a * (g a - z) ^ 2) =
      (∑ a, p a * (g a - m) ^ 2) + (m - z)^2 := by
    calc
      _ = ∑ a, (p a * (g a - m)^2 +
          (2 * (m-z)) * (p a * (g a-m)) + (m-z)^2 * p a) := by
            apply Finset.sum_congr rfl
            intro a ha
            ring
      _ = (∑ a, p a * (g a-m)^2) +
            (2 * (m-z))*(∑ a, p a*(g a-m)) +
            (m-z)^2*(∑ a, p a) := by
              simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      _ = (∑ a, p a * (g a-m)^2) + (m-z)^2 := by
        rw [hcent, hp]
        ring
  change (∑ a, p a*(g a-m)^2) ≤ _
  rw [hexact]
  nlinarith [sq_nonneg (m-z)]

variable {Θ Γ : Type*} [Fintype Θ] [DecidableEq Θ]
  [Fintype Γ] [DecidableEq Γ]

/-- Fibre-level correlated-mixture lower bound. Each latent component
has an arbitrary nonnegative mass on the other-coordinate fibre γ,
but conditional on that fibre, the selected coordinate has a
normalized categorical law p θ independent of γ. -/
theorem conditional_mixture_fibre_dominance
    (w : Θ → ℝ) (other : Θ → Γ → ℝ) (p : Θ → A → ℝ)
    (g : Γ → A → ℝ) (z : Γ → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hother : ∀ θ γ, 0 ≤ other θ γ)
    (hp : ∀ θ, (∑ a, p θ a) = 1)
    (hp0 : ∀ θ a, 0 ≤ p θ a) :
    (∑ γ : Γ, ∑ θ : Θ, (w θ * other θ γ) *
          (∑ a : A, p θ a * (g γ a - z γ)^2)) ≥
    (∑ γ : Γ, ∑ θ : Θ, (w θ * other θ γ) *
          (∑ a : A, p θ a * (g γ a - mean (p θ) (g γ))^2)) := by
  apply Finset.sum_le_sum
  intro γ hγ
  apply Finset.sum_le_sum
  intro θ hθ
  exact mul_le_mul_of_nonneg_left
    (mean_minimizes_squared_loss (p θ) (g γ) (hp θ) (hp0 θ) (z γ))
    (mul_nonneg (hw θ) (hother θ γ))

end Nightfall.LatentMixture
