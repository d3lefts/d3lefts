import ActualESConditionalProjection
import ActualESSourceEnergy
import ActualESOrthogonality
import ActualESVarianceEnergy

/-!
# Canonical ORIGINAL-source influence ANOVA and owned pair energy budget

The source's full coordinate-resampling influence is decomposed into
exact canonical Efron-Stein energies of interactions containing that
coordinate. The proof reuses actual-source conditional projection,
resampling, orthogonality and section-energy equality, never a
user-supplied ANOVA energy bound. The resulting nonnegative-subset
inequality gives any owned pair subset an influence cap.

This is a candidate source-level bridge; only strict pinned kernel
compilation may promote it to certified status. It does not by itself
identify a synthetic independent-neighbor moment table with an actual
source conditional section, or complete the Q2 terminal constant.
-/

namespace Nightfall.Observability.ActualESInfluenceEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESConditionalSection
open Nightfall.Observability.ActualESConditionalProjection
open Nightfall.Observability.ActualESSourceEnergy
open Nightfall.Observability.ActualESOrthogonality
open Nightfall.Observability.ActualESVarianceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The genuinely centered source coordinate section ignores the input
symbol at i, even when f itself depends on that symbol. -/
theorem source_section_update_insensitive
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x y : ι → α) (a : α)
    (hother : ∀ j, j ≠ i → x j = y j) :
    sourceSection p f i x a = sourceSection p f i y a := by
  have hu (b : α) :
      Function.update x i b = Function.update y i b := by
    funext k
    by_cases hk : k = i
    · subst k
      simp
    · simp [hk, hother k hk]
  unfold sourceSection
  rw [hu a]
  apply congrArg (fun t : ℝ => f (Function.update y i a) - t)
  apply Finset.sum_congr rfl
  intro b _
  rw [hu b]

/-- Conditioning on every other original coordinate does not change
the genuine source section. The unused input coordinate is integrated
under the original product law, not replaced with an independent copy. -/
theorem source_section_full_neighbor_average
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) :
    averageSourceSection p f i (Finset.univ.erase i) x a =
      sourceSection p f i x a := by
  have hsame (y : ι → α) :
      sourceSection p f i (merge (Finset.univ.erase i) x y) a =
        sourceSection p f i x a := by
    apply source_section_update_insensitive p f i _ x a
    intro j hj
    have hmem : j ∈ Finset.univ.erase i := by simp [hj]
    simp [merge, hmem]
  unfold averageSourceSection
  calc
    (∑ y : ι → α, prodMass p y *
      sourceSection p f i (merge (Finset.univ.erase i) x y) a) =
      ∑ y : ι → α, prodMass p y *
        sourceSection p f i x a := by
          apply Finset.sum_congr rfl
          intro y _
          rw [hsame y]
    _ = (∑ y : ι → α, prodMass p y) *
        sourceSection p f i x a := by rw [Finset.sum_mul]
    _ = sourceSection p f i x a := by
          rw [sum_prodMass p hp1, one_mul]

/-- Pointwise genuine source section equals the canonical sum of
all interaction components containing its resampled coordinate.
No Hoeffding degree cap is required here. -/
theorem source_section_eq_canonical_containing
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) :
    sourceSection p f i x a =
      ∑ T : Finset ι,
        if i ∈ T then esComp p T f (Function.update x i a) else 0 := by
  have hnot : i ∉ (Finset.univ.erase i : Finset ι) := by simp
  have hins : insert i (Finset.univ.erase i : Finset ι) = Finset.univ := by
    exact Finset.insert_erase (Finset.mem_univ i)
  have hsrc := actual_source_section_es_projection
    p hp1 f i (Finset.univ.erase i) hnot x a
  rw [source_section_full_neighbor_average p hp1 f i x a] at hsrc
  simpa only [hins, Finset.subset_univ, and_true] using hsrc

/-- The full original source influence is the energy of exactly those
canonical components whose supports contain the resampled coordinate.
Derives source energy accounting from genuine Efron-Stein terms and
orthogonality. No supplied influence/energy identity is a hypothesis. -/
theorem actual_source_influence_es_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    pinfl p f i =
      ∑ T : Finset ι,
        if i ∈ T then
          (∑ x : ι → α, prodMass p x * (esComp p T f x)^2)
        else 0 := by
  classical
  let Y : Finset ι → (ι → α) → ℝ :=
    fun T x => if i ∈ T then esComp p T f x else 0
  let G : (ι → α) → ℝ := fun x => ∑ T : Finset ι, Y T x
  have hsource (x : ι → α) (a : α) :
      sourceSection p f i x a = G (Function.update x i a) := by
    simpa only [G, Y] using
      source_section_eq_canonical_containing p hp1 f i x a
  have hresample :
      sourceSectionEnergy p f i =
        ∑ x : ι → α, prodMass p x * (G x)^2 := by
    unfold sourceSectionEnergy
    calc
      (∑ x : ι → α, prodMass p x *
        (∑ a : α, p i a * (sourceSection p f i x a)^2)) =
        ∑ x : ι → α, ∑ a : α, prodMass p x * p i a *
          (G (Function.update x i a))^2 := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            rw [hsource x a]
            ring
      _ = ∑ x : ι → α, prodMass p x * (G x)^2 :=
        resample_sum p hp1 i (fun x => (G x)^2)
  have horth : ∀ T U : Finset ι, T ≠ U →
    (∑ x : ι → α, prodMass p x * Y T x * Y U x) = 0 := by
    intro T U hne
    by_cases ht : i ∈ T
    · by_cases hu : i ∈ U
      · simpa only [Y, if_pos ht, if_pos hu] using
          actual_esComp_orthogonal p hp1 f T U hne
      · simp [Y, hu]
    · simp [Y, ht]
  have hparseval := weighted_orthogonal_sum_sq
    (prodMass p) Y horth
  calc
    pinfl p f i = sourceSectionEnergy p f i :=
      (actual_source_section_energy_eq_influence p hp1 f i).symm
    _ = ∑ x : ι → α, prodMass p x * (G x)^2 := hresample
    _ = ∑ T : Finset ι, ∑ x : ι → α,
      prodMass p x * (Y T x)^2 := hparseval
    _ = ∑ T : Finset ι, if i ∈ T then
      (∑ x : ι → α, prodMass p x * (esComp p T f x)^2)
      else 0 := by
        apply Finset.sum_congr rfl
        intro T _
        by_cases ht : i ∈ T <;> simp [Y, ht]

/-- Degree-two source influence is exactly singleton+pair energy
on supports containing the coordinate. Not an assumed budget. -/
theorem actual_degree_two_influence_es_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) :
    pinfl p f i =
      ∑ T : Finset ι,
        if i ∈ T ∧ T.card ≤ 2 then
          (∑ x : ι → α, prodMass p x * (esComp p T f x)^2)
        else 0 := by
  rw [actual_source_influence_es_energy p hp1 f i]
  apply Finset.sum_congr rfl
  intro T _
  by_cases hi : i ∈ T
  · by_cases hc : T.card ≤ 2
    · simp [hi, hc]
    · have hz (x : ι → α) :
          esComp p T f x = 0 := by
        exact hdegree T (by omega) x
      simp [hi, hc, hz]
  · simp [hi]

/-- Any chosen subset of genuine pair supports containing i has total
nonnegative L2 energy at most the actual original-source influence.
This is the desired source-side owner energy cap, independently of how
ownership was generated; source graph reindexing still needs a bridge. -/
theorem actual_owned_pair_subset_energy_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (S : Finset (Finset ι))
    (hS : ∀ T ∈ S, i ∈ T ∧ T.card = 2) :
    S.sum (fun T =>
      ∑ x : ι → α, prodMass p x * (esComp p T f x)^2)
      ≤ pinfl p f i := by
  classical
  let E : Finset ι → ℝ := fun T =>
    ∑ x : ι → α, prodMass p x * (esComp p T f x)^2
  have hnonneg (T : Finset ι) : 0 ≤ E T := by
    dsimp [E]
    exact Finset.sum_nonneg (fun x _ =>
      mul_nonneg (prodMass_nonneg' p hp x) (sq_nonneg _))
  have hsubset :
      S ⊆ (Finset.univ.filter
        (fun T : Finset ι => i ∈ T ∧ T.card ≤ 2)) := by
    intro T hT
    obtain ⟨hmem,hcard⟩ := hS T hT
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨hmem, by omega⟩
  calc
    S.sum E ≤
      (Finset.univ.filter
        (fun T : Finset ι => i ∈ T ∧ T.card ≤ 2)).sum E := by
          apply Finset.sum_le_sum_of_subset_of_nonneg hsubset
          intro T _ _
          exact hnonneg T
    _ = pinfl p f i := by
          rw [actual_degree_two_influence_es_energy p hp1 f hdegree i]
          simp only [Finset.sum_filter]
          rfl

end Nightfall.Observability.ActualESInfluenceEnergy
