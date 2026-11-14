import ActualSourceSingletonEnergyBridge

/-!
# L1 Hilbert first moment <= square-root of actual second-moment cap

The finite sampled mass is exactly normalized by the original product
marginals, even when some atoms have mass zero. The l1-l2 step is a
finite weighted Cauchy–Schwarz inequality, not a supplied moment oracle.
-/

namespace Nightfall.Observability.ActualSourceOwnedFirstMomentCap

open Finset
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceFinitePairMoment

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem original_independent_hilbert_l1_sq_le_l2
    (q : ℕ → α → ℝ)
    (hq : ∀ k a, 0 ≤ q k a)
    (hq1 : ∀ k, (∑ a : α, q k a) = 1)
    (Y : ℕ → α → α → ℝ) (n : ℕ) :
    (∑ w : Samples α n, mass q n w *
      Real.sqrt (vecNormSq (sumVector Y n w)))^2 ≤
        moment2 q Y n := by
  classical
  let μ : Samples α n → ℝ := mass q n
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (sumVector Y n w))
  have hμ : ∀ w, 0 ≤ μ w := mass_nonneg q hq n
  have hμ1 : (∑ w : Samples α n, μ w) = 1 := mass_one q hq1 n
  have hV : ∀ w, 0 ≤ v w := fun w => Real.sqrt_nonneg _
  have h := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
    (s := (Finset.univ : Finset (Samples α n)))
    (r := fun w => μ w * v w)
    (f := μ)
    (g := fun w => μ w * (v w)^2)
    (fun w _ => hμ w)
    (fun w _ => mul_nonneg (hμ w) (sq_nonneg (v w)))
    (fun w _ => by ring)
  rw [hμ1, one_mul] at h
  have hv2 (w : Samples α n) :
      (v w)^2 = vecNormSq (sumVector Y n w) :=
    Real.sq_sqrt (vecNormSq_nonneg _)
  have hright :
      (∑ w : Samples α n, μ w * (v w)^2) = moment2 q Y n := by
    unfold moment2
    apply Finset.sum_congr rfl
    intro w _
    rw [hv2]
  simpa only [μ, v, hright] using h

/-- The exact source-derived owned Hilbert first moment is bounded
by sqrt(M), when M bounds its ORIGINAL coordinate influence. -/
theorem original_owned_first_norm_le_sqrt_source_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι)
    (M : ℝ) (hM0 : 0 ≤ M)
    (hM : sourceInfluence p f i ≤ M) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    (∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤
      Real.sqrt M := by
  classical
  dsimp
  let J := ownedNeighbors c i
  let j := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let z : ℝ := ∑ w : Samples α J.card,
    mass (fun k => p (j k)) J.card w *
      Real.sqrt (vecNormSq (sumVector Y J.card w))
  have hz : 0 ≤ z := by
    dsimp [z]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg
      (mass_nonneg (fun k => p (j k)) (fun k a => hp (j k) a) J.card w)
      (Real.sqrt_nonneg _)
  have hsq : z^2 ≤ M := by
    have hCS := original_independent_hilbert_l1_sq_le_l2
      (fun k => p (j k)) (fun k a => hp (j k) a)
      (fun k => hp1 (j k)) Y J.card
    have henergy := original_owned_neighbor_moment2_le_influence
      p hp hp1 f c i
    exact hCS.trans (henergy.trans hM)
  have hroot : 0 ≤ Real.sqrt M := Real.sqrt_nonneg M
  have hroot_sq : (Real.sqrt M)^2 = M := Real.sq_sqrt hM0
  change z ≤ Real.sqrt M
  nlinarith

end Nightfall.Observability.ActualSourceOwnedFirstMomentCap
