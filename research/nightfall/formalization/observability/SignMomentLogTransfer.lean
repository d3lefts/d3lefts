import Mathlib

/-!
# Finite signed trace influence: exponential union and logarithmic transfer

A quantified finite sign-ensemble composition from an influential signed scalar
projection and a *separately stated* coordinate exponential-moment premise.
This module does NOT yet derive the PSD Gaussian moment bound from Gram matrices,
nor does it formalize completed measurable products or adaptive posterior kernels.

The premise hmoment is the precise remaining local analytic interface:
  E_sign [exp(Q_i/(4m)) - 1] <= (sqrt 2 - 1) tr(A_i)/m.
No theorem below assumes the desired logarithmic conclusion.
-/

namespace Nightfall.Observability.SignMoment

open Finset

variable {ι σ : Type*} [Fintype ι] [Fintype σ]

/-- Finite exponential-union implication. The signed scalar lower bound is
required for every sign, and the individual exponential-moment upper bounds
are explicit hypotheses, not concealed by the statement. -/
theorem exp_union
    (w : σ → ℝ) (hw : ∀ e, 0 ≤ w e)
    (hw1 : (∑ e : σ, w e) = 1)
    (Q : ι → σ → ℝ) (hQ : ∀ i e, 0 ≤ Q i e)
    (s : ι → ℝ) (m a L : ℝ) (hm : 0 < m)
    (hscalar : ∀ e : σ, ∃ i : ι, L ≤ Q i e)
    (hmoment : ∀ i : ι,
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * m)) - 1)) ≤
        a * s i / m) :
    Real.exp (L / (4 * m)) - 1 ≤
      ∑ i : ι, a * s i / m := by
  classical
  have hm4 : 0 < 4 * m := by positivity
  have hnonneg (i : ι) (e : σ) :
      0 ≤ Real.exp (Q i e / (4 * m)) - 1 := by
    have hz : 0 ≤ Q i e / (4 * m) := div_nonneg (hQ i e) (le_of_lt hm4)
    have he := Real.exp_le_exp.mpr hz
    rw [Real.exp_zero] at he
    linarith
  have hpoint (e : σ) :
      Real.exp (L / (4 * m)) - 1 ≤
        ∑ i : ι, (Real.exp (Q i e / (4 * m)) - 1) := by
    obtain ⟨i, hi⟩ := hscalar e
    have hdiv : L / (4 * m) ≤ Q i e / (4 * m) :=
      (div_le_div_iff_of_pos_right hm4).mpr hi
    have he : Real.exp (L / (4 * m)) ≤ Real.exp (Q i e / (4 * m)) :=
      Real.exp_le_exp.mpr hdiv
    have hsingle : Real.exp (Q i e / (4 * m)) - 1 ≤
        ∑ j : ι, (Real.exp (Q j e / (4 * m)) - 1) :=
      Finset.single_le_sum (fun j _ => hnonneg j e) (Finset.mem_univ i)
    linarith
  calc
    Real.exp (L / (4 * m)) - 1 =
        (∑ e : σ, w e) * (Real.exp (L / (4 * m)) - 1) := by rw [hw1]; ring
    _ = ∑ e : σ, w e * (Real.exp (L / (4 * m)) - 1) := by
      rw [Finset.sum_mul]
    _ ≤ ∑ e : σ, w e *
        (∑ i : ι, (Real.exp (Q i e / (4 * m)) - 1)) := by
      apply Finset.sum_le_sum
      intro e _
      exact mul_le_mul_of_nonneg_left (hpoint e) (hw e)
    _ = ∑ e : σ, ∑ i : ι,
        w e * (Real.exp (Q i e / (4 * m)) - 1) := by
      apply Finset.sum_congr rfl
      intro e _
      rw [Finset.mul_sum]
    _ = ∑ i : ι, ∑ e : σ,
        w e * (Real.exp (Q i e / (4 * m)) - 1) := Finset.sum_comm
    _ ≤ ∑ i : ι, a * s i / m := by
      apply Finset.sum_le_sum
      intro i _
      exact hmoment i

/-- Logarithmic transfer. This is a *proved implication* from local signed
influence and the finite exponential-moment hypothesis, with exact factor 4. -/
theorem logarithmic_trace_from_moment
    (w : σ → ℝ) (hw : ∀ e, 0 ≤ w e)
    (hw1 : (∑ e : σ, w e) = 1)
    (Q : ι → σ → ℝ) (hQ : ∀ i e, 0 ≤ Q i e)
    (s : ι → ℝ) (m a L : ℝ) (hm : 0 < m)
    (hp : 0 ≤ ∑ i : ι, s i)
    (ha : 0 ≤ a)
    (hscalar : ∀ e : σ, ∃ i : ι, L ≤ Q i e)
    (hmoment : ∀ i : ι,
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * m)) - 1)) ≤
        a * s i / m) :
    L ≤ (4 * m) * Real.log (1 + a * (∑ i : ι, s i) / m) := by
  classical
  have hsum := exp_union w hw hw1 Q hQ s m a L hm hscalar hmoment
  have hsum_eq :
      (∑ i : ι, a * s i / m) = a * (∑ i : ι, s i) / m := by
    calc
      (∑ i : ι, a * s i / m) = (∑ i : ι, (a * s i) * m⁻¹) := by
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ = (∑ i : ι, a * s i) * m⁻¹ := by
        rw [Finset.sum_mul]
      _ = a * (∑ i : ι, s i) / m := by
        rw [Finset.mul_sum]
        ring
  rw [hsum_eq] at hsum
  have hpos : 0 < 1 + a * (∑ i : ι, s i) / m := by
    have hnn : 0 ≤ a * (∑ i : ι, s i) / m :=
      div_nonneg (mul_nonneg ha hp) (le_of_lt hm)
    linarith
  have hexp : Real.exp (L / (4 * m)) ≤
      Real.exp (Real.log (1 + a * (∑ i : ι, s i) / m)) := by
    rw [Real.exp_log hpos]
    linarith
  have hlog : L / (4 * m) ≤
      Real.log (1 + a * (∑ i : ι, s i) / m) :=
    Real.exp_le_exp.mp hexp
  calc
    L ≤ Real.log (1 + a * (∑ i : ι, s i) / m) * (4 * m) :=
      (div_le_iff₀ (by positivity : 0 < 4 * m)).mp hlog
    _ = (4 * m) * Real.log (1 + a * (∑ i : ι, s i) / m) := by ring


/-- The normalized exponential chord inequality; unlike the Gaussian
moment bound, this is entirely elementary convexity and is proved here. -/
theorem exp_chord (t x : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Real.exp (t * x) - 1 ≤ t * (Real.exp x - 1) := by
  have hconv : Real.exp (t * x + (1 - t) * 0) ≤
      t * Real.exp x + (1 - t) * Real.exp 0 :=
    convexOn_exp.2 (Set.mem_univ _) (Set.mem_univ _)
      ht0 (by linarith) (by ring)
  simp only [mul_zero, add_zero, Real.exp_zero] at hconv
  nlinarith

/-- Convert the normalized PSD sign-moment bound at the trace scale into
the precise m-scale hypothesis needed by logarithmic_trace_from_moment.
The only specialized input is hnormalized; the convex chord is proved. -/
theorem scaled_moment_of_normalized
    (w : σ → ℝ) (hw : ∀ e, 0 ≤ w e)
    (Q : ι → σ → ℝ) (s : ι → ℝ)
    (m a : ℝ) (hm : 0 < m)
    (hs : ∀ i, 0 ≤ s i) (hsm : ∀ i, s i ≤ m)
    (htrace_zero : ∀ i, s i = 0 → ∀ e, Q i e = 0)
    (hnormalized : ∀ i, 0 < s i →
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * s i)) - 1)) ≤ a) :
    ∀ i : ι,
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * m)) - 1)) ≤
      a * s i / m := by
  classical
  intro i
  by_cases hi0 : s i = 0
  · have hQ0 : ∀ e : σ, Q i e = 0 := htrace_zero i hi0
    simp [hi0, hQ0]
  · have hi : 0 < s i := lt_of_le_of_ne (hs i) (Ne.symm hi0)
    have ht0 : 0 ≤ s i / m := div_nonneg (hs i) (le_of_lt hm)
    have ht1 : s i / m ≤ 1 := (div_le_iff₀ hm).mpr (by simpa using hsm i)
    have hfactor (e : σ) :
        Q i e / (4 * m) =
          (s i / m) * (Q i e / (4 * s i)) := by
      field_simp
    have hchord (e : σ) :
        Real.exp (Q i e / (4 * m)) - 1 ≤
          (s i / m) * (Real.exp (Q i e / (4 * s i)) - 1) := by
      rw [hfactor e]
      exact exp_chord (s i / m) (Q i e / (4 * s i)) ht0 ht1
    calc
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * m)) - 1)) ≤
          ∑ e : σ, w e * ((s i / m) *
            (Real.exp (Q i e / (4 * s i)) - 1)) := by
        apply Finset.sum_le_sum
        intro e _
        exact mul_le_mul_of_nonneg_left (hchord e) (hw e)
      _ = (s i / m) * (∑ e : σ, w e *
            (Real.exp (Q i e / (4 * s i)) - 1)) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro e _
        ring
      _ ≤ (s i / m) * a := by
        exact mul_le_mul_of_nonneg_left (hnormalized i hi) ht0
      _ = a * s i / m := by ring

/-- Entire rank-log implication from a normalized PSD sign-moment
estimate, with the chord scaling and exponential union kernel-checked.
The Gaussian PSD estimate itself is an explicit imported hypothesis. -/
theorem log_from_normalized_psd_moment
    (w : σ → ℝ) (hw : ∀ e, 0 ≤ w e)
    (hw1 : (∑ e : σ, w e) = 1)
    (Q : ι → σ → ℝ) (hQ : ∀ i e, 0 ≤ Q i e)
    (s : ι → ℝ) (m a L : ℝ) (hm : 0 < m)
    (hs : ∀ i, 0 ≤ s i) (hsm : ∀ i, s i ≤ m)
    (ha : 0 ≤ a)
    (htrace_zero : ∀ i, s i = 0 → ∀ e, Q i e = 0)
    (hscalar : ∀ e : σ, ∃ i : ι, L ≤ Q i e)
    (hnormalized : ∀ i, 0 < s i →
      (∑ e : σ, w e * (Real.exp (Q i e / (4 * s i)) - 1)) ≤ a) :
    L ≤ (4 * m) * Real.log (1 + a * (∑ i : ι, s i) / m) := by
  classical
  have hp : 0 ≤ ∑ i : ι, s i := Finset.sum_nonneg (fun i _ => hs i)
  apply logarithmic_trace_from_moment w hw hw1 Q hQ s m a L hm hp ha hscalar
  exact scaled_moment_of_normalized w hw Q s m a hm hs hsm
    htrace_zero hnormalized

end Nightfall.Observability.SignMoment
