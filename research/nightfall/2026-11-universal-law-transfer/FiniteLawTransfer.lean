import Mathlib

/-!
NIGHTFALL / Universal Law Transfer — finite exact inequality kernel.

The two substantive finite statements below give the complete sharp-dual
UPPER certificate for bounded-loss transport across an arbitrary change of law.
The fully general measure-theoretic Radon–Nikodym/Lebesgue decomposition,
threshold optimality, and the import of the existing adaptive observer
are separate written analytic arguments, NOT compiled by this file.
-/

namespace Nightfall.UniversalLawTransfer

/-- Pointwise Neyman–Pearson / hockey-stick upper certificate. No probability
normalization is needed for this elementary inequality. -/
theorem loss_dual_pointwise (p q e a : ℝ)
    (he0 : 0 ≤ e) (he1 : e ≤ 1) :
    q * e ≤ a * (p * e) + max (q - a * p) 0 := by
  let z : ℝ := max (q - a * p) 0
  have hmajor : q ≤ a * p + z := by
    have hz : q - a * p ≤ z := le_max_left _ _
    linarith
  have hz_nonneg : 0 ≤ z := le_max_right _ _
  have hmult := mul_le_mul_of_nonneg_right hmajor he0
  have hcap := mul_le_mul_of_nonneg_left he1 hz_nonneg
  dsimp [z] at *
  nlinarith

/-- The finite sharp-dual upper inequality for transport of ANY bounded
loss with a finite reference-law budget. No density bound is imposed. -/
theorem finite_loss_dual {Ω : Type*} [Fintype Ω]
    (p q loss : Ω → ℝ) (a t : ℝ)
    (ha : 0 ≤ a)
    (hlo : ∀ i, 0 ≤ loss i)
    (hhi : ∀ i, loss i ≤ 1)
    (hbudget : (∑ i, p i * loss i) ≤ t) :
    (∑ i, q i * loss i) ≤
      a * t + ∑ i, max (q i - a * p i) 0 := by
  classical
  calc
    (∑ i, q i * loss i) ≤
        ∑ i, (a * (p i * loss i) + max (q i - a * p i) 0) := by
      apply Finset.sum_le_sum
      intro i hi
      exact loss_dual_pointwise (p i) (q i) (loss i) a (hlo i) (hhi i)
    _ = a * (∑ i, p i * loss i) +
          ∑ i, max (q i - a * p i) 0 := by
      rw [Finset.sum_add_distrib, Finset.mul_sum]
    _ ≤ a * t + ∑ i, max (q i - a * p i) 0 := by
      have h := mul_le_mul_of_nonneg_left hbudget ha
      linarith

/-- Zero-error transport on the support of *any* target law dominated
by the reference support; an exact-observation policy need not change. -/
theorem exact_support_transfer {Ω V : Type*}
    (p q : Ω → ℝ) (f predictor : Ω → V)
    (hdom : ∀ x, 0 < q x → 0 < p x)
    (hcorrect : ∀ x, 0 < p x → predictor x = f x) :
    ∀ x, 0 < q x → predictor x = f x := by
  intro x hx
  exact hcorrect x (hdom x hx)

open MeasureTheory

/-- Full arbitrary-measurable-space zero-error transport from reference law
to ANY absolutely continuous target law. This theorem imports the classical
mathlib absolute-continuity AE implication; it does NOT assume or prove the
existence of a low-degree source observer. -/
theorem exact_observer_under_dominated_measure
    {Ω V : Type*} [MeasurableSpace Ω]
    (μ ν : MeasureTheory.Measure Ω) (f predicted : Ω → V)
    (hνμ : ν ≪ μ)
    (hμ : f =ᵐ[μ] predicted) :
    f =ᵐ[ν] predicted := by
  exact hνμ.ae_eq hμ

end Nightfall.UniversalLawTransfer
