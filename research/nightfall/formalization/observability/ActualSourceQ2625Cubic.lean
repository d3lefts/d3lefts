import ActualSourceOwnedFourthClosure
import Q2625GoldenTrade

/-!
# Source-exact cubic interpolation for greedy owned Hilbert increments

No additional probability, moment, or source law oracle: all terms are
the actual p,f and actual greedy owner c.
-/

namespace Nightfall.Observability.ActualSourceQ2625Cubic

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceOwnerOrientation
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Q2625GoldenTrade
open Nightfall.Q2625Golden

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Exact original-source owned-neighbor cubic: intermediate step
previously buried inside the weaker fourth-moment terminal inequality. -/
theorem actual_source_owned_cubic
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
      |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
        c (owner edgeFirst edgeSecond c e))
    (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    let s := moment2 (fun k => p (j k)) Y J.card
    let z := ∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w))
    s^3 ≤ z^2 * ((c i)^2*s + 3*s^2) := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let q : ℕ → α → ℝ := fun k => p (j k)
  let s : ℝ := moment2 q Y J.card
  let z : ℝ := ∑ w : Samples α J.card,
      mass q J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w))
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk
    have hm : j k ∈ J := neighborIndex_mem i J k hk
    exact (original_owner_not_in_neighbors c i) hm
  have hkernel : ∀ k, k < J.card → ∀ a b,
      |sourceDoubleCenteredPair p f i (j k) a b| ≤ c i := by
    intro k hk a b
    exact actual_owned_neighbor_kernel_amplitude
      p hp1 f c hcover i k hk a b
  have hcent : ∀ k a, ∑ b : α, q k b * Y k b a = 0 := by
    intro k a
    exact finitePairIncrement_centered p hp1 f i j J.card hne k a
  have hbounded : ∀ k a, vecNormSq (Y k a) ≤ (c i)^2 := by
    intro k a
    exact finitePairIncrement_norm_bounded
      p hp hp1 f i j J.card (c i) hkernel k a
  have h2 := moment2_eq_budget q Y (fun k => hp1 (j k)) hcent J.card
  have h4 := arbitrary_law_many_hilbert_fourth q Y (c i)
    (fun k a => hp (j k) a) (fun k => hp1 (j k))
    hcent hbounded J.card
  have hfourth :
      moment4 q Y J.card ≤ (c i)^2*s+3*s^2 := by
    dsimp [s]
    simpa only [← h2] using h4
  have hinterp := actual_product_l1_l2_l4 q Y
    (fun k a => hp (j k) a) J.card
  have hnonneg : 0 ≤ z^2 := sq_nonneg z
  have hfourthmul := mul_le_mul_of_nonneg_left hfourth hnonneg
  dsimp [z, s, q, Y, j, J] at *
  exact hinterp.trans hfourthmul

end Nightfall.Observability.ActualSourceQ2625Cubic
