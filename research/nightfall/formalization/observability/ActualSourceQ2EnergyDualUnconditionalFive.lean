import ActualSourceQ2SharpAdditiveFinal
import ActualSourceQ2EnergyDualTerminalFive

/-!
# Source-only unconditional Q2 energy-dual 736.673 candidate

All source-specific budgets, singleton+owned influence complement,
second/fourth moment, ownership and degree-two product assumptions
are derived from the given original p,f. The caller supplies only
actual source p,f and an actual uniform coordinate influence cap M.

THIS DECLARATION REQUIRES a new strict Lean 4.36.0-rc2 kernel receipt
at its exact commit before it can be labeled certified. No assertion
of historical novelty/optimality or heterogeneous alphabet type.
-/

namespace Nightfall.Observability.ActualSourceQ2EnergyDualUnconditionalFive

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ActualSourceQ2EnergyDualTerminalFive

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_source_q2_energy_dual_five_unconditional
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
        (403/40+(9/4)*Real.sqrt 2+(7/2)*Real.sqrt 3+
          Real.sqrt 6)^2 * B^2 * M := by
  exact actual_source_q2_energy_dual_five_given_additive_budget
    p hp hp1 f hdegree B hB hf
    (original_source_sharp_additive_budget
      p hp hp1 f hdegree B hB hf)

end Nightfall.Observability.ActualSourceQ2EnergyDualUnconditionalFive
