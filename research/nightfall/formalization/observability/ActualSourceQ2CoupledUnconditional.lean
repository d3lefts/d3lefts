import ActualSourceQ2SharpAdditiveFinal
import ActualSourceQ2CoupledTerminalGate

/-!
# Strict-source Q2 1064.958 improvement — pending current-pin check

No caller-supplied amplitude, moment, noise, additive, Jensen, matching
or variance budget. Actual source p,f hypotheses only.

Scope: arbitrary finite coordinates, common finite nonempty alphabet type;
coordinate-dependent normalized marginals and zero-probability atoms;
pointwise |f| <= B, canonical Efron–Stein degree <= 2.

No claim of historical novelty / independent human proof review is made.
-/

namespace Nightfall.Observability.ActualSourceQ2CoupledUnconditional

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ActualSourceQ2CoupledTerminalGate

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Unconditional, source-only variance-squared maximum-influence
inequality at coefficient 1064.958449..., strictly conditional on
successful current-pin Lean compilation and standard-axiom audit. -/
theorem actual_source_q2_coupled_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (8*(1+Real.sqrt 3) + (Real.sqrt 3+1/2)*2*(1+Real.sqrt 2))^2 *
          B^2 * M := by
  exact actual_source_q2_coupled_given_additive_budget
    p hp hp1 f hdegree B hB hf
    (original_source_sharp_additive_budget
      p hp hp1 f hdegree B hB hf)

end Nightfall.Observability.ActualSourceQ2CoupledUnconditional
