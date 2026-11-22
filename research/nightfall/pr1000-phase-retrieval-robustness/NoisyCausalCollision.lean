import Mathlib

/-!
# NIGHTFALL PR #1001: an unconditional noisy causal collision

This module handles real linear sensing rows selected from *corrupted* observations.
The history is stored in reverse chronological order. The next row is a continuous
linear functional of the input, but its dependence on the history may be arbitrary:
this is a **stronger** lower-bound model than continuous row selection.

For any vector y with ‖y‖² ≤ σ, the zero signal and y have identical observed
histories under appropriate per-reading noise of magnitude at most σ, **for
every finite adaptive policy** whose rows satisfy |row x| ≤ ‖x‖.

The resulting worst-case sign-quotient reconstruction error is at least ‖y‖/2,
for any deterministic decoder. The externally stated sqrt(σ)/2 ball floor
follows by choosing a unit vector and y = sqrt(σ) • v.

This proves no sharp minimax upper bound, no phase-retrieval topological theorem,
and no novel priority claim. It contains no theorem-shaped axiom, sorry, or
use of a preassumed collision.
-/

namespace Nightfall.CausalNoise

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- A causal policy, with each row a normalized continuous *linear* functional
of the signal. Norming is stated pointwise; this is the operator-norm ≤ 1
condition for a continuous linear functional. No history regularity is needed
for a universal lower bound. -/
structure Policy (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  row : ℕ → List ℝ → E →L[ℝ] ℝ
  bounded : ∀ k h x, |row k h x| ≤ ‖x‖

/-- Reverse-chronological observed history. Noise is added *after squaring*.
The choice at stage k sees the actual corrupted prefix. -/
def transcript (p : Policy E) (x : E) (noise : ℕ → ℝ) : ℕ → List ℝ
  | 0 => []
  | k + 1 =>
      let h := transcript p x noise k
      (((p.row k h) x) ^ 2 + noise k) :: h

/-- On input zero, zero noise produces a zero transcript, irrespective of the
adaptive policy. -/
theorem transcript_zero (p : Policy E) (m : ℕ) :
    transcript p (0 : E) (fun _ => 0) m = List.replicate m 0 := by
  induction m with
  | zero => rfl
  | succ k ih =>
      simp [transcript, ih]

/-- Construct, rather than assume, the adversarial noise that cancels the
reading of a nonzero signal on the all-zero observed-prefix path. -/
def cancellingNoise (p : Policy E) (y : E) (k : ℕ) : ℝ :=
  -(((p.row k (List.replicate k 0)) y) ^ 2)

/-- The cancelling noises make the entire *actual* causal transcript zero. -/
theorem transcript_cancelled (p : Policy E) (y : E) (m : ℕ) :
    transcript p y (cancellingNoise p y) m = List.replicate m 0 := by
  induction m with
  | zero => rfl
  | succ k ih =>
      simp [transcript, cancellingNoise, ih]

/-- If the squared signal norm fits in the noise budget, every cancelling
noise fits in that budget. -/
theorem cancellingNoise_bound (p : Policy E) (y : E) (σ : ℝ)
    (hy : ‖y‖ ^ 2 ≤ σ) (k : ℕ) :
    |cancellingNoise p y k| ≤ σ := by
  let c : ℝ := (p.row k (List.replicate k 0)) y
  have hc : |c| ≤ ‖y‖ := p.bounded k (List.replicate k 0) y
  have hprod :
      0 ≤ (‖y‖ - |c|) * (‖y‖ + |c|) := by
    apply mul_nonneg
    · exact sub_nonneg.mpr hc
    · exact add_nonneg (norm_nonneg _) (abs_nonneg _)
  have hsquare : |c| ^ 2 = c ^ 2 := by
    simp
  have hcsq : c ^ 2 ≤ ‖y‖ ^ 2 := by
    nlinarith
  change |-(c ^ 2)| ≤ σ
  rw [abs_neg, abs_of_nonneg (sq_nonneg c)]
  exact hcsq.trans hy

/-- Sign-quotient distance, used here without constructing the quotient type. -/
def dpm (x y : E) : ℝ := min ‖x - y‖ ‖x + y‖

/-- A single decoder output cannot be within radius < ‖y‖/2 of
both sign classes 0 and y. The sign choice is fully accounted for. -/
theorem two_input_radius (z y : E) :
    ‖y‖ / 2 ≤ max ‖z‖ (dpm z y) := by
  have ha : ‖y‖ ≤ ‖z‖ + ‖z - y‖ := by
    calc
      ‖y‖ = ‖z - (z - y)‖ := by
        congr 1
        abel
      _ ≤ ‖z‖ + ‖z - y‖ := norm_sub_le _ _
  have hb : ‖y‖ ≤ ‖z‖ + ‖z + y‖ := by
    calc
      ‖y‖ = ‖(z + y) - z‖ := by
        congr 1
        abel
      _ ≤ ‖z + y‖ + ‖z‖ := norm_sub_le _ _
      _ = ‖z‖ + ‖z + y‖ := add_comm _ _
  have hmin : ‖y‖ ≤ ‖z‖ + dpm z y := by
    rcases le_total ‖z - y‖ ‖z + y‖ with h | h
    · simpa [dpm, min_eq_left h] using ha
    · simpa [dpm, min_eq_right h] using hb
  have hz : ‖z‖ ≤ max ‖z‖ (dpm z y) := le_max_left _ _
  have hdy : dpm z y ≤ max ‖z‖ (dpm z y) := le_max_right _ _
  linarith

/-- Fully quantified causal indistinguishability and deterministic
decoder lower bound, valid in any real normed vector space.
No topological or collision assumption is used. -/
theorem decoder_noise_floor
    (p : Policy E) (m : ℕ) (y : E) (σ : ℝ)
    (hy : ‖y‖ ^ 2 ≤ σ) (decoder : List ℝ → E) :
    ∃ noise₀ noise₁ : ℕ → ℝ,
      (∀ k, |noise₀ k| ≤ σ) ∧
      (∀ k, |noise₁ k| ≤ σ) ∧
      transcript p (0 : E) noise₀ m = transcript p y noise₁ m ∧
      ‖y‖ / 2 ≤
        max (dpm (decoder (transcript p (0 : E) noise₀ m)) 0)
            (dpm (decoder (transcript p y noise₁ m)) y) := by
  refine ⟨(fun _ => 0), cancellingNoise p y, ?_, ?_, ?_, ?_⟩
  · intro k
    have hσ : 0 ≤ σ := le_trans (sq_nonneg _) hy
    simpa using hσ
  · intro k
    exact cancellingNoise_bound p y σ hy k
  · rw [transcript_zero, transcript_cancelled]
  · rw [transcript_zero, transcript_cancelled]
    simpa [dpm] using two_input_radius (decoder (List.replicate m 0)) y

#print decoder_noise_floor
#print axioms decoder_noise_floor
#print axioms transcript_cancelled
#print axioms cancellingNoise_bound
#print axioms two_input_radius

end Nightfall.CausalNoise
