import ActualSourceQ223802Terminal
import InfinitePiQ2FiniteDegreeBridge
import InfinitePiQ2ZeroCellSourceInvariance

/-!
# Source-supported finite Q2, exact C105.416

Compose the already certified finite original-source terminal with:
* pointwise triple-difference -> canonical Efron-Stein degree <= 2;
* positive-support retraction preserving degree and boundedness;
* original-law variance and coordinate-influence invariance on zero cells.

The theorem removes the artificial requirement that f be defined with
quadratic structure and a global bound on zero-probability words.
This is a FINITE theorem: it does not assert arbitrary-product Q2.
-/

namespace Nightfall.InfinitePiQ2SupportedFiniteTerminal

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQ223802Terminal
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteSupportRepair
open Nightfall.InfinitePiQ2FiniteDegreeBridge
open Nightfall.InfinitePiQ2ZeroCellSourceInvariance

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Unrestricted finite original-source Q2 directly from assumptions only
on positive-probability source configurations. Zero-mass values need not
respect any global pointwise degree-two identity or bound. -/
theorem source_q2_supported_degree_two_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hfDegree : SupportedDegreeTwo p f)
    (B : ℝ) (hB : 0 ≤ B)
    (hfBound : ∀ x, SourceSupported p x → |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M := by
  intro M hM0 hM
  let g : (ι → α) → ℝ :=
    fun x => f (mapInputs (retractToPositive p hp1) x)
  have hgDegree : ESDegreeLE p g 2 :=
    pointwiseDegreeTwo_implies_ESDegreeLE p g
      (supported_degree_two_retraction p hp1 f hfDegree)
  have hgBound : ∀ x, |g x| ≤ B :=
    supported_bound_retraction p hp1 f B hfBound
  have hgInfluence : ∀ i, sourceInfluence p g i ≤ M := by
    intro i
    have heq : sourceInfluence p g i = sourceInfluence p f i := by
      simpa only [g] using
        (sourceInfluence_retractToPositive_exact p hp hp1 f i)
    rw [heq]
    exact hM i
  have hFinite := actual_source_q2_23802_unconditional
    p hp hp1 g hgDegree B hB hgBound M hM0 hgInfluence
  have hVariance : sourceVariance p g = sourceVariance p f := by
    simpa only [g] using
      (sourceVariance_retractToPositive_exact p hp hp1 f)
  rw [hVariance] at hFinite
  exact hFinite

end Nightfall.InfinitePiQ2SupportedFiniteTerminal
