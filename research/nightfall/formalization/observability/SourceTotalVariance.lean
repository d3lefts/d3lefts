import Mathlib

/-!
# Original-law finite conditional total-variance identity

This is the exact decomposition of overall variance into (i) variance of
the conditional projection onto the fair block and (ii) the original-law
conditional variance of the arbitrary block. Source weights are explicit,
arbitrary, heterogeneous and may vanish. The theorem is not an invocation of
an auxiliary fair measure on the arbitrary-law block.

This discharges the purely algebraic total-variance identity used in #807.
It does NOT establish the conditional Efron--Stein/Poincare estimate for
multi-coordinate arbitrary-law blocks.
-/

namespace Nightfall.CubicQ3.SourceVariance

open Finset

/-- Exact finite weighted expansion of squared deviations. Positivity is not
needed for this identity; it applies to all normalized original weights. -/
theorem weighted_square_shift
    {α : Type*} [Fintype α]
    (p f : α → ℝ) (t : ℝ)
    (hnorm : (∑ a, p a) = 1) :
    (∑ a, p a * (f a - t) ^ 2) =
      (∑ a, p a * (f a) ^ 2) -
      2 * t * (∑ a, p a * f a) + t ^ 2 := by
  calc
    (∑ a, p a * (f a - t) ^ 2) =
        (∑ a, (p a * (f a) ^ 2 -
          (2 * t) * (p a * f a) + t ^ 2 * p a)) := by
      apply Finset.sum_congr rfl
      intro a _
      ring
    _ = (∑ a, p a * (f a) ^ 2) -
        (2 * t) * (∑ a, p a * f a) +
        t ^ 2 * (∑ a, p a) := by
      simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
        ← Finset.mul_sum]
    _ = (∑ a, p a * (f a) ^ 2) -
        2 * t * (∑ a, p a * f a) + t ^ 2 := by
      rw [hnorm]
      ring

/-- Source-specific law of total variance at a fixed fair configuration.
The centered conditional fluctuation is measured using actual weights p. -/
theorem weighted_source_total_variance_at
    {α : Type*} [Fintype α]
    (p f : α → ℝ) (μ : ℝ)
    (hnorm : (∑ a, p a) = 1) :
    (∑ a, p a * (f a - μ) ^ 2) =
      ((∑ a, p a * f a) - μ) ^ 2 +
      (∑ a, p a * (f a - (∑ z, p z * f z)) ^ 2) := by
  let g : ℝ := ∑ a, p a * f a
  have htotal := weighted_square_shift p f μ hnorm
  have hres := weighted_square_shift p f g hnorm
  dsimp [g] at *
  rw [htotal, hres]
  ring

/-- Entire conditional total-variance decomposition for any finite arbitrary
original-law source A and any finite independent block F. The weights on F
need not even be normalized because the identity holds pointwise in F.
With original product probability laws and μ=E f this is precisely:
Var(f) = Var(E_A f) + E_F[Var_A(f | F)]. -/
theorem finite_source_conditional_total_variance
    {α β : Type*} [Fintype α] [Fintype β]
    (p : α → ℝ) (ρ : β → ℝ) (f : α → β → ℝ) (μ : ℝ)
    (hnorm : (∑ a, p a) = 1) :
    (∑ x, ρ x * (∑ a, p a * (f a x - μ) ^ 2)) =
      (∑ x, ρ x * ((∑ a, p a * f a x) - μ) ^ 2) +
      (∑ x, ρ x * (∑ a,
        p a * (f a x - (∑ z, p z * f z x)) ^ 2)) := by
  calc
    (∑ x, ρ x * (∑ a, p a * (f a x - μ) ^ 2)) =
        (∑ x, (ρ x * ((∑ a, p a * f a x) - μ) ^ 2 +
          ρ x * (∑ a,
            p a * (f a x - (∑ z, p z * f z x)) ^ 2))) := by
      apply Finset.sum_congr rfl
      intro x _
      rw [weighted_source_total_variance_at p (fun a => f a x) μ hnorm]
      ring
    _ = (∑ x, ρ x * ((∑ a, p a * f a x) - μ) ^ 2) +
        (∑ x, ρ x * (∑ a,
          p a * (f a x - (∑ z, p z * f z x)) ^ 2)) := by
      rw [Finset.sum_add_distrib]

end Nightfall.CubicQ3.SourceVariance
