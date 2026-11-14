import ActualSourceOwnedGraph
import ActualSourcePairEnergyBridge
import ActualSourceInfluenceEnergy

/-!
# Owned original-pair energy is bounded by genuine source influence

All edges are the true two-element subsets of the original finite
coordinate set. The greedy owner retains exactly one endpoint of
each edge, so its owned pair sectors are a subset of the original
Efron–Stein sectors containing that endpoint. No energy upper bound
or extra probability law is supplied.
-/

namespace Nightfall.Observability.ActualSourceOwnedInfluence

open Finset
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualSourceFinitePairMoment

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Every genuinely owned source pair-energy is already a
nonnegative summand of the owner's exact coordinate influence. -/
theorem actual_owned_source_pair_energy_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι) :
    (ownedEdges edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι)) i).sum
      (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) ≤
    sourceInfluence p f i := by
  classical
  let F : Finset (Edge ι) :=
    ownedEdges edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι)) i
  let q : Edge ι → Finset ι := fun e => e.1
  let P : Finset (Finset ι) := F.image q
  let en : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
  have hen (S : Finset ι) : 0 ≤ en S := by
    dsimp [en]
    apply Finset.sum_nonneg
    intro x _
    have hm : 0 ≤ originalMass p x := by
      unfold originalMass
      exact Finset.prod_nonneg (fun k _ => hp k (x k))
    exact mul_nonneg hm (sq_nonneg _)
  have hinj : Set.InjOn q (↑F : Set (Edge ι)) := by
    intro e he d hd h
    apply edge_simple e d
    simpa only [q, edge_pair_eq_endpoints] using h
  have hsum : F.sum (fun e => en (q e)) = P.sum en := by
    exact (Finset.sum_image (s := F) (g := q)
      (f := en) (fun e he d hd h => hinj he hd h)).symm
  have hsub : P ⊆ Finset.univ.filter (fun S : Finset ι => i ∈ S) := by
    intro S hS
    obtain ⟨e, he, rfl⟩ := Finset.mem_image.mp hS
    have heowner : owner edgeFirst edgeSecond c e = i :=
      (Finset.mem_filter.mp he).2
    apply Finset.mem_filter.mpr
    constructor
    · exact Finset.mem_univ _
    change i ∈ (e.1 : Finset ι)
    rw [edge_pair_eq_endpoints e,
      endpoints_eq_owner_other edgeFirst edgeSecond c e, heowner]
    simp
  have hsmall :
      P.sum en ≤
      (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun S hS hnot => hen S)
  have htotal :
      (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en =
      sourceInfluence p f i := by
    have h := original_source_influence_eq_interaction_energy p hp1 f i
    simpa [Finset.sum_filter, en] using h.symm
  have hcanonical (e : Edge ι) :
      sourcePairEnergy p f (edgeFirst e) (edgeSecond e) =
        en (q e) := by
    have he := original_pair_finite_moment_energy_eq_canonical
      p hp1 f (edgeFirst e) (edgeSecond e)
      (edgeFirst_ne_edgeSecond e)
    simpa only [en, q, edge_pair_eq_endpoints] using he
  change F.sum (fun e =>
    sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) ≤
      sourceInfluence p f i
  calc
    F.sum (fun e =>
      sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) =
      F.sum (fun e => en (q e)) := by
        apply Finset.sum_congr rfl
        intro e _
        exact hcanonical e
    _ = P.sum en := hsum
    _ ≤ (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en := hsmall
    _ = sourceInfluence p f i := htotal

end Nightfall.Observability.ActualSourceOwnedInfluence
