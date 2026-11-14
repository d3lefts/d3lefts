import ActualSourceOwnedFirstMomentCap
import ActualSourceOwnedInfluence
import ActualSourcePairEnergyBridge

/-!
# Q2 joint original singleton + genuinely owned pair influence cap

The singleton canonical support and each greedily owned two-element
support are DISJOINT summands of the same original coordinate influence.
The Hilbert moment is the true source-owned pair energy, not a synthetic
factorization. This lemma adds no moment or influence cap assumption.
A strict pinned Lean receipt is required before citing certification.
-/

namespace Nightfall.Observability.ActualSourceQ2EnergyDualSource

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedInfluence
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Actual original singleton variance PLUS actual source greedy-owned
pair moment is at most the original coordinate resampling influence.
No extra source assumptions beyond those of the previous Q2 theorem. -/
theorem original_singleton_plus_owned_energy_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    (originalSingletonNorm p f i)^2 +
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card) ≤
        sourceInfluence p f i := by
  classical
  let F : Finset (Edge ι) :=
    ownedEdges edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι)) i
  let q : Edge ι → Finset ι := fun e => e.1
  let P : Finset (Finset ι) := F.image q
  let en : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
  let H : Finset (Finset ι) :=
    Finset.univ.filter (fun S : Finset ι => i ∈ S)
  have hen (S : Finset ι) : 0 ≤ en S := by
    dsimp [en]
    apply Finset.sum_nonneg
    intro x _
    have hm : 0 ≤ originalMass p x := by
      unfold originalMass
      exact Finset.prod_nonneg (fun k _ => hp k (x k))
    exact mul_nonneg hm (sq_nonneg _)
  have hinj : Set.InjOn q (↑F : Set (Edge ι)) := by
    intro e he d hd heq
    exact Subtype.ext heq
  have hsum : F.sum (fun e => en (q e)) = P.sum en := by
    exact (Finset.sum_image (s := F) (g := q)
      (f := en) (fun e he d hd heq => hinj he hd heq)).symm
  have hcanon (e : Edge ι) :
      sourcePairEnergy p f (edgeFirst e) (edgeSecond e) =
        en (q e) := by
    have h := original_pair_finite_moment_energy_eq_canonical
      p hp1 f (edgeFirst e) (edgeSecond e)
      (edgeFirst_ne_edgeSecond e)
    simpa only [en, q, edge_pair_eq_endpoints] using h
  have howned :
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card) =
        P.sum en := by
    calc
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card) =
          F.sum (fun e =>
            sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
        exact original_owned_neighbor_moment2_eq_owned_energy p hp hp1 f c i
      _ = F.sum (fun e => en (q e)) := by
        apply Finset.sum_congr rfl
        intro e _
        exact hcanon e
      _ = P.sum en := hsum
  have hnot : ({i} : Finset ι) ∉ P := by
    intro h
    obtain ⟨e, he, heq⟩ := Finset.mem_image.mp h
    have hcard : (e.1 : Finset ι).card = 1 := by
      change (q e).card = 1
      rw [heq]
      simp
    have h2 : (e.1 : Finset ι).card = 2 := e.2
    omega
  have hsubP : P ⊆ H := by
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
  have hsub : insert ({i} : Finset ι) P ⊆ H := by
    intro S hS
    rcases Finset.mem_insert.mp hS with hS | hS
    · subst S
      simp [H]
    · exact hsubP hS
  have hle : (insert ({i} : Finset ι) P).sum en ≤ H.sum en :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun S _ _ => hen S)
  have htotal : H.sum en = sourceInfluence p f i := by
    simpa only [H, en, Finset.sum_filter] using
      (original_source_influence_eq_interaction_energy p hp1 f i).symm
  have ha2 : (originalSingletonNorm p f i)^2 = en ({i} : Finset ι) := by
    simpa only [en] using
      original_singleton_norm_sq_eq_es_energy p hp hp1 f hdegree i
  calc
    (originalSingletonNorm p f i)^2 +
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card)
       = en ({i} : Finset ι) + P.sum en := by
           rw [ha2, howned]
    _ = (insert ({i} : Finset ι) P).sum en := by
          exact (Finset.sum_insert hnot).symm
    _ ≤ H.sum en := hle
    _ = sourceInfluence p f i := htotal

end Nightfall.Observability.ActualSourceQ2EnergyDualSource
