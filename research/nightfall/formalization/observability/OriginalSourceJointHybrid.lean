import SourceTotalVariance
import OriginalSourceConditionalPoincare

/-!
# Q3 original-source joint variance / conditional-Poincare bridge

Combines two source-checked analytic dependencies into one named theorem:
(1) exact law of total variance for an arbitrary-law block versus the
independent fair block, and (2) true original-source all-degree Efron--Stein
on the arbitrary-law coordinates conditional on the fair configuration.

Theorem does not require Efron-Stein degree <= 3 and proves an upper bound
for the *actual joint input function*, with no supplied variance remainder.
It still does not prove the fair-only Q3 C<220 bound, nor its Fourier extraction.
-/

namespace Nightfall.CubicQ3.JointHybrid

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.CubicQ3.SourceVariance
open Nightfall.CubicQ3.ConditionalPoincare

variable {ι α β : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Fintype β]

/-- Joint original-law mean, with A coordinates using their exact product
law and the F block using the explicit nonnegative weights ρ. -/
noncomputable def jointMean
    (p : ι → α → ℝ) (ρ : β → ℝ)
    (f : (ι → α) → β → ℝ) : ℝ :=
  ∑ y : β, ρ y * (∑ x : ι → α, originalMass p x * f x y)

/-- Joint source variance (given normalized ρ) relative to its true mean. -/
noncomputable def jointVariance
    (p : ι → α → ℝ) (ρ : β → ℝ)
    (f : (ι → α) → β → ℝ) : ℝ :=
  ∑ y : β, ρ y * (∑ x : ι → α,
    originalMass p x * (f x y - jointMean p ρ f)^2)

/-- Variance of the original-law A-conditional projection onto F. -/
noncomputable def projectedVariance
    (p : ι → α → ℝ) (ρ : β → ℝ)
    (f : (ι → α) → β → ℝ) : ℝ :=
  ∑ y : β, ρ y *
    ((∑ x : ι → α, originalMass p x * f x y) -
      jointMean p ρ f)^2

/-- Complete finite original-source upper bound for the arbitrary-coordinate
Poincare remainder. Unlike a scalar hybrid lemma, the variance and influence
are actually derived from the SAME original input function f and mass p. -/
theorem joint_original_source_poincare_bridge
    (p : ι → α → ℝ) (ρ : β → ℝ)
    (f : (ι → α) → β → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hρ : ∀ y, 0 ≤ ρ y) :
    jointVariance p ρ f ≤ projectedVariance p ρ f +
      (∑ i : ι, ∑ y : β,
        ρ y * sourceInfluence p (fun x => f x y) i) := by
  have hnorm : (∑ x : ι → α, originalMass p x) = 1 :=
    sum_originalMass' p hp1
  have hdecomp :
      jointVariance p ρ f =
        projectedVariance p ρ f +
          (∑ y : β, ρ y * (∑ x : ι → α,
            originalMass p x *
              (f x y - (∑ z : ι → α,
                originalMass p z * f z y))^2)) := by
    simpa only [jointVariance, projectedVariance] using
      (finite_source_conditional_total_variance
        (originalMass p) ρ f (jointMean p ρ f) hnorm)
  have hcond :
      (∑ y : β, ρ y * (∑ x : ι → α,
        originalMass p x *
          (f x y - (∑ z : ι → α, originalMass p z * f z y))^2)) ≤
        (∑ i : ι, ∑ y : β,
          ρ y * sourceInfluence p (fun x => f x y) i) := by
    simpa only [sourceVariance, sourceMean] using
      (conditional_original_source_efron_stein p ρ f hp hp1 hρ)
  calc
    jointVariance p ρ f =
      projectedVariance p ρ f +
        (∑ y : β, ρ y * (∑ x : ι → α,
          originalMass p x *
            (f x y - (∑ z : ι → α,
              originalMass p z * f z y))^2)) := hdecomp
    _ ≤ projectedVariance p ρ f +
      (∑ i : ι, ∑ y : β,
        ρ y * sourceInfluence p (fun x => f x y) i) :=
        by
          nlinarith [add_le_add_left hcond (projectedVariance p ρ f)]

end Nightfall.CubicQ3.JointHybrid
