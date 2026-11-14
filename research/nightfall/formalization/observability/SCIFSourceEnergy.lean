import SCIFSourceDegree
import ActualSourceInfluenceEnergy

/-!
# SCIF source bridge II: re-derive true source influence and variance
after changing the product marginal law.

Unlike the pair-table identities, all quantities in this file are built from
the original observable f and sourceMass q / esComp q. The new-law degree
hypothesis is proved from the old source's canonical decomposition.

This stage identifies exactly which new-law interaction energies contribute
to true source resampling influence. It does not yet express the new
canonical components in terms of the old low-order components, nor prove
a local computational update or source-greedy owner reuse.
-/

namespace Nightfall.SCIF.SourceEnergy
open Finset
open Nightfall.SCIF.SourceDegree
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- After ANY product-law edit, the actual source coordinate resampling
influence is exactly the new-law singleton+pair canonical energy.
The degree premise is only on the OLD original source f. -/
theorem source_edited_degree_two_influence_energy
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) (i : ι) :
    sourceInfluence q f i =
      ∑ S : Finset ι,
        if i ∈ S ∧ S.card ≤ 2 then
          ∑ x : ι → α, originalMass q x * (esComp q S f x)^2
        else 0 := by
  exact original_source_degree_two_influence_energy
    q hq1 f (degree_two_source_repair p q hp1 f hdegree) i

/-- Source variance is exactly the edited canonical singleton+pair
Parseval energy, with no new degree oracle supplied. -/
theorem source_edited_degree_two_variance_energy
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    sourceVariance q f =
      ∑ S : Finset ι,
        if S ≠ ∅ ∧ S.card ≤ 2 then
          ∑ x : ι → α, originalMass q x * (esComp q S f x)^2
        else 0 := by
  exact actual_degree_two_source_variance_energy
    q hq1 f (degree_two_source_repair p q hp1 f hdegree)

end Nightfall.SCIF.SourceEnergy
