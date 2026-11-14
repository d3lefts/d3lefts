import ActualSourceQuadraticSectorSplit
import ActualSourceSingletonEnergyBridge
import ActualSourceCanonicalIdentification

/-!
# Literal canonical f = mean + singleton + unordered pairs, source only.

This repacks the *actual* source Efron–Stein decomposition, not a free
quadratic representation or another product measure. In particular,
each two-site kernel inherits original marginal centering.
-/

namespace Nightfall.Q2190
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceQuadraticSectorSplit
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceCanonicalIdentification
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Pointwise source canonical quadratic expansion on the FULL product
domain, including old zero-mass configurations. -/
theorem actual_source_literal_quadratic_expansion
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) (x : ι → α) :
    f x = sourceMean p f +
      (∑ i : ι, sourceCenteredSingleton p f i (x i)) +
      (∑ e : Edge ι,
        sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e)
          (x (edgeFirst e)) (x (edgeSecond e))) := by
  classical
  have hsplit (S : Finset ι) :
      (if S.card ≤ 2 then esComp p S f x else 0) =
      (if S = ∅ then esComp p S f x else 0) +
      (if S ≠ ∅ ∧ S.card ≤ 2 then esComp p S f x else 0) := by
    by_cases hz : S=∅
    · simp [hz]
    · by_cases hsmall : S.card≤2
      · simp [hz,hsmall]
      · simp [hz,hsmall]
  have hbase :
      (∑ S : Finset ι,
        if S.card ≤ 2 then esComp p S f x else 0) =
      esComp p ∅ f x +
        ((∑ i : ι, esComp p ({i} : Finset ι) f x) +
         (∑ e : Edge ι, esComp p e.1 f x)) := by
    calc
      _ = ∑ S : Finset ι,
          ((if S=∅ then esComp p S f x else 0) +
           (if S≠∅ ∧ S.card≤2 then esComp p S f x else 0)) := by
              apply Finset.sum_congr rfl
              intro S _
              exact hsplit S
      _ = (∑ S : Finset ι, if S=∅ then esComp p S f x else 0) +
          (∑ S : Finset ι, if S≠∅ ∧ S.card≤2 then esComp p S f x else 0) :=
            Finset.sum_add_distrib
      _ = esComp p ∅ f x +
          ((∑ i : ι, esComp p ({i} : Finset ι) f x) +
           (∑ e : Edge ι, esComp p e.1 f x)) := by
             rw [finite_degree_two_energy_reindex]
             simp
  have hpoint := actual_degree_two_source_decomposition p hp1 f hdegree x
  have hpair (e : Edge ι) :
      esComp p e.1 f x =
        sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e)
          (x (edgeFirst e)) (x (edgeSecond e)) := by
    rw [edge_pair_eq_endpoints e]
    exact actual_source_esComp_pair_eq_derived p hp1 f
      (edgeFirst e) (edgeSecond e) (edgeFirst_ne_edgeSecond e) x
  calc
    f x = esComp p ∅ f x +
      ((∑ i : ι, esComp p ({i} : Finset ι) f x) +
       (∑ e : Edge ι, esComp p e.1 f x)) := by
         rw [← hbase]
         exact hpoint.symm
    _ = sourceMean p f +
      ((∑ i : ι, sourceCenteredSingleton p f i (x i)) +
       (∑ e : Edge ι,
         sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e)
           (x (edgeFirst e)) (x (edgeSecond e)))) := by
          rw [esComp_empty_eq_source_mean p f x]
          congr 1
          · apply Finset.sum_congr rfl
            intro i _
            exact source_es_singleton_at_original_coordinate
              p hp1 f hdegree i x
          · apply Finset.sum_congr rfl
            intro e _
            exact hpair e
    _ = _ := by ring

end Nightfall.Q2190
