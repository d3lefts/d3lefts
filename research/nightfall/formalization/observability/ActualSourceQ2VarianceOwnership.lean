import ActualSourceOwnedMomentEnergy
import ActualSourceVarianceEnergy
import ActualSourcePairEnergyBridge

/-!
# Original-source Q2 variance-to-owned-moment identity (Lean 4.36 candidate)

This file isolates the terminal Q2 energy bookkeeping. It does not invoke
the conditional scalar closure and does not claim a full Q2 certificate.

All sectors are canonical Efron–Stein components extracted from one p,f.
Every unordered pair occurs precisely once as a subtype `Edge ι`.
The final equality replaces each pair by its genuinely owned, original-
coordinate Hilbert second moment. No variance budget, pair law, matching
bound, or artificial decomposition is supplied.
-/

namespace Nightfall.Observability.ActualSourceQ2VarianceOwnership

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Finite combinatorial decomposition of all nonempty sectors of size at
most two. In particular, no factor of two enters the pair sum. -/
theorem sum_degree_two_sectors (w : Finset ι → ℝ) :
    (∑ S : Finset ι,
      if S ≠ ∅ ∧ S.card ≤ 2 then w S else 0) =
      (∑ i : ι, w ({i} : Finset ι)) +
      (∑ e : Edge ι, w e.1) := by
  classical
  let T1 : Finset (Finset ι) :=
    Finset.univ.filter (fun S => S.card = 1)
  let T2 : Finset (Finset ι) :=
    Finset.univ.filter (fun S => S.card = 2)
  have hsplit (S : Finset ι) :
      (if S ≠ ∅ ∧ S.card ≤ 2 then w S else 0) =
        (if S.card = 1 then w S else 0) +
        (if S.card = 2 then w S else 0) := by
    by_cases h1 : S.card = 1
    · have hne : S ≠ ∅ := by
        intro hs
        subst S
        simp at h1
      have hsmall : S.card ≤ 2 := by omega
      simp [h1, hne, hsmall]
    · by_cases h2 : S.card = 2
      · have hne : S ≠ ∅ := by
          intro hs
          subst S
          simp at h2
        have hsmall : S.card ≤ 2 := by omega
        simp [h1, h2, hne, hsmall]
      · have hno : ¬(S ≠ ∅ ∧ S.card ≤ 2) := by
          intro h
          have hpos : S.card ≠ 0 := by
            intro hz
            exact h.1 (Finset.card_eq_zero.mp hz)
          omega
        simp [h1, h2, hno]
  have himage1 :
      (Finset.univ : Finset ι).image
        (fun i => ({i} : Finset ι)) = T1 := by
    ext S
    simp only [Finset.mem_image, Finset.mem_univ, true_and,
      T1, Finset.mem_filter]
    constructor
    · rintro ⟨i, rfl⟩
      simp
    · intro h
      obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
      exact ⟨i, hi.symm⟩
  have himage2 :
      (Finset.univ : Finset (Edge ι)).image
        (fun e => e.1) = T2 := by
    ext S
    simp only [Finset.mem_image, Finset.mem_univ, true_and,
      T2, Finset.mem_filter]
    constructor
    · rintro ⟨e, rfl⟩
      exact e.2
    · intro h
      exact ⟨⟨S, h⟩, rfl⟩
  have hsum1 :
      (∑ S ∈ T1, w S) = ∑ i : ι, w ({i} : Finset ι) := by
    rw [← himage1]
    exact Finset.sum_image
      (s := (Finset.univ : Finset ι))
      (g := fun i : ι => ({i} : Finset ι)) (f := w)
      (fun i _ j _ hij => by simpa using hij)
  have hsum2 :
      (∑ S ∈ T2, w S) = ∑ e : Edge ι, w e.1 := by
    rw [← himage2]
    exact Finset.sum_image
      (s := (Finset.univ : Finset (Edge ι)))
      (g := fun e : Edge ι => e.1) (f := w)
      (fun e _ d _ hed => Subtype.ext hed)
  calc
    (∑ S : Finset ι,
      if S ≠ ∅ ∧ S.card ≤ 2 then w S else 0) =
        ∑ S : Finset ι,
          ((if S.card = 1 then w S else 0) +
           (if S.card = 2 then w S else 0)) := by
          apply Finset.sum_congr rfl
          intro S _
          exact hsplit S
    _ = (∑ S : Finset ι, if S.card = 1 then w S else 0) +
        (∑ S : Finset ι, if S.card = 2 then w S else 0) := by
          rw [Finset.sum_add_distrib]
    _ = (∑ S ∈ T1, w S) + (∑ S ∈ T2, w S) := by
          simp only [T1, T2, Finset.sum_filter]
    _ = (∑ i : ι, w ({i} : Finset ι)) +
        (∑ e : Edge ι, w e.1) := by
          rw [hsum1, hsum2]

/-- Genuine degree-two product variance is the singleton Efron–Stein
sector plus one original-law two-site energy per *unordered* edge. -/
theorem actual_source_variance_singletons_and_pairs
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    sourceVariance p f =
      (∑ i : ι, ∑ x : ι → α,
        originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2) +
      (∑ e : Edge ι,
        sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
  classical
  let en : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
  have hsector := sum_degree_two_sectors (ι := ι) en
  have hpair (e : Edge ι) :
      en e.1 = sourcePairEnergy p f (edgeFirst e) (edgeSecond e) := by
    have hcanonical :=
      original_pair_finite_moment_energy_eq_canonical
        p hp1 f (edgeFirst e) (edgeSecond e)
          (edgeFirst_ne_edgeSecond e)
    rw [edge_pair_eq_endpoints e]
    exact hcanonical.symm
  calc
    sourceVariance p f =
        (∑ S : Finset ι,
          if S ≠ ∅ ∧ S.card ≤ 2 then en S else 0) := by
          simpa only [en] using
            (actual_degree_two_source_variance_energy p hp1 f hdegree)
    _ = (∑ i : ι, en ({i} : Finset ι)) +
        (∑ e : Edge ι, en e.1) := hsector
    _ = (∑ i : ι, en ({i} : Finset ι)) +
        (∑ e : Edge ι,
          sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
          apply congrArg
            (fun t : ℝ => (∑ i : ι, en ({i} : Finset ι)) + t)
          apply Finset.sum_congr rfl
          intro e _
          exact hpair e
    _ = (∑ i : ι, ∑ x : ι → α,
        originalMass p x * (esComp p ({i} : Finset ι) f x)^2) +
        (∑ e : Edge ι,
          sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := rfl

/-- Exact end-to-end *energy* composition: actual source variance equals
singleton sector energy plus the second moment of the truly owned
independent-neighbor Hilbert stars. This is an equality, not yet Q2. -/
theorem actual_source_variance_singletons_and_owned_moments
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) :
    sourceVariance p f =
      (∑ i : ι, ∑ x : ι → α,
        originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2) +
      (∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        moment2 (fun k => p (j k))
          (finitePairIncrement p f i j J.card) J.card) := by
  classical
  let pairEn : Edge ι → ℝ := fun e =>
    sourcePairEnergy p f (edgeFirst e) (edgeSecond e)
  have hpart :
      (∑ i : ι,
        (ownedEdges edgeFirst edgeSecond c
          (Finset.univ : Finset (Edge ι)) i).sum pairEn) =
        ∑ e : Edge ι, pairEn e :=
    owned_energy_partition edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι)) pairEn
  have hmom (i : ι) :
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card) =
      (ownedEdges edgeFirst edgeSecond c
        (Finset.univ : Finset (Edge ι)) i).sum pairEn := by
    simpa only [pairEn] using
      (original_owned_neighbor_moment2_eq_owned_energy
        p hp hp1 f c i)
  calc
    sourceVariance p f =
        (∑ i : ι, ∑ x : ι → α,
          originalMass p x *
          (esComp p ({i} : Finset ι) f x)^2) +
        (∑ e : Edge ι, pairEn e) := by
          simpa only [pairEn] using
            (actual_source_variance_singletons_and_pairs
              p hp1 f hdegree)
    _ = (∑ i : ι, ∑ x : ι → α,
          originalMass p x *
          (esComp p ({i} : Finset ι) f x)^2) +
        (∑ i : ι,
          (ownedEdges edgeFirst edgeSecond c
            (Finset.univ : Finset (Edge ι)) i).sum pairEn) := by
          rw [hpart]
    _ = (∑ i : ι, ∑ x : ι → α,
          originalMass p x *
          (esComp p ({i} : Finset ι) f x)^2) +
        (∑ i : ι,
          let J := ownedNeighbors c i
          let j := neighborIndex i J
          moment2 (fun k => p (j k))
            (finitePairIncrement p f i j J.card) J.card) := by
          apply congrArg
            (fun t : ℝ =>
              (∑ i : ι, ∑ x : ι → α,
                originalMass p x *
                (esComp p ({i} : Finset ι) f x)^2) + t)
          apply Finset.sum_congr rfl
          intro i _
          exact (hmom i).symm

end Nightfall.Observability.ActualSourceQ2VarianceOwnership
