import ActualESPairMatchingBridge
import ActualESPairEnergyFubini
import ActualESCanonicalPairGraph

/-!
# Orientation-free source interactions on unordered canonical edges

The true Efron–Stein pair is a component on the unordered support
{i,j}. Swapping its two endpoint coordinates and two input symbols
does not alter its value. Pair L2 energy is likewise independent of
orientation. Both identities are obtained from the source, not from a
supplied symmetric interaction table.

This permits a greedily owned edge to be read consistently as an
increment indexed by (owner, other), whichever endpoint was first in
the canonical graph representation.
-/

namespace Nightfall.Observability.ActualESPairOrientation

open Finset
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESPairEnergyFubini
open Nightfall.Observability.ActualESOwnedEnergy
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESGreedyOwnership

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

theorem actual_pair_kernel_swap
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α)
    (i j : ι) (hij : i ≠ j) (a b : α) :
    actualPairKernel p f base i j a b =
      actualPairKernel p f base j i b a := by
  unfold actualPairKernel
  have hs : ({i,j} : Finset ι) = {j,i} := Finset.pair_comm i j
  rw [hs]
  rw [Function.update_comm hij]

/-- The actual source pair energy depends only on the unordered
coordinate support, not which endpoint appears first. -/
theorem actual_pair_energy_swap
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) (hij : i ≠ j) :
    sourcePairEnergy p f base i j =
      sourcePairEnergy p f base j i := by
  rw [actual_source_pair_energy_eq_canonical_inner
    p hp1 f base i j hij]
  rw [actual_source_pair_energy_eq_canonical_inner
    p hp1 f base j i hij.symm]
  rw [Finset.pair_comm]

/-- The source energy of a canonical edge is exactly the energy of
the owner-neighbor ordered pair selected by the generated cover. -/
theorem actual_owned_edge_energy_eq_owner_neighbor
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (c : ι → ℝ) (e : Edge ι) :
    sourcePairEnergy p f base (first e) (second e) =
      sourcePairEnergy p f base
        (owner first second c e) (other first second c e) := by
  classical
  by_cases h : c (second e) ≤ c (first e)
  · simp [owner, other, h]
  · simp [owner, other, h]
    exact actual_pair_energy_swap
      p hp1 f base (first e) (second e) (first_ne_second e)

/-- Bound at the generated owner, correctly oriented for the
Hilbert-valued finite-neighbor increment table. -/
theorem actual_owner_oriented_kernel_bound
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (c : ι → ℝ)
    (e : Edge ι) (a b : α)
    (hbound : ∀ s t : α,
      |actualPairKernel p f base (first e) (second e) s t| ≤
        c (owner first second c e)) :
    |actualPairKernel p f base
      (owner first second c e) (other first second c e) a b| ≤
      c (owner first second c e) := by
  classical
  by_cases h : c (second e) ≤ c (first e)
  · simpa [owner, other, h] using hbound a b
  · simpa [owner, other, h,
        actual_pair_kernel_swap p f base
          (first e) (second e) (first_ne_second e)] using hbound b a

end Nightfall.Observability.ActualESPairOrientation
