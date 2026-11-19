import Mathlib

/-!
# Original-law conditional projection contracts squared difference energy

This source proves the weighted Jensen contraction required for #807's finite
mixed arbitrary-law/fair-sign hybrid. It is an analytic dependency, not the
complete fair-cubic influence theorem, and it does not assert conditional
Efron--Stein Poincare or the #804 sharp Khintchine inequality.

Weights may have zero mass. No artificial fair measure is placed on anchor
coordinates. All statements use finite original-law sums.
-/

namespace Nightfall.CubicQ3.SourceProjection

open Finset

/-- Finite Jensen for the square, with original nonnegative weights.
This proof uses only nonnegativity of weighted deviations and finite sums. -/
theorem weighted_square_jensen
    {α : Type*} [Fintype α] (p d : α → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hpsum : (∑ a, p a) = 1) :
    (∑ a, p a * d a) ^ 2 ≤ (∑ a, p a * (d a) ^ 2) := by
  let μ : ℝ := ∑ a, p a * d a
  have hnonneg : 0 ≤ (∑ a, p a * (d a - μ) ^ 2) := by
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hp a) (sq_nonneg _)
  have hexpand :
      (∑ a, p a * (d a - μ) ^ 2) =
        (∑ a, p a * (d a) ^ 2) -
        2 * μ * (∑ a, p a * d a) +
        μ ^ 2 * (∑ a, p a) := by
    calc
      (∑ a, p a * (d a - μ) ^ 2) =
          (∑ a, (p a * (d a) ^ 2 -
            (2 * μ) * (p a * d a) + μ ^ 2 * p a)) := by
          apply Finset.sum_congr rfl
          intro a _
          ring
      _ = (∑ a, p a * (d a) ^ 2) -
          2 * μ * (∑ a, p a * d a) +
          μ ^ 2 * (∑ a, p a) := by
          simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
            ← Finset.mul_sum]
  have hμ : (∑ a, p a * d a) = μ := rfl
  rw [hexpand, hμ, hpsum] at hnonneg
  change μ ^ 2 ≤ (∑ a, p a * (d a) ^ 2)
  nlinarith

/-- Averaging over arbitrary original-law anchor data cannot increase
the squared difference between any two fair configurations. -/
theorem pointwise_projection_difference_contracts
    {α : Type*} [Fintype α] {β : Type*}
    (p : α → ℝ) (f : α → β → ℝ) (x y : β)
    (hp : ∀ a, 0 ≤ p a) (hpsum : (∑ a, p a) = 1) :
    ((∑ a, p a * f a x) - (∑ a, p a * f a y)) ^ 2 ≤
      (∑ a, p a * (f a x - f a y) ^ 2) := by
  have h := weighted_square_jensen p (fun a => f a x - f a y) hp hpsum
  have hdiff :
      (∑ a, p a * (f a x - f a y)) =
        (∑ a, p a * f a x) - (∑ a, p a * f a y) := by
    calc
      (∑ a, p a * (f a x - f a y)) =
          (∑ a, (p a * f a x - p a * f a y)) := by
            apply Finset.sum_congr rfl
            intro a _
            ring
      _ = (∑ a, p a * f a x) - (∑ a, p a * f a y) := by
            rw [Finset.sum_sub_distrib]
  rw [hdiff] at h
  exact h

/-- All-site L² flip-difference energy contracts under original-law
conditional expectation. The external weights need only be nonnegative.
Taking uniform fair cube weights and a single-coordinate flip is precisely
the \`Inf_i(E_A f) ≤ Inf_i(f)\` energy step required by #807. -/
theorem weighted_flip_energy_contracts
    {α β : Type*} [Fintype α] [Fintype β]
    (p : α → ℝ) (ρ : β → ℝ) (f : α → β → ℝ) (flip : β → β)
    (hp : ∀ a, 0 ≤ p a) (hpsum : (∑ a, p a) = 1)
    (hρ : ∀ x, 0 ≤ ρ x) :
    (∑ x, ρ x *
      ((∑ a, p a * f a x) - (∑ a, p a * f a (flip x))) ^ 2) ≤
    (∑ x, ρ x *
      (∑ a, p a * (f a x - f a (flip x)) ^ 2)) := by
  apply Finset.sum_le_sum
  intro x _
  exact mul_le_mul_of_nonneg_left
    (pointwise_projection_difference_contracts
      p f x (flip x) hp hpsum) (hρ x)

end Nightfall.CubicQ3.SourceProjection
