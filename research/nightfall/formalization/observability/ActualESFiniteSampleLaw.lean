import HilbertManyIncrementMoment
import ProductInfluence

/-!
# Genuine finite-source law of a distinct observed sample prefix

The samples used by QuadraticHilbertMany are recursively represented
independent draws. This module proves that *for an injective prefix of
genuine original source coordinate labels*, the law of their observed
values is exactly that recursive independent product law.

No repeated-coordinate copies and no assumed law-transport hypothesis.
The source is the SAME normalized finite product that defines
Efron-Stein components; zero atoms are allowed.

This does not yet construct the enumeration of greedy-owned neighbors or
state the terminal Q2 theorem. It discharges the product-distribution
identification, the major missing representation step.
-/

namespace Nightfall.Observability.ActualESFiniteSampleLaw

open Finset
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual source symbols at the first n coordinates selected
by j. This is a deterministic observation of ONE original source draw. -/
def observedSample (j : ℕ → ι) :
    (n : ℕ) → (ι → α) → Samples α n
  | 0, _ => PUnit.unit
  | n + 1, x => (observedSample j n x, x (j n))

/-- An update at a coordinate NOT among the observed original sites
leaves the observed sample entirely unchanged. -/
theorem observedSample_update_outside
    (j : ℕ → ι) (k : ι) (x : ι → α) (b : α) :
    ∀ n : ℕ, (∀ m, m < n → j m ≠ k) →
      observedSample j n (Function.update x k b) =
        observedSample j n x := by
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
      change (observedSample j n (Function.update x k b),
          (Function.update x k b) (j n)) =
        (observedSample j n x, x (j n))
      rw [ih hfirst]
      simp [Function.update_of_ne hlast]

/-- Exact distribution of n DISTINCT observed original coordinates.
The two expectations are equal for every observable F, not just for
squared energy: this covers the first moment z and fourth moment too.
No probability lower bound and no synthetic independence premise. -/
theorem actual_source_observedSample_law
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ℕ → ι) :
    ∀ n : ℕ,
      (∀ k l, k < n → l < n → k ≠ l → j k ≠ j l) →
      ∀ F : Samples α n → ℝ,
        (∑ x : ι → α, prodMass p x * F (observedSample j n x)) =
          ∑ w : Samples α n,
            mass (fun k => p (j k)) n w * F w := by
  classical
  intro n
  induction n with
  | zero =>
      intro _ F
      change (∑ x : ι → α,
        prodMass p x * F PUnit.unit) =
        (∑ _ : PUnit, (1 : ℝ) * F PUnit.unit)
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_punit,
        Nat.cast_one, one_smul]
      rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]
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
          observedSample j (n + 1)
            (Function.update x (j n) b) =
              (observedSample j n x, b) := by
        change (observedSample j n
             (Function.update x (j n) b),
             (Function.update x (j n) b) (j n)) =
            (observedSample j n x, b)
        rw [observedSample_update_outside j (j n)
          x b n hseparate]
        simp
      let G : Samples α n → ℝ :=
        fun w => ∑ b : α, p (j n) b * F (w, b)
      have hprev := ih hprefix G
      calc
        (∑ x : ι → α, prodMass p x *
          F (observedSample j (n + 1) x)) =
          ∑ x : ι → α, ∑ b : α,
            prodMass p x * p (j n) b *
              F (observedSample j (n + 1)
                (Function.update x (j n) b)) :=
                    (resample_sum p hp1 (j n)
                      (fun x => F (observedSample j (n + 1) x))).symm
        _ = ∑ x : ι → α, prodMass p x *
              (∑ b : α, p (j n) b *
                F (observedSample j n x, b)) := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro b _
              rw [hupdate x b]
              ring
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

/-- Specialize the source-law bridge to the genuine Hilbert first
norm moment. The right side is the exact original-source expectation
of the norm, not a moment from an unrelated artificial experiment. -/
theorem actual_source_observed_hilbert_first_moment
    {K : Type*} [Fintype K]
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ℕ → ι) (n : ℕ)
    (hInj : ∀ k l, k < n → l < n → k ≠ l → j k ≠ j l)
    (Y : ℕ → α → K → ℝ) :
    (∑ x : ι → α, prodMass p x *
       Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
         (sumVector Y n (observedSample j n x)))) =
    ∑ w : Samples α n, mass (fun k => p (j k)) n w *
       Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
         (sumVector Y n w)) := by
  exact actual_source_observedSample_law p hp1 j n hInj _

end Nightfall.Observability.ActualESFiniteSampleLaw
