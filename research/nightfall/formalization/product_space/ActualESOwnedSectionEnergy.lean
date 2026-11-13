import ActualESCanonicalPairGraph
import ActualESPairEnergyFubini
import ActualESOrthogonalEnergy

/-!
# The genuine conditional-section energy of each greedy owner

This module links the existing exact greedy ownership to the ORIGINAL
finite product-source conditional sections. The owned section for an
original source coordinate i is the sum of the true canonical
Hoeffding pair components on all original edges assigned to i.

Taking the p_i conditional L2 norm and integrating over original
X_{-i} gives *exactly* the sum of source pair L2 energies assigned
to i. The proof uses genuine source resampling and pairwise Efron–Stein
orthogonality; no independent-copy approximation, extra conditional
energy premise, or asserted variance/influence cap is involved.

The separate ActualESOwnedInfluenceBound theorem proves this
quantity is at most the original source influence pinfl_i.
-/

namespace Nightfall.Observability.ActualESOwnedSectionEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESOwnedEnergy
open Nightfall.Observability.ActualESPairEnergyFubini
open Nightfall.Observability.ActualESOrthogonalEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Actual original-source pair interaction *section* assigned to i. -/
noncomputable def ownedPairSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι)
    (x : ι → α) (a : α) : ℝ :=
  ∑ e ∈ ownedEdges first second c
    (Finset.univ : Finset (Edge ι)) i,
    esComp p e.1 f (Function.update x i a)

/-- Integrated conditional squared Hilbert norm on the ACTUAL
original source x, and the ORIGINAL marginal p_i. -/
noncomputable def actualOwnedSectionEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, prodMass p x *
    (∑ a : α, p i a * (ownedPairSection p f c i x a)^2)

/-- Exact product-resampling identity: the conditional Hilbert energy
of a scalar function G is its full original-source L2 energy. -/
theorem source_conditional_resampling_square
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (G : (ι → α) → ℝ) (i : ι) :
    (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a * (G (Function.update x i a))^2)) =
      sourceInner p G G := by
  classical
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a * (G (Function.update x i a))^2)) =
      ∑ x : ι → α, ∑ a : α,
        prodMass p x * p i a * (G (Function.update x i a))^2 := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ x : ι → α, prodMass p x * (G x)^2 :=
      resample_sum p hp1 i (fun y => (G y)^2)
    _ = ∑ x : ι → α, prodMass p x * (G x * G x) := by
      apply Finset.sum_congr rfl
      intro x _
      ring

/-- Parseval for an arbitrary owned finite edge set. Each canonical
source component appears only once because edges are indexed by their
actual unordered two-coordinate support. -/
theorem owned_canonical_components_parseval
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (f : (ι → α) → ℝ)
    (S : Finset (Edge ι)) :
    sourceInner p
      (fun x => ∑ e ∈ S, esComp p e.1 f x)
      (fun x => ∑ e ∈ S, esComp p e.1 f x) =
      ∑ e ∈ S,
        sourceInner p (esComp p e.1 f) (esComp p e.1 f) := by
  classical
  let H : {e : Edge ι // e ∈ S} → (ι → α) → ℝ :=
    fun e x => esComp p e.1.1 f x
  have hsum (x : ι → α) :
      (∑ e ∈ S, esComp p e.1 f x) =
      ∑ e : {e : Edge ι // e ∈ S}, H e x := by
    simpa only [H] using
      (Finset.sum_attach S (fun e : Edge ι => esComp p e.1 f x)).symm
  have hortho (e d : {e : Edge ι // e ∈ S}) (hne : e ≠ d) :
      sourceInner p (H e) (H d) = 0 := by
    have hsupport : e.1.1 ≠ d.1.1 := by
      intro h
      apply hne
      exact Subtype.ext (Subtype.ext h)
    exact actual_esComp_orthogonal_distinct
      p hp1 f e.1.1 d.1.1 hsupport
  have hparseval := sourceInner_parseval_of_orthogonal p H hortho
  calc
    sourceInner p
      (fun x => ∑ e ∈ S, esComp p e.1 f x)
      (fun x => ∑ e ∈ S, esComp p e.1 f x) =
      sourceInner p
        (fun x => ∑ e : {e : Edge ι // e ∈ S}, H e x)
        (fun x => ∑ e : {e : Edge ι // e ∈ S}, H e x) := by
          unfold sourceInner
          apply Finset.sum_congr rfl
          intro x _
          rw [hsum x]
    _ = ∑ e : {e : Edge ι // e ∈ S},
        sourceInner p (H e) (H e) := hparseval
    _ = ∑ e ∈ S,
        sourceInner p (esComp p e.1 f) (esComp p e.1 f) := by
          simpa only [H] using
            (Finset.sum_attach S
              (fun e : Edge ι =>
                sourceInner p (esComp p e.1 f) (esComp p e.1 f)))

/-- MAIN SOURCE ENERGY IDENTITY:
E_{X_{-i}} [ ||sum_{edges owned by i} h_edge(.,X_{-i})||_{L²(p_i)}² ]
= sum_{edges owned by i} ||h_edge||_{L²(p)}².

Both sides are built from f and original coordinate weights.
No energy comparison, source influence, or moment cap is assumed. -/
theorem actual_owned_section_energy_eq_source_pair_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    actualOwnedSectionEnergy p f c i =
      ownedSourceEnergy p f base first second c
        (Finset.univ : Finset (Edge ι)) i := by
  classical
  let S : Finset (Edge ι) :=
    ownedEdges first second c (Finset.univ : Finset (Edge ι)) i
  let G : (ι → α) → ℝ :=
    fun x => ∑ e ∈ S, esComp p e.1 f x
  have hres :
      actualOwnedSectionEnergy p f c i = sourceInner p G G := by
    unfold actualOwnedSectionEnergy
    change (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a * (G (Function.update x i a))^2)) = _
    exact source_conditional_resampling_square p hp1 G i
  rw [hres]
  have hparseval := owned_canonical_components_parseval p hp1 f S
  have hpair (e : Edge ι) :
      sourcePairEnergy p f base (first e) (second e) =
        sourceInner p (esComp p e.1 f) (esComp p e.1 f) :=
    canonical_source_pair_energy_eq_component p hp1 f base e
  calc
    sourceInner p G G =
      ∑ e ∈ S, sourceInner p (esComp p e.1 f)
        (esComp p e.1 f) := hparseval
    _ = ∑ e ∈ S, sourcePairEnergy p f base (first e) (second e) := by
          apply Finset.sum_congr rfl
          intro e _
          exact (hpair e).symm
    _ = ownedSourceEnergy p f base first second c
      (Finset.univ : Finset (Edge ι)) i := rfl

end Nightfall.Observability.ActualESOwnedSectionEnergy
