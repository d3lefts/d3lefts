import ActualSourceInfluenceEnergy

/-!
# Original-source Q2 variance and influence energy interface

This declaration composes both canonical sector identities under one
genuine finite product source p, observable f, and degree-two hypothesis.

It assumes no external sector-energy, amplitude, matching, fourth-moment,
or section budget. It is NOT the terminal dimension-free Q2 inequality.
The terminal quantitative source-only theorem remains a separate gate.
-/
namespace Nightfall.Observability.ActualSourceIntegratedEnergy

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Same-source degree-two Parseval and canonical coordinate energy,
with no imported auxiliary energy hypotheses. -/
theorem genuine_source_degree_two_variance_and_influence
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    (sourceVariance p f =
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
          else 0) := by
  constructor
  · exact actual_degree_two_source_variance_energy p hp1 f hdegree
  · intro i
    exact original_source_degree_two_influence_energy p hp1 f hdegree i

end Nightfall.Observability.ActualSourceIntegratedEnergy
