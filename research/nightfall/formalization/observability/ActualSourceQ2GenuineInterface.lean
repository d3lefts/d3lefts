import ActualSourceIntegratedEnergy
import ActualSourceMatchingCover

/-!
# One genuine finite-product source: degree-two energy and the derived 8B pair cover

The hypotheses are only an original finite product law, an original
bounded function of Efron-Stein degree at most two, and a base point.
No sector-energy, pair-amplitude, matching, or endpoint budget is supplied.

This is an intermediate source-only certificate, **not** the terminal
dimension-free variance-squared / maximum-influence theorem. It must be
strict-compiled under the active Lean pin before it can be cited.
-/

namespace Nightfall.Observability.ActualSourceQ2GenuineInterface

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceIntegratedEnergy
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.ActualSourceMatchingCover

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Same original p,f throughout both Parseval and the global, unsupplied
greedy endpoint cover. No auxiliary Q2 inequality or numerical budget. -/
theorem original_source_energy_and_attained_pair_cover
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ((sourceVariance p f =
        ∑ S : Finset ι,
          if S ≠ ∅ ∧ S.card ≤ 2 then
            (∑ x : ι → α,
              originalMass p x * (esComp p S f x)^2)
          else 0) ∧
      (∀ i : ι,
        sourceInfluence p f i =
          ∑ S : Finset ι,
            if i ∈ S ∧ S.card ≤ 2 then
              (∑ x : ι → α,
                originalMass p x * (esComp p S f x)^2)
            else 0)) ∧
    (∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i j : ι, i ≠ j →
        pairAmplitudeWeight p f i j ≤ max (c i) (c j))) := by
  classical
  constructor
  · exact genuine_source_degree_two_variance_and_influence p hp1 f hdegree
  · let T : Finset (ι × ι) :=
      Finset.univ.filter (fun e => e.1 ≠ e.2)
    have hne : ∀ e ∈ T, e.1 ≠ e.2 := by
      intro e he
      exact (Finset.mem_filter.mp he).2
    obtain ⟨c, hc, hbudget, hcover⟩ :=
      source_greedy_attained_endpoint_cover
        (E := ι × ι) (ι := ι) (α := α)
        p hp hp1 f hdegree base
        (fun e : ι × ι => e.1) (fun e : ι × ι => e.2)
        T hne B hf
    refine ⟨c, hc, hbudget, ?_⟩
    intro i j hij
    apply hcover (i, j)
    simp [T, hij]

end Nightfall.Observability.ActualSourceQ2GenuineInterface
