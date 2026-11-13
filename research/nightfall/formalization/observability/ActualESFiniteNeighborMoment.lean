import ActualESPairHilbertMoment
import ActualESOwnedEnergy

/-!
# Actual finite-neighbor Hilbert endpoint with zero tail

The existing fourth-moment endpoint accepts a total natural-number
neighbor map, and therefore does not guarantee distinct source sites.
This module states its real finite-scope interface: only k<n is an
actual neighbor with nontrivial source increment. The tail k>=n is
identically zero. Its centering, boundedness and fourth-moment
endpoint are proved from the original source pair kernels.

An injective enumeration of owned source sites is the *next* input
to this finite-scope theorem. It is necessary for identifying
moments of this independent draw table with conditional expectations
of the original product function, not for the algebraic fourth moment.
-/

namespace Nightfall.Observability.ActualESFiniteNeighborMoment

open Finset
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESPairHilbertMoment
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Use the original actual pair-kernel increment only within the
finite list of true neighbors; outside its length, use exactly zero. -/
noncomputable def finitePairIncrement
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ) :
    ℕ → α → α → ℝ :=
  fun k b a => if k < n then
    actualPairIncrement p f base i j k b a else 0

/-- Genuine source pair-degeneracy centers every increment,
including the identically zero part of the sequence. -/
theorem finitePairIncrement_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k)
    (k : ℕ) (a : α) :
    (∑ b : α, p (j k) b *
      finitePairIncrement p f base i j n k b a) = 0 := by
  classical
  by_cases hk : k < n
  · simp only [finitePairIncrement, if_pos hk]
    let t : ℝ := Real.sqrt (p i a)
    have hcent :
        (∑ b : α, p (j k) b *
          actualPairKernel p f base i (j k) a b) = 0 :=
      actual_pair_kernel_right_centered p hp1 f base i (j k) (hne k hk) a
    calc
      (∑ b : α, p (j k) b *
        actualPairIncrement p f base i j k b a) =
        t * (∑ b : α, p (j k) b *
          actualPairKernel p f base i (j k) a b) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            dsimp [t, actualPairIncrement]
            ring
      _ = 0 := by rw [hcent, mul_zero]
  · simp [finitePairIncrement, hk]

/-- The source pair amplitude bound gives a bound on each finite
weighted-Hilbert-vector increment, with zero increments outside n. -/
theorem finitePairIncrement_norm_bounded
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι) (j : ℕ → ι) (n : ℕ)
    (c : ℝ)
    (hkernel : ∀ k, k < n → ∀ a b,
      |actualPairKernel p f base i (j k) a b| ≤ c)
    (k : ℕ) (b : α) :
    vecNormSq (finitePairIncrement p f base i j n k b) ≤ c^2 := by
  classical
  by_cases hk : k < n
  · let jconst : ℕ → ι := fun _ => j k
    have hAll : ∀ m a b,
        |actualPairKernel p f base i (jconst m) a b| ≤ c := by
      intro m a d
      exact hkernel k hk a d
    have h := actualPairIncrement_norm_bounded
      p hp hp1 f base i jconst c hAll 0 b
    simpa only [finitePairIncrement, if_pos hk, actualPairIncrement, jconst] using h
  · have hc2 : 0 ≤ c^2 := sq_nonneg c
    simpa [finitePairIncrement, hk, vecNormSq] using hc2

/-- Exact source-derived independent-neighbor product moment budget. -/
theorem finitePairIncrement_moment2_eq_budget
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f base i j n) n =
    budget (fun k => p (j k))
      (finitePairIncrement p f base i j n) n := by
  exact moment2_eq_budget (fun k => p (j k))
    (finitePairIncrement p f base i j n)
    (fun k => hp1 (j k))
    (fun k a =>
      finitePairIncrement_centered p hp1 f base i j n hne k a)
    n

/-- ACTUAL finite-neighbor fourth-moment endpoint.
No supplied fourth-moment or interpolation premise, and no demanded
properties of the arbitrary tail of j. The only energy cap is the
explicit finite-neighbor moment2<=M premise; replacing it with a
derived pinfl bound is the next genuine source ANOVA interface. -/
theorem finitePairIncrement_fourth_endpoint
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (c M : ℝ)
    (hne : ∀ k, k < n → i ≠ j k)
    (hc : 0 ≤ c)
    (hkernel : ∀ k, k < n → ∀ a b,
      |actualPairKernel p f base i (j k) a b| ≤ c)
    (hM : moment2 (fun k => p (j k))
      (finitePairIncrement p f base i j n) n ≤ M) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f base i j n) n ≤
      (∑ w : Samples α n,
        mass (fun k => p (j k)) n w *
          Real.sqrt (vecNormSq (sumVector
            (finitePairIncrement p f base i j n) n w))) *
      (c + Real.sqrt (3 * M)) := by
  exact actual_product_fourth_endpoint
    (fun k => p (j k))
    (finitePairIncrement p f base i j n)
    c M n
    (fun k a => hp (j k) a)
    (fun k => hp1 (j k))
    (fun k a =>
      finitePairIncrement_centered p hp1 f base i j n hne k a)
    hc
    (fun k a =>
      finitePairIncrement_norm_bounded
        p hp hp1 f base i j n c hkernel k a)
    hM

/-- The SECOND MOMENT of the actual finite-neighbor Hilbert increment
table equals the sum of the literal original source-pair L2 energies.
This derives the numerical energy object used in the fourth-moment
endpoint; it does not assume a moment-to-energy identification. -/
theorem finitePairIncrement_moment2_eq_source_pair_energies
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f base i j n) n =
    (∑ k ∈ Finset.range n,
      Nightfall.Observability.ActualESOwnedEnergy.sourcePairEnergy
        p f base i (j k)) := by
  classical
  rw [finitePairIncrement_moment2_eq_budget p hp1 f base i j n hne]
  unfold budget
  apply Finset.sum_congr rfl
  intro k hk
  have hklt : k < n := Finset.mem_range.mp hk
  unfold Nightfall.Observability.ActualESOwnedEnergy.sourcePairEnergy
  unfold vecNormSq
  calc
    (∑ b : α, p (j k) b *
      (∑ a : α, (finitePairIncrement p f base i j n k b a)^2)) =
      ∑ b : α, ∑ a : α,
        p (j k) b *
          (finitePairIncrement p f base i j n k b a)^2 := by
            apply Finset.sum_congr rfl
            intro b _
            rw [Finset.mul_sum]
    _ = ∑ a : α, ∑ b : α,
        p (j k) b *
          (finitePairIncrement p f base i j n k b a)^2 :=
            Finset.sum_comm
    _ = ∑ a : α, ∑ b : α,
        p i a * p (j k) b *
          (actualPairKernel p f base i (j k) a b)^2 := by
            apply Finset.sum_congr rfl
            intro a _
            apply Finset.sum_congr rfl
            intro b _
            simp only [finitePairIncrement, if_pos hklt,
              actualPairIncrement, mul_pow,
              Real.sq_sqrt (hp i a)]
            ring

end Nightfall.Observability.ActualESFiniteNeighborMoment
