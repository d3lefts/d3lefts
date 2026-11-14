import ActualSourceConditionalProjection
import ActualSourceSingletonProjection
import ActualSourceCanonicalIdentification
import ActualSourceInfluenceEnergy

/-!
# Exact source-only degree-two conditional support reindexing

For i not in S, the ANOVA supports of order at most two that
contain i and are contained in insert i S are exactly {i}
and the genuine distinct source pairs {i,j} for j in S.

This is a finite-set theorem; it is not a probabilistic modeling
assumption. The application identifies the actual conditional
centered section with its source-derived singleton and pair tables,
including zero-probability atoms.
-/

namespace Nightfall.Observability.ActualSourceQuadraticSupportSum

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualSourceConditionalProjection
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualSourceCanonicalIdentification
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualProductSourcePairCentering

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- All incident supports of size at most 2 are a singleton
plus exactly one source pair for each distinct neighbor. -/
theorem incident_degree_two_supports
    (i : ι) (S : Finset ι) (hi : i ∉ S) :
    (Finset.univ.filter
      (fun T : Finset ι => T.card ≤ 2 ∧ i ∈ T ∧ T ⊆ insert i S)) =
      insert ({i} : Finset ι) (S.image (fun j => ({i,j} : Finset ι))) := by
  classical
  ext T
  simp only [Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_insert, Finset.mem_image]
  constructor
  · rintro ⟨hcard, himem, hsub⟩
    by_cases hsing : T = ({i} : Finset ι)
    · exact Or.inl hsing
    · have hother : ∃ j ∈ T, j ≠ i := by
        by_contra hn
        push_neg at hn
        have hTsub : T ⊆ ({i} : Finset ι) := by
          intro j hj
          simp [hn j hj]
        have heq : T = ({i} : Finset ι) :=
          Finset.Subset.antisymm hTsub (by simpa using himem)
        exact hsing heq
      obtain ⟨j, hjT, hji⟩ := hother
      have hjS : j ∈ S := by
        have hmem : j ∈ insert i S := hsub hjT
        rcases Finset.mem_insert.mp hmem with heq | hs
        · exact (hji heq).elim
        · exact hs
      have hpairs : ({i,j} : Finset ι) ⊆ T := by
        simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
        exact ⟨himem, hjT⟩
      have hpaircard : ({i,j} : Finset ι).card = 2 := by
        simp [hji, hji.symm]
      have hEq : ({i,j} : Finset ι) = T :=
        Finset.eq_of_subset_of_card_le hpairs (by omega)
      exact Or.inr ⟨j, hjS, hEq⟩
  · rintro (rfl | ⟨j, hjS, rfl⟩)
    · constructor
      · simp
      constructor
      · simp
      · exact Finset.singleton_subset_iff.mpr (by simp)
    · have hji : j ≠ i := by
        intro heq
        subst j
        exact hi hjS
      constructor
      · simp [hji, hji.symm]
      constructor
      · simp
      · intro k hk
        have hk' : k = i ∨ k = j := by
          simpa only [Finset.mem_insert, Finset.mem_singleton] using hk
        rcases hk' with rfl | rfl
        · simp
        · simp [hjS]

theorem incident_degree_two_sum
    (i : ι) (S : Finset ι) (hi : i ∉ S)
    (h : Finset ι → ℝ) :
    (∑ T : Finset ι,
      if T.card ≤ 2 ∧ i ∈ T ∧ T ⊆ insert i S then h T else 0) =
      h {i} + ∑ j ∈ S, h {i,j} := by
  classical
  let F : Finset (Finset ι) :=
    Finset.univ.filter
      (fun T : Finset ι => T.card ≤ 2 ∧ i ∈ T ∧ T ⊆ insert i S)
  have hnot :
      ({i} : Finset ι) ∉ S.image (fun j => ({i,j} : Finset ι)) := by
    intro hm
    obtain ⟨j, hj, heq⟩ := Finset.mem_image.mp hm
    have hji : j ≠ i := by
      intro he
      subst j
      exact hi hj
    have hmem : j ∈ ({i} : Finset ι) := by
      rw [← heq]
      simp
    exact hji (by simpa using hmem)
  have hinj : Set.InjOn (fun j : ι => ({i,j} : Finset ι))
        (↑S : Set ι) := by
    intro j hj k hk heq
    have hji : j ≠ i := by
      intro h
      subst j
      exact hi hj
    have hset : ({i,j} : Finset ι) = {i,k} := heq
    have hmem : j ∈ ({i,k} : Finset ι) := by
      rw [← hset]
      simp
    have hcases : j = i ∨ j = k := by
      simpa only [Finset.mem_insert, Finset.mem_singleton] using hmem
    exact hcases.resolve_left hji
  calc
    (∑ T : Finset ι,
        if T.card ≤ 2 ∧ i ∈ T ∧ T ⊆ insert i S then h T else 0) =
      F.sum h := by
        simp only [F, Finset.sum_filter]
    _ = h {i} + (S.image (fun j => ({i,j} : Finset ι))).sum h := by
      dsimp [F]
      rw [incident_degree_two_supports i S hi, Finset.sum_insert hnot]
    _ = h {i} + ∑ j ∈ S, h {i,j} := by
      congr 1
      exact Finset.sum_image (s := S) (f := h)
        (g := fun j => ({i,j} : Finset ι))
        (fun j hj k hk heq => hinj hj hk heq)

/-- Genuine source singleton equals the conditional section
with no neighbors retained; this also identifies the canonical
singleton Hoeffding term. -/
theorem original_es_singleton_eq_source_singleton
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (x : ι → α) (a : α) :
    esComp p ({i} : Finset ι) f (Function.update x i a) =
      sourceCenteredSingleton p f i a := by
  classical
  have hpairs := actual_degree_two_section_es_projection
    p hp1 f hdegree i (∅ : Finset ι) (by simp) x a
  have hsingle :
      averageSourceSection p f i (∅ : Finset ι) x a =
      esComp p ({i} : Finset ι) f (Function.update x i a) := by
    rw [incident_degree_two_sum i (∅ : Finset ι) (by simp)
      (fun T => esComp p T f (Function.update x i a))] at hpairs
    simpa using hpairs
  have hzero :
      averageSourceSection p f i (∅ : Finset ι) x a =
      ∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a := by
    unfold averageSourceSection
    apply Finset.sum_congr rfl
    intro y _
    have hmerge : merge (∅ : Finset ι) x y = y := by
      funext k
      simp [merge]
    rw [hmerge]
    rfl
  calc
    esComp p ({i} : Finset ι) f (Function.update x i a) =
      averageSourceSection p f i ∅ x a := hsingle.symm
    _ = ∑ y : ι → α, originalMass p y *
      sourceCenteredSection p f i y a := hzero
    _ = sourceCenteredSingleton p f i a := by
      simpa only [originalSourceSection, sourceCenteredSection] using
        (actual_source_singleton_eq_mean_section p hp1 f i a).symm

/-- Exact original-product degree-two conditional identity;
no surrogate pair kernel or projective decomposition premise. -/
theorem source_degree_two_projected_section_eq_singleton_add_pairs
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (S : Finset ι) (hi : i ∉ S)
    (x : ι → α) (a : α) :
    averageSourceSection p f i S x a =
      sourceCenteredSingleton p f i a +
        ∑ j ∈ S, sourceDoubleCenteredPair p f i j a (x j) := by
  rw [actual_degree_two_section_es_projection
    p hp1 f hdegree i S hi x a,
    incident_degree_two_sum i S hi
      (fun T => esComp p T f (Function.update x i a)),
    original_es_singleton_eq_source_singleton p hp1 f hdegree i x a]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  have hji : j ≠ i := by
    intro h
    subst j
    exact hi hj
  have hpair := actual_source_esComp_pair_eq_derived
    p hp1 f i j hji.symm (Function.update x i a)
  simpa [Function.update_of_ne hji] using hpair

end Nightfall.Observability.ActualSourceQuadraticSupportSum
