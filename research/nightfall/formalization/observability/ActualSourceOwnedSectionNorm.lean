import ActualSourceOwnedMomentEnergy

/-!
# Pointwise Hilbert samples equal source-owned pair-section norms

The recursive Hilbert sample at genuine original-coordinate symbols
equals the weighted L2(p_i) norm of the actual source-derived pair
kernels. This is only the pointwise/first-norm identification, not
yet the conditional projection/Jensen endpoint of terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceOwnedSectionNorm

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Exact recursive sample-vector unrolling on genuine source sites. -/
theorem original_observed_sample_sumVector_eq_range
    {K : Type} [Fintype K]
    (Y : ℕ → α → K → ℝ)
    (j : ℕ → ι) (x : ι → α) (a : K) :
    ∀ n : ℕ,
      sumVector Y n (observedActualSample j n x) a =
        ∑ k ∈ Finset.range n, Y k (x (j k)) a := by
  intro n
  induction n with
  | zero =>
      simp [sumVector, observedActualSample]
  | succ n ih =>
      change sumVector Y n (observedActualSample j n x) a +
        Y n (x (j n)) a =
          ∑ k ∈ Finset.range (n + 1), Y k (x (j k)) a
      rw [Finset.sum_range_succ, ih]

/-- Actual source-derived centered pair tables, not foreign kernels,
are the exact components of the finite Hilbert sum. -/
theorem original_source_finitePair_observed_sum
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (x : ι → α) (a : α) :
    sumVector (finitePairIncrement p f i j n)
      n (observedActualSample j n x) a =
      Real.sqrt (p i a) *
        (∑ k ∈ Finset.range n,
          sourceDoubleCenteredPair p f i (j k) a (x (j k))) := by
  rw [original_observed_sample_sumVector_eq_range]
  calc
    (∑ k ∈ Finset.range n,
      finitePairIncrement p f i j n k (x (j k)) a) =
      ∑ k ∈ Finset.range n,
        Real.sqrt (p i a) *
          sourceDoubleCenteredPair p f i (j k) a (x (j k)) := by
        apply Finset.sum_congr rfl
        intro k hk
        simp [finitePairIncrement, Finset.mem_range.mp hk,
          sourcePairIncrement]
    _ = Real.sqrt (p i a) *
        (∑ k ∈ Finset.range n,
          sourceDoubleCenteredPair p f i (j k) a (x (j k))) := by
          rw [Finset.mul_sum]

/-- Exact source pair-section L2² identity pointwise in source X. -/
theorem original_source_finitePair_observed_sqNorm
    (p : ι → α → ℝ) (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ)
    (i : ι) (j : ℕ → ι) (n : ℕ) (x : ι → α) :
    vecNormSq
      (sumVector (finitePairIncrement p f i j n)
        n (observedActualSample j n x)) =
      ∑ a : α, p i a *
        (∑ k ∈ Finset.range n,
          sourceDoubleCenteredPair p f i (j k) a (x (j k)))^2 := by
  classical
  unfold vecNormSq
  apply Finset.sum_congr rfl
  intro a _
  rw [original_source_finitePair_observed_sum p f i j n x a,
    mul_pow, Real.sq_sqrt (hp i a)]
  ring

/-- The recursive Hilbert first norm is literally the original-law
expected L2 norm of the source-owned pair kernel sum. -/
theorem original_source_finitePair_first_norm_is_actual_section
    (p : ι → α → ℝ) (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ)
    (i : ι) (j : ℕ → ι) (n : ℕ) :
    (∑ x : ι → α, originalMass p x *
      Real.sqrt (vecNormSq
        (sumVector (finitePairIncrement p f i j n)
          n (observedActualSample j n x)))) =
    ∑ x : ι → α, originalMass p x *
      Real.sqrt (∑ a : α, p i a *
        (∑ k ∈ Finset.range n,
          sourceDoubleCenteredPair p f i (j k) a (x (j k)))^2) := by
  classical
  apply Finset.sum_congr rfl
  intro x _
  rw [original_source_finitePair_observed_sqNorm p hp f i j n x]

end Nightfall.Observability.ActualSourceOwnedSectionNorm
