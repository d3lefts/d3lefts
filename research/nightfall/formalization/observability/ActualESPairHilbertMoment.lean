import ActualESPairMatchingBridge
import QuadraticActualMomentEndpoint

/-!
# Genuine Efron-Stein source pair kernels -> independent Hilbert moments

This explicitly constructs a Hilbert increment table from the **actual**
Efron-Stein pair kernels of one finite-product source function f. It proves
the increment centering and L2(output-law) norm bound from the source law.
Consequently it invokes a previously derived (not assumed) finite
fourth-moment/interpolation endpoint.

Scope: the neighbor coordinates are sampled independently by a *new*
finite product table, with each row law taken from source p. An injectivity
condition is included to make them distinct coordinates of the original
source; identifying these new-product moments with a conditional section
of the original source still needs a separate source-measurability bridge.
The amplitude bound |h_ij| ≤ c and the energy cap ≤ M are explicit
hypotheses. Neither is the desired global Q2 conclusion: the first must
be supplied by a matching cover and the second by source ANOVA.
This is NOT a complete Q2 theorem or a new priority claim.
-/

namespace Nightfall.Observability.ActualESPairHilbertMoment

open Finset
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Source-derived increments: sampled neighbor symbol b is the input,
and coordinate a of the output vector is weighted by sqrt(p_i(a)). -/
noncomputable def actualPairIncrement
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι) (j : ℕ → ι) :
    ℕ → α → α → ℝ :=
  fun n b a => Real.sqrt (p i a) *
    actualPairKernel p f base i (j n) a b

/-- Genuine pair-degeneracy forces each Hilbert increment to have zero
mean. Centering is not passed as an oracle or an assumed moment. -/
theorem actualPairIncrement_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι)
    (hne : ∀ n, i ≠ j n) (n : ℕ) (a : α) :
    (∑ b : α, p (j n) b *
      actualPairIncrement p f base i j n b a) = 0 := by
  classical
  let K : α → ℝ := fun b => actualPairKernel p f base i (j n) a b
  have hk : (∑ b : α, p (j n) b * K b) = 0 := by
    exact actual_pair_kernel_right_centered
      p hp1 f base i (j n) (hne n) a
  calc
    (∑ b : α, p (j n) b * actualPairIncrement p f base i j n b a) =
      Real.sqrt (p i a) * (∑ b : α, p (j n) b * K b) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro b _
        dsimp [actualPairIncrement, K]
        ring
    _ = 0 := by rw [hk, mul_zero]

/-- The genuine source pair amplitudes give the required pointwise
Hilbert squared-norm bound (no alphabet-size or atom-floor factor).
-/
theorem actualPairIncrement_norm_bounded
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (c : ℝ)
    (hkernel : ∀ n a b,
      |actualPairKernel p f base i (j n) a b| ≤ c)
    (n : ℕ) (b : α) :
    vecNormSq (actualPairIncrement p f base i j n b) ≤ c^2 := by
  classical
  unfold vecNormSq
  calc
    (∑ a : α, (actualPairIncrement p f base i j n b a)^2) ≤
      ∑ a : α, p i a * c^2 := by
        apply Finset.sum_le_sum
        intro a _
        let k : ℝ := actualPairKernel p f base i (j n) a b
        have hb := abs_le.mp (hkernel n a b)
        have hsq : k^2 ≤ c^2 := by
          have hl : 0 ≤ c - k := sub_nonneg.mpr hb.2
          have hr : 0 ≤ c + k := by linarith [hb.1]
          nlinarith [mul_nonneg hl hr]
        have hstep := mul_le_mul_of_nonneg_left hsq (hp i a)
        dsimp [actualPairIncrement, k]
        rw [mul_pow, Real.sq_sqrt (hp i a)]
        nlinarith [hstep]
    _ = (∑ a : α, p i a) * c^2 := by rw [Finset.sum_mul]
    _ = c^2 := by rw [hp1 i, one_mul]

/-- First full source->product-moment integration: actual Efron-Stein pair
kernels determine the independent increment table; their centering,
bounded norm, fourth moment and interpolation are all *derived*. The
per-neighbor amplitude cover and the source-energy cap remain explicitly
displayed hypotheses. -/
theorem actual_source_pair_fourth_endpoint
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i : ι) (j : ℕ → ι) (c M : ℝ) (n : ℕ)
    (hne : ∀ k, i ≠ j k)
    (hc : 0 ≤ c)
    (hkernel : ∀ k a b,
      |actualPairKernel p f base i (j k) a b| ≤ c)
    (hM : moment2 (fun k => p (j k))
      (actualPairIncrement p f base i j) n ≤ M) :
    moment2 (fun k => p (j k))
      (actualPairIncrement p f base i j) n ≤
      (∑ w : Samples α n,
        mass (fun k => p (j k)) n w *
        Real.sqrt (vecNormSq
          (sumVector (actualPairIncrement p f base i j) n w))) *
      (c + Real.sqrt (3 * M)) := by
  exact actual_product_fourth_endpoint
    (fun k => p (j k))
    (actualPairIncrement p f base i j)
    c M n
    (fun k a => hp (j k) a)
    (fun k => hp1 (j k))
    (fun k a => actualPairIncrement_centered p hp1 f base i j hne k a)
    hc
    (fun k a => actualPairIncrement_norm_bounded p hp hp1 f base i j
      c hkernel k a)
    hM

end Nightfall.Observability.ActualESPairHilbertMoment
