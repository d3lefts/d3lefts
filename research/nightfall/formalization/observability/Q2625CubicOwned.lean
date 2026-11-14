import ActualSourceOwnedFourthClosure
import QuadraticActualMomentEndpoint

/-!
# Expose the actual-source owned cubic fourth-moment certificate

The existing fourth-moment endpoint derives this cubic inequality internally.
This module exports it as a named, directly source-indexed Lean theorem,
without adding a moment/interpolation axiom. It still takes the generated
owner cover as an explicit hypothesis, to be composed in a later source gate.
-/

namespace Nightfall.Q2625CubicOwned

open Finset
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualESGreedyOwnership

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Independent centered Hilbert increments satisfy the exact cubic
moment inequality; it is stronger than the linear fourth endpoint. -/
theorem actual_product_owned_cubic
    {K : Type} [Fintype K]
    (q : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (c : ℝ) (n : ℕ)
    (hq : ∀ k a, 0 ≤ q k a)
    (hq1 : ∀ k, (∑ a : α, q k a) = 1)
    (hY : ∀ k a, (∑ b : α, q k b * Y k b a) = 0)
    (hbound : ∀ k b, vecNormSq (Y k b) ≤ c^2) :
    (moment2 q Y n)^3 ≤
      (∑ w : Samples α n, mass q n w *
        Real.sqrt (vecNormSq (sumVector Y n w)))^2 *
      (c^2 * moment2 q Y n + 3 * (moment2 q Y n)^2) := by
  have hinter := actual_product_l1_l2_l4 q Y hq n
  have hfourth := arbitrary_law_many_hilbert_fourth
    q Y c hq hq1 hY hbound n
  have hbudget := moment2_eq_budget q Y hq1 hY n
  have hupper : moment4 q Y n ≤
      c^2 * moment2 q Y n + 3 * (moment2 q Y n)^2 := by
    simpa only [← hbudget] using hfourth
  exact hinter.trans (mul_le_mul_of_nonneg_left hupper (sq_nonneg _))

/-- The cubic bound on genuinely owned distinct-neighbor increments
of the original source p/f. No independent synthetic law is supplied. -/
theorem actual_source_owned_neighbor_cubic
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
      |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
        c (owner edgeFirst edgeSecond c e))
    (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    (moment2 (fun k => p (j k)) Y J.card)^3 ≤
      (∑ w : Samples α J.card,
        mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w)))^2 *
      ((c i)^2 * moment2 (fun k => p (j k)) Y J.card +
        3 * (moment2 (fun k => p (j k)) Y J.card)^2) := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk
    exact original_owner_not_in_neighbors c i
      (neighborIndex_mem i J k hk)
  have hkernel : ∀ k, k < J.card → ∀ a b,
      |sourceDoubleCenteredPair p f i (j k) a b| ≤ c i := by
    intro k hk a b
    exact actual_owned_neighbor_kernel_amplitude
      p hp1 f c hcover i k hk a b
  exact actual_product_owned_cubic
    (fun k => p (j k))
    (finitePairIncrement p f i j J.card)
    (c i) J.card
    (fun k a => hp (j k) a)
    (fun k => hp1 (j k))
    (fun k a => finitePairIncrement_centered p hp1 f i j J.card hne k a)
    (fun k a => finitePairIncrement_norm_bounded
      p hp hp1 f i j J.card (c i) hkernel k a)

end Nightfall.Q2625CubicOwned
