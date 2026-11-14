import ActualSourceQuadraticSectorSplit

/-!
# Exact original-product singleton amplitude and owned variance identity

Certificate from one original product source p and actual degree≤2 f:
  * original singleton weighted Hilbert norm squared = its canonical energy;
  * singleton energy ≤ its ACTUAL Efron–Stein coordinate influence;
  * entire variance = sum singleton energies + sum greedily-owned
    second moments, without supplying either energy identity.
The source weight may vanish on arbitrary alphabet symbols.
-/

namespace Nightfall.Observability.ActualSourceSingletonEnergyBridge

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualProductSourceMarginal
open Nightfall.Observability.ActualSourceQuadraticSectorSplit
open Nightfall.Observability.ActualSourceQuadraticSupportSum
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Original singleton Hoeffding sector is literally the
source-derived one-site table evaluated at its sole source symbol. -/
theorem source_es_singleton_at_original_coordinate
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (x : ι → α) :
    esComp p ({i} : Finset ι) f x =
      sourceCenteredSingleton p f i (x i) := by
  have h := original_es_singleton_eq_source_singleton
    p hp1 f hdegree i x (x i)
  simpa using h

/-- Zero-mass-tolerant equality between actual singleton L2 norm
and original-product canonical one-site energy. -/
theorem original_singleton_norm_sq_eq_es_energy
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) :
    (originalSingletonNorm p f i)^2 =
      ∑ x : ι → α, originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2 := by
  classical
  have hmean (a : α) :
      (∑ x : ι → α, originalMass p x *
        sourceCenteredSection p f i x a) =
      sourceCenteredSingleton p f i a := by
    simpa only [originalSourceSection, sourceCenteredSection] using
      (actual_source_singleton_eq_mean_section p hp1 f i a).symm
  have hsq_nonneg : 0 ≤ (∑ a : α, p i a *
    (∑ x : ι → α, originalMass p x *
      sourceCenteredSection p f i x a)^2) := by
    exact Finset.sum_nonneg (fun a _ =>
      mul_nonneg (hp i a) (sq_nonneg _))
  calc
    (originalSingletonNorm p f i)^2 =
        ∑ a : α, p i a *
          (∑ x : ι → α, originalMass p x *
            sourceCenteredSection p f i x a)^2 := by
      unfold originalSingletonNorm
      exact Real.sq_sqrt hsq_nonneg
    _ = ∑ a : α, p i a * (sourceCenteredSingleton p f i a)^2 := by
      apply Finset.sum_congr rfl
      intro a _
      rw [hmean]
    _ = ∑ x : ι → α, originalMass p x *
          (sourceCenteredSingleton p f i (x i))^2 := by
      exact (actual_product_coordinate_marginal p hp1 i
        (fun a => (sourceCenteredSingleton p f i a)^2)).symm
    _ = ∑ x : ι → α, originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2 := by
      apply Finset.sum_congr rfl
      intro x _
      rw [source_es_singleton_at_original_coordinate p hp1 f hdegree i x]

/-- A source singleton energy is a nonnegative term of its actual
coordinate influence decomposition, with no inferred influence oracle. -/
theorem actual_singleton_energy_le_source_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) :
    (∑ x : ι → α, originalMass p x *
      (esComp p ({i} : Finset ι) f x)^2) ≤
      sourceInfluence p f i := by
  classical
  let en : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
  let F : Finset (Finset ι) :=
    Finset.univ.filter (fun S : Finset ι => i ∈ S)
  have hpositive (S : Finset ι) : 0 ≤ en S := by
    dsimp [en]
    apply Finset.sum_nonneg
    intro x _
    have hm : 0 ≤ originalMass p x := by
      unfold originalMass
      exact Finset.prod_nonneg (fun k _ => hp k (x k))
    exact mul_nonneg hm (sq_nonneg _)
  have hsub : ({({i} : Finset ι)} : Finset (Finset ι)) ⊆ F := by
    intro S hS
    have hsing : S = ({i} : Finset ι) := by
      simpa only [Finset.mem_singleton] using hS
    subst S
    simp [F]
  have hle :
      (({({i} : Finset ι)} : Finset (Finset ι)).sum en) ≤
        F.sum en :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun S _ _ => hpositive S)
  have htotal : F.sum en = sourceInfluence p f i := by
    simpa only [F, en, Finset.sum_filter] using
      (original_source_influence_eq_interaction_energy p hp1 f i).symm
  simpa only [Finset.sum_singleton, en] using hle.trans_eq htotal

/-- Actual original-singleton norm is <= sqrt of any valid
genuine coordinate influence cap, no bias or dimension factor. -/
theorem original_singleton_norm_le_sqrt_influence_cap
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (M : ℝ) (hM0 : 0 ≤ M)
    (hM : sourceInfluence p f i ≤ M) :
    originalSingletonNorm p f i ≤ Real.sqrt M := by
  have hnonneg : 0 ≤ originalSingletonNorm p f i :=
    Real.sqrt_nonneg _
  have hsq : (originalSingletonNorm p f i)^2 ≤ M := by
    rw [original_singleton_norm_sq_eq_es_energy p hp hp1 f hdegree i]
    exact (actual_singleton_energy_le_source_influence p hp hp1 f i).trans hM
  have hsqroot : (Real.sqrt M)^2 = M := Real.sq_sqrt hM0
  have hroot : 0 ≤ Real.sqrt M := Real.sqrt_nonneg M
  nlinarith

/-- Exact partition of actual degree-two variance into a one-site
Hilbert energy at each original site and actual greedy-owned independent
neighbor second moments. Owner costs are arbitrary; no energy is lost. -/
theorem original_source_variance_eq_singleton_plus_owned_moment2
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) :
    sourceVariance p f =
      (∑ i : ι, (originalSingletonNorm p f i)^2) +
      (∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        moment2 (fun k => p (j k))
          (finitePairIncrement p f i j J.card) J.card) := by
  classical
  have hsingle :
      (∑ i : ι, ∑ x : ι → α, originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2) =
      ∑ i : ι, (originalSingletonNorm p f i)^2 := by
    apply Finset.sum_congr rfl
    intro i _
    exact (original_singleton_norm_sq_eq_es_energy p hp hp1 f hdegree i).symm
  have hpairs :
      (∑ e : Edge ι, sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) =
      ∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        moment2 (fun k => p (j k))
          (finitePairIncrement p f i j J.card) J.card := by
    calc
      (∑ e : Edge ι, sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) =
        ∑ i : ι,
          (ownedEdges edgeFirst edgeSecond c
            (Finset.univ : Finset (Edge ι)) i).sum
              (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
        exact (owned_energy_partition edgeFirst edgeSecond c
          (Finset.univ : Finset (Edge ι))
          (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e))).symm
      _ = ∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        moment2 (fun k => p (j k))
          (finitePairIncrement p f i j J.card) J.card := by
        apply Finset.sum_congr rfl
        intro i _
        exact (original_owned_neighbor_moment2_eq_owned_energy
          p hp hp1 f c i).symm
  calc
    sourceVariance p f =
      (∑ i : ι, ∑ x : ι → α, originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2) +
      (∑ e : Edge ι,
        sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) :=
      source_variance_eq_singleton_plus_pair_energy p hp1 f hdegree
    _ = (∑ i : ι, (originalSingletonNorm p f i)^2) +
      (∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        moment2 (fun k => p (j k))
          (finitePairIncrement p f i j J.card) J.card) := by
      rw [hsingle, hpairs]

end Nightfall.Observability.ActualSourceSingletonEnergyBridge
