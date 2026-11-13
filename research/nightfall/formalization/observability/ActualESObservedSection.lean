import ActualESFiniteSampleLaw
import ActualESFiniteNeighborMoment
import ActualESConditionalJensen

/-!
# Exact pointwise identification of source-observed Hilbert increments

The recursive sumVector sampled at genuinely observed coordinate labels
is *definitionally the same finite sum* of canonical Efron–Stein
pair-kernel values at those labels. This is a pointwise identity, not
merely an equality of expectations or of second moments. The weighted
norm formula then identifies the observable used for the fourth-moment
endpoint with the actual source section norm.

Proof scope: arbitrary finite categorical product laws, including zero
weights, with the original Efron–Stein kernel. The neighbor coordinate
labels must be distinct when the independent-product law is invoked;
the pointwise identities themselves do not need distinctness.
-/

namespace Nightfall.Observability.ActualESObservedSection

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.ActualESFiniteSampleLaw
open Nightfall.Observability.ActualESConditionalJensen

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Recursive sample-vector arithmetic is exactly the sum of the
corresponding increments at the original source's observed symbols. -/
theorem observedSample_sumVector_eq_range
    {K : Type} [Fintype K]
    (Y : ℕ → α → K → ℝ)
    (j : ℕ → ι) (x : ι → α) (a : K) :
    ∀ n : ℕ,
    sumVector Y n (observedSample j n x) a =
      ∑ k ∈ Finset.range n, Y k (x (j k)) a := by
  intro n
  induction n with
  | zero =>
      simp [sumVector, observedSample]
  | succ n ih =>
      change sumVector Y n (observedSample j n x) a +
        Y n (x (j n)) a =
          ∑ k ∈ Finset.range (n + 1), Y k (x (j k)) a
      rw [Finset.sum_range_succ, ih]

/-- Specialization to the genuine source-derived pair-kernel Hilbert
increments, with the tail truncated at exactly n. -/
theorem finitePairIncrement_observed_eq_source_sum
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (x : ι → α) (a : α) :
    sumVector (finitePairIncrement p f base i j n)
      n (observedSample j n x) a =
      Real.sqrt (p i a) *
        (∑ k ∈ Finset.range n,
          actualPairKernel p f base i (j k) a (x (j k))) := by
  rw [observedSample_sumVector_eq_range]
  calc
    (∑ k ∈ Finset.range n,
      finitePairIncrement p f base i j n k (x (j k)) a) =
      ∑ k ∈ Finset.range n,
        Real.sqrt (p i a) *
          actualPairKernel p f base i (j k) a (x (j k)) := by
            apply Finset.sum_congr rfl
            intro k hk
            simp [finitePairIncrement, Finset.mem_range.mp hk,
              ActualESPairHilbertMoment.actualPairIncrement]
    _ = Real.sqrt (p i a) *
      (∑ k ∈ Finset.range n,
        actualPairKernel p f base i (j k) a (x (j k))) := by
          rw [Finset.mul_sum]

/-- Pointwise square-norm identity: the artificial-looking recursive
Hilbert vector is exactly the actual weighted source pair section. -/
theorem finitePair_observed_sqNorm_eq_source_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (x : ι → α) :
    vecNormSq
      (sumVector (finitePairIncrement p f base i j n)
        n (observedSample j n x)) =
      sqNorm (p i)
        (fun a => ∑ k ∈ Finset.range n,
          actualPairKernel p f base i (j k) a (x (j k))) := by
  classical
  unfold vecNormSq sqNorm
  apply Finset.sum_congr rfl
  intro a _
  rw [finitePairIncrement_observed_eq_source_sum p f base i j n x a,
      mul_pow, Real.sq_sqrt (hp i a)]
  ring

/-- The first norm observable of the recursive endpoint is *literally*
the weighted L2 norm of the original source's owned pair section. -/
theorem finitePair_observed_norm_eq_source_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (x : ι → α) :
    Real.sqrt (vecNormSq
      (sumVector (finitePairIncrement p f base i j n)
        n (observedSample j n x))) =
      norm (p i)
        (fun a => ∑ k ∈ Finset.range n,
          actualPairKernel p f base i (j k) a (x (j k))) := by
  exact congrArg Real.sqrt
    (finitePair_observed_sqNorm_eq_source_section
      p hp f base i j n x)

end Nightfall.Observability.ActualESObservedSection
