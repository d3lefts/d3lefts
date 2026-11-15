import ActualSourcePureQ2Golden
import ActualSourceIntegratedSharp

/-!
# Source-unconditional pure Q2 C95.0630724694

Independent composition of the exact-head strict Lean source theorems
from PR #546 (pure golden site, C100.946) and PR #549
(sharp 2(1+sqrt 2)*B actual-source section, unrestricted degree two).

No shifted c/5 probabilistic premise is needed. This is only for
zero canonical singletons, not arbitrary nonzero singleton functions.
The source is the genuine finite product with heterogeneous normalized
marginals, including zero-probability atoms.

Certification requires current-head pinned Lean compilation, permitted
axiom check and exact source digest; prior-art or human review separate.
-/

namespace Nightfall.Observability.ActualSourcePureQ2Sharp

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourcePureQ2Golden
open Nightfall.Observability.ActualSourceIntegratedSharp
open Nightfall.Q2625Golden

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Full original-product source theorem: no caller-supplied section,
moment, ownership, or influence-energy premise. Zero singleton is
the explicit and necessary subclass restriction. -/
theorem actual_source_pure_q2_95_063_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+8*gamma)^2*B^2*M := by
  intro M hM0 hM
  have hsection :
      (∑ i : ι, sourceMeanSectionNorm p f i) ≤
        (2*(1+Real.sqrt 2))*B :=
    actual_source_integrated_sharp_budget
      p hp hp1 f hdegree B hB hf
  have h := actual_source_pure_q2_golden_given_section_budget
    p hp hp1 f hdegree hzero B hB hf
    (2*(1+Real.sqrt 2)) (by positivity)
    hsection M hM0 hM
  convert h using 1 <;> ring

end Nightfall.Observability.ActualSourcePureQ2Sharp
