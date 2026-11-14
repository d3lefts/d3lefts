import ActualProductSourcePairCentering
import QuadraticActualMomentEndpoint
import ActualSourceFiniteSampleLaw

/-!
# Source-exact finite actual-neighbor Hilbert fourth endpoint (4.36 pin).
Ported from historical #424 / ActualESFiniteNeighborMoment: the pair
kernel is now directly sourceDoubleCenteredPair, not a supplied table,
and all original-law j(k) neighbor sampling is mediated by the
separate certified source distinct-label law. The endpoint retains
the explicit moment2≤M premise until current-source influence Parseval
and owner-energy partition are composed.
-/
namespace Nightfall.Observability.ActualSourceFinitePairMoment
open Finset
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticActualMomentEndpoint
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def sourcePairIncrement
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (j : ℕ → ι) (k : ℕ) (b a : α) : ℝ :=
  Real.sqrt (p i a) *
    sourceDoubleCenteredPair p f i (j k) a b

noncomputable def sourcePairEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) : ℝ :=
  ∑ a : α, ∑ b : α,
    p i a * p j b * (sourceDoubleCenteredPair p f i j a b)^2

theorem sourcePairIncrement_norm_bounded
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) 
    (i : ι) (j : ℕ → ι) (c : ℝ)
    (hkernel : ∀ n a b,
      |sourceDoubleCenteredPair p f i (j n) a b| ≤ c)
    (n : ℕ) (b : α) :
    vecNormSq (sourcePairIncrement p f i j n b) ≤ c^2 := by
  classical
  unfold vecNormSq
  calc
    (∑ a : α, (sourcePairIncrement p f i j n b a)^2) ≤
      ∑ a : α, p i a * c^2 := by
        apply Finset.sum_le_sum
        intro a _
        let k : ℝ := sourceDoubleCenteredPair p f i (j n) a b
        have hb := abs_le.mp (hkernel n a b)
        have hsq : k^2 ≤ c^2 := by
          have hl : 0 ≤ c - k := sub_nonneg.mpr hb.2
          have hr : 0 ≤ c + k := by linarith [hb.1]
          nlinarith [mul_nonneg hl hr]
        have hstep := mul_le_mul_of_nonneg_left hsq (hp i a)
        dsimp [sourcePairIncrement, k]
        rw [mul_pow, Real.sq_sqrt (hp i a)]
        nlinarith [hstep]
    _ = (∑ a : α, p i a) * c^2 := by rw [Finset.sum_mul]
    _ = c^2 := by rw [hp1 i, one_mul]


noncomputable def finitePairIncrement
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    
    (i : ι) (j : ℕ → ι) (n : ℕ) :
    ℕ → α → α → ℝ :=
  fun k b a => if k < n then
    sourcePairIncrement p f i j k b a else 0

/-- Genuine source pair-degeneracy centers every increment,
including the identically zero part of the sequence. -/
theorem finitePairIncrement_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
     (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k)
    (k : ℕ) (a : α) :
    (∑ b : α, p (j k) b *
      finitePairIncrement p f i j n k b a) = 0 := by
  classical
  by_cases hk : k < n
  · simp only [finitePairIncrement, if_pos hk]
    let t : ℝ := Real.sqrt (p i a)
    have hcent :
        (∑ b : α, p (j k) b *
          sourceDoubleCenteredPair p f i (j k) a b) = 0 :=
      actual_source_derived_pair_second_centered p hp1 f i (j k) a
    calc
      (∑ b : α, p (j k) b *
        sourcePairIncrement p f i j k b a) =
        t * (∑ b : α, p (j k) b *
          sourceDoubleCenteredPair p f i (j k) a b) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            dsimp [t, sourcePairIncrement]
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
     (i : ι) (j : ℕ → ι) (n : ℕ)
    (c : ℝ)
    (hkernel : ∀ k, k < n → ∀ a b,
      |sourceDoubleCenteredPair p f i (j k) a b| ≤ c)
    (k : ℕ) (b : α) :
    vecNormSq (finitePairIncrement p f i j n k b) ≤ c^2 := by
  classical
  by_cases hk : k < n
  · let jconst : ℕ → ι := fun _ => j k
    have hAll : ∀ m a b,
        |sourceDoubleCenteredPair p f i (jconst m) a b| ≤ c := by
      intro m a d
      exact hkernel k hk a d
    have h := sourcePairIncrement_norm_bounded
      p hp hp1 f i jconst c hAll 0 b
    have hEq :
        finitePairIncrement p f i j n k b =
          sourcePairIncrement p f i jconst 0 b := by
      funext a
      simp [finitePairIncrement, sourcePairIncrement, jconst, hk]
    rw [hEq]
    exact h
  · have hc2 : 0 ≤ c^2 := sq_nonneg c
    simpa [finitePairIncrement, hk, vecNormSq] using hc2

/-- Exact source-derived independent-neighbor product moment budget. -/
theorem finitePairIncrement_moment2_eq_budget
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) 
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f i j n) n =
    budget (fun k => p (j k))
      (finitePairIncrement p f i j n) n := by
  exact moment2_eq_budget (fun k => p (j k))
    (finitePairIncrement p f i j n)
    (fun k => hp1 (j k))
    (fun k a =>
      finitePairIncrement_centered p hp1 f i j n hne k a)
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
    (f : (ι → α) → ℝ) 
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (c M : ℝ)
    (hne : ∀ k, k < n → i ≠ j k)
    (hc : 0 ≤ c)
    (hkernel : ∀ k, k < n → ∀ a b,
      |sourceDoubleCenteredPair p f i (j k) a b| ≤ c)
    (hM : moment2 (fun k => p (j k))
      (finitePairIncrement p f i j n) n ≤ M) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f i j n) n ≤
      (∑ w : Samples α n,
        mass (fun k => p (j k)) n w *
          Real.sqrt (vecNormSq (sumVector
            (finitePairIncrement p f i j n) n w))) *
      (c + Real.sqrt (3 * M)) := by
  exact actual_product_fourth_endpoint
    (fun k => p (j k))
    (finitePairIncrement p f i j n)
    c M n
    (fun k a => hp (j k) a)
    (fun k => hp1 (j k))
    (fun k a =>
      finitePairIncrement_centered p hp1 f i j n hne k a)
    hc
    (fun k a =>
      finitePairIncrement_norm_bounded
        p hp hp1 f i j n c hkernel k a)
    hM

/-- The SECOND MOMENT of the actual finite-neighbor Hilbert increment
table equals the sum of the literal original source-pair L2 energies.
This derives the numerical energy object used in the fourth-moment
endpoint; it does not assume a moment-to-energy identification. -/
theorem finitePairIncrement_moment2_eq_source_pair_energies
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) 
    (i : ι) (j : ℕ → ι) (n : ℕ)
    (hne : ∀ k, k < n → i ≠ j k) :
    moment2 (fun k => p (j k))
      (finitePairIncrement p f i j n) n =
    (∑ k ∈ Finset.range n,
      sourcePairEnergy
        p f i (j k)) := by
  classical
  rw [finitePairIncrement_moment2_eq_budget p hp1 f i j n hne]
  unfold budget
  apply Finset.sum_congr rfl
  intro k hk
  have hklt : k < n := Finset.mem_range.mp hk
  unfold sourcePairEnergy
  unfold vecNormSq
  calc
    (∑ b : α, p (j k) b *
      (∑ a : α, (finitePairIncrement p f i j n k b a)^2)) =
      ∑ b : α, ∑ a : α,
        p (j k) b *
          (finitePairIncrement p f i j n k b a)^2 := by
            apply Finset.sum_congr rfl
            intro b _
            rw [Finset.mul_sum]
    _ = ∑ a : α, ∑ b : α,
        p (j k) b *
          (finitePairIncrement p f i j n k b a)^2 :=
            Finset.sum_comm
    _ = ∑ a : α, ∑ b : α,
        p i a * p (j k) b *
          (sourceDoubleCenteredPair p f i (j k) a b)^2 := by
            apply Finset.sum_congr rfl
            intro a _
            apply Finset.sum_congr rfl
            intro b _
            simp only [finitePairIncrement, if_pos hklt,
              sourcePairIncrement, mul_pow,
              Real.sq_sqrt (hp i a)]
            ring


end Nightfall.Observability.ActualSourceFinitePairMoment
