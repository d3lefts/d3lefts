import HilbertManyIncrementMoment
import ActualProductResampleBridge

/-!
# Recover distinct coordinate samples from the genuine original product law

Current Lean 4.36.0-rc2 source-preserving port of the distribution
bridge in legacy #434 ActualESFiniteSampleLaw.lean.

This establishes the equality of the law of injectively selected
original coordinate labels with the recursive independent-sample
representation. In particular it transfers FIRST NORM moments and
second/fourth moments without introducing synthetic duplicate sites.

This alone is not terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceFiniteSampleLaw

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

def observedActualSample (j : ℕ → ι) :
    (n : ℕ) → (ι → α) → Samples α n
  | 0, _ => PUnit.unit
  | n + 1, x => (observedActualSample j n x, x (j n))

theorem observedActualSample_update_outside
    (j : ℕ → ι) (k : ι) (x : ι → α) (b : α) :
    ∀ n : ℕ, (∀ m, m < n → j m ≠ k) →
      observedActualSample j n (Function.update x k b) =
        observedActualSample j n x := by
  intro n
  induction n with
  | zero =>
      intro _
      rfl
  | succ n ih =>
      intro hk
      have hfirst : ∀ m, m < n → j m ≠ k := by
        intro m hm
        exact hk m (Nat.lt_succ_of_lt hm)
      have hlast : j n ≠ k := hk n (Nat.lt_succ_self n)
      change (observedActualSample j n (Function.update x k b),
          (Function.update x k b) (j n)) =
        (observedActualSample j n x, x (j n))
      rw [ih hfirst]
      simp [Function.update_of_ne hlast]

/-- Complete equality of the original-coordinate sample distribution
and the independent recursive sample distribution, for EVERY test
observable F and including source laws with zero-mass symbols. -/
theorem original_source_distinct_prefix_law
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ℕ → ι) :
    ∀ n : ℕ,
      (∀ k l, k < n → l < n → k ≠ l → j k ≠ j l) →
      ∀ F : Samples α n → ℝ,
        (∑ x : ι → α,
          originalMass p x * F (observedActualSample j n x)) =
          ∑ w : Samples α n,
            mass (fun k => p (j k)) n w * F w := by
  classical
  intro n
  induction n with
  | zero =>
      intro _ F
      change (∑ x : ι → α,
        originalMass p x * F PUnit.unit) =
        (∑ _ : PUnit, (1 : ℝ) * F PUnit.unit)
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_punit,
        Nat.cast_one, one_smul]
      rw [← Finset.sum_mul, sum_originalMass' p hp1, one_mul]
  | succ n ih =>
      intro hdist F
      have hprefix :
          ∀ k l, k < n → l < n → k ≠ l → j k ≠ j l := by
        intro k l hk hl hne
        exact hdist k l (Nat.lt_succ_of_lt hk)
          (Nat.lt_succ_of_lt hl) hne
      have hseparate : ∀ m, m < n → j m ≠ j n := by
        intro m hm
        exact hdist m n (Nat.lt_succ_of_lt hm)
          (Nat.lt_succ_self n) (Nat.ne_of_lt hm)
      have hupdate (x : ι → α) (b : α) :
          observedActualSample j (n + 1)
            (Function.update x (j n) b) =
              (observedActualSample j n x, b) := by
        change (observedActualSample j n
             (Function.update x (j n) b),
             (Function.update x (j n) b) (j n)) =
            (observedActualSample j n x, b)
        rw [observedActualSample_update_outside j (j n)
          x b n hseparate]
        simp
      let G : Samples α n → ℝ :=
        fun w => ∑ b : α, p (j n) b * F (w, b)
      have hprev := ih hprefix G
      calc
        (∑ x : ι → α, originalMass p x *
          F (observedActualSample j (n + 1) x)) =
          ∑ x : ι → α, originalMass p x *
            (∑ b : α, p (j n) b *
              F (observedActualSample j (n + 1)
                (Function.update x (j n) b))) :=
                  (actual_source_resample_sum p hp1 (j n)
                    (fun x => F (observedActualSample j (n + 1) x))).symm
        _ = ∑ x : ι → α, originalMass p x *
              (∑ b : α, p (j n) b *
                F (observedActualSample j n x, b)) := by
              apply Finset.sum_congr rfl
              intro x _
              congr 1
              apply Finset.sum_congr rfl
              intro b _
              rw [hupdate x b]
        _ = ∑ w : Samples α n,
              mass (fun k => p (j k)) n w *
                (∑ b : α, p (j n) b * F (w, b)) := hprev
        _ = ∑ w : Samples α (n + 1),
              mass (fun k => p (j k)) (n + 1) w * F w := by
              rw [expectation_succ (fun k => p (j k)) n F]
              unfold Nightfall.Observability.QuadraticMoments.jointAvg
              apply Finset.sum_congr rfl
              intro w _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro b _
              ring

/-- First norm moment under real source equals recursive independent
sample first norm moment, with no artificial neighbor stream. -/
theorem original_source_distinct_prefix_first_norm
    {K : Type*} [Fintype K]
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ℕ → ι) (n : ℕ)
    (hInj : ∀ k l, k < n → l < n → k ≠ l → j k ≠ j l)
    (Y : ℕ → α → K → ℝ) :
    (∑ x : ι → α, originalMass p x *
       Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
         (sumVector Y n (observedActualSample j n x)))) =
    ∑ w : Samples α n, mass (fun k => p (j k)) n w *
       Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
         (sumVector Y n w)) := by
  exact original_source_distinct_prefix_law p hp1 j n hInj
    (fun w : Samples α n =>
      Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
        (sumVector Y n w)))

end Nightfall.Observability.ActualSourceFiniteSampleLaw
