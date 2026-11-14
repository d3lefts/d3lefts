import ActualSourceQ2SharpAdditiveFinal
import ActualSourceQ2SharpTerminalGate

/-!
# Strong 1228.356 source-only Q2 theorem — candidate for strict Lean audit

No caller-supplied singleton/additive budget, noise polynomial, matching,
energy, moment, Jensen, or variance premise. The original same-source
sharp additive budget is discharged internally.

STATUS: The declaration must complete the pinned Lean 4.36.0-rc2
transitive build and standard-axiom audit before it can be called certified.
Scope: finite coordinate set, common finite nonempty alphabet type,
heterogeneous normalized marginals including zero-mass atoms, pointwise
bounded degree-two f. Different alphabet types and infinite products
are not claimed by this Lean declaration.
-/

namespace Nightfall.Observability.ActualSourceQ2StrongUnconditional

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ActualSourceQ2SharpTerminalGate

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_source_q2_strong_unconditional
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
        ((10 + 2 * Real.sqrt 2) * (1 + Real.sqrt 3))^2 *
          B^2 * M := by
  exact actual_source_q2_sharp_given_additive_budget
    p hp hp1 f hdegree B hB hf
    (original_source_sharp_additive_budget
      p hp hp1 f hdegree B hB hf)

end Nightfall.Observability.ActualSourceQ2StrongUnconditional
