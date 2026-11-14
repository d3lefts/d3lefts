import ActualSourceFinitePairMoment
import ActualSourceCanonicalIdentification
import ActualProductPairSector

/-!
# True product-law canonical energy of one derived pair

The source-double-centered finite Hilbert moment table and the
current-source Efron–Stein projector have exactly the same L² energy.
This is a *source-only* Fubini identity: no mass floor, no auxiliary
pair energy assumption, no independent duplicate of an actual site.
It is valid for all finite coordinate types, and all distinct i,j.

This does not itself prove that a greedy-owned sum is bounded by a
coordinate's influence; that still requires finite-set reindexing.
-/

namespace Nightfall.Observability.ActualSourcePairEnergyBridge

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductPairSector
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCanonicalIdentification
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceFinitePairMoment

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The finite Hilbert moment pair energy is literally the full
original-source ANOVA pair energy. Every other source coordinate
has been integrated out by the genuine two-coordinate marginal law. -/
theorem original_pair_finite_moment_energy_eq_canonical
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (i j : ι) (hij : i ≠ j) :
    ActualSourceFinitePairMoment.sourcePairEnergy p f i j =
      ∑ x : ι → α, originalMass p x *
        (esComp p ({i,j} : Finset ι) f x)^2 := by
  classical
  unfold ActualSourceFinitePairMoment.sourcePairEnergy
  calc
    (∑ a : α, ∑ b : α,
      p i a * p j b *
        (sourceDoubleCenteredPair p f i j a b)^2) =
      ∑ x : ι → α, originalMass p x *
        (sourceDoubleCenteredPair p f i j (x i) (x j))^2 := by
      exact (actual_product_two_site_marginal p hp1 i j hij
        (fun a b => (sourceDoubleCenteredPair p f i j a b)^2)).symm
    _ = ∑ x : ι → α, originalMass p x *
      (esComp p ({i,j} : Finset ι) f x)^2 := by
      apply Finset.sum_congr rfl
      intro x _
      rw [actual_source_esComp_pair_eq_derived p hp1 f i j hij x]


/-- The actual two-site Möbius projector removes any arbitrary
orientation of a genuine unordered pair. This is pointwise, including
zero-mass symbols, rather than only an equality after integration. -/
theorem original_source_pair_kernel_swap
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i j : ι) (hij : i ≠ j) (a b : α) :
    sourceDoubleCenteredPair p f i j a b =
      sourceDoubleCenteredPair p f j i b a := by
  classical
  let x : ι → α :=
    Function.update (Function.update
      (fun _ : ι => a) i a) j b
  have hi : x i = a := by simp [x, hij]
  have hj : x j = b := by simp [x]
  have hforward :=
    actual_source_esComp_pair_eq_derived p hp1 f i j hij x
  have hreverse :=
    actual_source_esComp_pair_eq_derived p hp1 f j i hij.symm x
  rw [hi, hj] at hforward hreverse
  rw [Finset.pair_comm] at hreverse
  exact hforward.symm.trans hreverse

/-- Genuine pair moment energies are symmetric in their original
coordinate labels. The weights are the source's own marginals. -/
theorem original_source_pair_energy_swap
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i j : ι) (hij : i ≠ j) :
    ActualSourceFinitePairMoment.sourcePairEnergy p f i j =
      ActualSourceFinitePairMoment.sourcePairEnergy p f j i := by
  classical
  unfold ActualSourceFinitePairMoment.sourcePairEnergy
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro b _
  apply Finset.sum_congr rfl
  intro a _
  rw [original_source_pair_kernel_swap p hp1 f i j hij a b]
  ring

end Nightfall.Observability.ActualSourcePairEnergyBridge
