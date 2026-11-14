import ActualSourceOwnedGraph
import ActualSourcePairEnergyBridge

/-!
# An unordered true-source edge has an owner-independent energy

The finite Hilbert endpoint indexes an edge as (owner, other).
The source greedy cover originally maximizes its kernel as
(edgeFirst, edgeSecond). These are provably the same amplitude
and L² energy after the appropriate source-derived swap. This
is the precise orientation bridge required before s_i can be
compared to actual coordinate influence.
-/

namespace Nightfall.Observability.ActualSourceOwnerOrientation

open Finset
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualProductSourcePairCentering

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Exact equality of source-pair energies under greedy owner orientation. -/
theorem owned_original_pair_energy_orientation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ) (e : Edge ι) :
    sourcePairEnergy p f (edgeFirst e) (edgeSecond e) =
    sourcePairEnergy p f
      (owner edgeFirst edgeSecond c e)
      (other edgeFirst edgeSecond c e) := by
  classical
  by_cases h : c (edgeSecond e) ≤ c (edgeFirst e)
  · simp [owner, other, h]
  · simpa [owner, other, h] using
      original_source_pair_energy_swap p hp1 f
        (edgeFirst e) (edgeSecond e) (edgeFirst_ne_edgeSecond e)

/-- A bound on the attained actual-source amplitude in graph orientation
also controls the exactly same kernel in the owner-oriented Hilbert
increment. No source-specific alternate kernel is assumed. -/
theorem owned_original_pair_amplitude_orientation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ) (e : Edge ι)
    (hcover : ∀ a b : α,
      |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
      c (owner edgeFirst edgeSecond c e))
    (a b : α) :
    |sourceDoubleCenteredPair p f
      (owner edgeFirst edgeSecond c e)
      (other edgeFirst edgeSecond c e) a b| ≤
      c (owner edgeFirst edgeSecond c e) := by
  classical
  by_cases h : c (edgeSecond e) ≤ c (edgeFirst e)
  · simpa [owner, other, h] using hcover a b
  · have hswap :=
      original_source_pair_kernel_swap p hp1 f
        (edgeSecond e) (edgeFirst e)
        (edgeFirst_ne_edgeSecond e).symm a b
    simpa [owner, other, h, hswap] using hcover b a

end Nightfall.Observability.ActualSourceOwnerOrientation
