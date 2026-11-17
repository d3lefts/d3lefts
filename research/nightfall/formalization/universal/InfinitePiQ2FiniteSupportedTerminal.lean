import ActualSourceQ223802Terminal
import InfinitePiQ2FiniteDegreeBridge
import InfinitePiQ2ZeroCellSourceInvariance

/-!
# Complete original-source finite Q2 from positive-support degree/bound

This theorem composes the FULL merged original-source finite C105.416
certificate with all newly kernel-certified operators:
  * pointwise degree <=2 on the positive original source support,
  * coordinatewise zero-cell retraction to global pointwise degree <=2,
  * pointwise global absolute bound from the source-supported bound,
  * mixed-difference => canonical original Efron-Stein degree <=2,
  * exact original-source variance and heat-bath influence invariances.

Unlike an unsupported finite-label premise, this theorem requires NO
global quadratic/bound extension witness as input. No source atom floor,
positive-mass assumption on all letters, or replacement distribution.

This is an unrestricted original finite product theorem, not the final
arbitrary-index/infinite-alphabet source-product transport.
-/

namespace Nightfall.InfinitePiQ2FiniteSupportedTerminal

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ223802Terminal
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteSupportRepair
open Nightfall.InfinitePiQ2FiniteDegreeBridge
open Nightfall.InfinitePiQ2ZeroCellSourceInvariance

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]

/-- Full original finite C105.416 Q2 inequality under only source-supported
degree-two and |f| <= B assumptions. All zero-weight evaluations of f are
irrelevant. No caller-supplied repair, moment, owner, tensor, influence,
or variance identities. -/
theorem original_source_q2_105416_support_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : SupportedDegreeTwo p f)
    (B : ℝ) (hB : 0 ≤ B)
    (hbounded : ∀ x, SourceSupported p x → |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M := by
  classical
  let g : (ι → α) → ℝ :=
    fun x => f (mapInputs (retractToPositive p hp1) x)
  have hgdegree : PointwiseDegreeTwo g :=
    supported_degree_two_retraction p hp1 f hdegree
  have hgES : ESDegreeLE p g 2 :=
    pointwiseDegreeTwo_implies_ESDegreeLE p g hgdegree
  have hgbound : ∀ x, |g x| ≤ B :=
    supported_bound_retraction p hp1 f B hbounded
  have hvar : sourceVariance p g = sourceVariance p f :=
    sourceVariance_retractToPositive_exact p hp hp1 f
  have hinfl (i : ι) :
      sourceInfluence p g i = sourceInfluence p f i :=
    sourceInfluence_retractToPositive_exact p hp hp1 f i
  intro M hM0 hcap
  have hcapg : ∀ i, sourceInfluence p g i ≤ M := by
    intro i
    rw [hinfl i]
    exact hcap i
  have hfinite :=
    actual_source_q2_23802_unconditional
      p hp hp1 g hgES B hB hgbound M hM0 hcapg
  simpa only [hvar] using hfinite

end Nightfall.InfinitePiQ2FiniteSupportedTerminal
