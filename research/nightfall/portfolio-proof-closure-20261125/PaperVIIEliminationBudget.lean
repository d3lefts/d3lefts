import Mathlib

/-! Prospectus v0.7 Appendix A.3/C.2: finite exact reliability
schedule, geometric marginal screening cost, and validation cost.
This is the numerical expectation core of the overlapping-block
upper bound. No inter-block independence enters the sum. The actual
noisy policy and majority-tail probability coupling are separate. -/
namespace Nightfall.PaperVIIEliminationBudget

noncomputable def errorMass : ℕ → ℝ
  | 0 => 0
  | n+1 => errorMass n + 1 / (((n : ℝ)+1)*((n : ℝ)+2))

theorem errorMass_exact (n : ℕ) :
    errorMass n = 1 - 1/((n : ℝ)+1) := by
  induction n with
  | zero => norm_num [errorMass]
  | succ n ih =>
    rw [errorMass, ih]
    push_cast
    have h1 : (n : ℝ)+1 ≠ 0 := by positivity
    have h2 : (n : ℝ)+2 ≠ 0 := by positivity
    have h3 : (n : ℝ)+1+1 ≠ 0 := by positivity
    field_simp
    <;> ring

theorem errorMass_le_one (n : ℕ) : errorMass n ≤ 1 := by
  rw [errorMass_exact]
  have h : 0 ≤ (1 : ℝ) / ((n : ℝ)+1) := by positivity
  linarith

/-- j is zero-based, so a fair block reaches its jth relative
position with probability 2^{-j}. -/
noncomputable def screenWork (r : ℕ → ℝ) (j : ℕ) : ℕ → ℝ
  | 0 => 0
  | n+1 => r j + (1/2 : ℝ) * screenWork r (j+1) n

/-- A survivor of an n-bit fair block has probability 2^{-n};
validation uses a fresh copy of the schedule. -/
noncomputable def validationWork (r : ℕ → ℝ) (j : ℕ) : ℕ → ℝ
  | 0 => 0
  | n+1 => (1/2 : ℝ)^(n+1) * r j +
      (1/2 : ℝ) * validationWork r (j+1) n

theorem half_pow_le_one (n : ℕ) : (1/2 : ℝ)^n ≤ 1 := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    rw [pow_succ]
    linarith

theorem screenWork_bound (r : ℕ → ℝ) (C : ℝ) (hC : 0 ≤ C)
    (hr : ∀ j, r j ≤ C*((j : ℝ)+1)) (j n : ℕ) :
    screenWork r j n ≤ 2*C*((j : ℝ)+2) := by
  induction n generalizing j with
  | zero =>
    simp only [screenWork]
    positivity
  | succ n ih =>
    rw [screenWork]
    have h := ih (j+1)
    have hj := hr j
    push_cast at h
    linarith

theorem validationWork_le_screenWork (r : ℕ → ℝ)
    (hr : ∀ j, 0 ≤ r j) (j n : ℕ) :
    validationWork r j n ≤ screenWork r j n := by
  induction n generalizing j with
  | zero => simp [validationWork, screenWork]
  | succ n ih =>
    rw [validationWork, screenWork]
    have h := ih (j+1)
    have hmul := mul_le_mul_of_nonneg_right (half_pow_le_one (n+1)) (hr j)
    rw [one_mul] at hmul
    linarith

/-- Exact finite formula for validation; its equality with the
unconditional marginal validation work is independent of block overlap. -/
theorem validationWork_formula (r : ℕ → ℝ) (j n : ℕ) :
    validationWork r j n = (1/2 : ℝ)^n * ∑ i ∈ Finset.range n, r (j+i) := by
  induction n generalizing j with
  | zero => simp [validationWork]
  | succ n ih =>
    rw [validationWork, ih (j+1), Finset.sum_range_succ', pow_succ]
    simp only [Nat.add_zero]
    have he : (∑ i ∈ Finset.range n, r (j+1+i)) =
        ∑ i ∈ Finset.range n, r (j+(i+1)) := by
      apply Finset.sum_congr rfl
      intro i _
      congr 1
      omega
    rw [he]
    ring

/-- The expected sum of screening and validation costs is O(m)
for arbitrary finite block widths, once the per-position repetition
schedule has the linear envelope (which includes logarithmic schedules). -/
theorem total_marginal_work_bound {I : Type*} (blocks : Finset I)
    (width : I → ℕ) (r : ℕ → ℝ) (C : ℝ) (hC : 0 ≤ C)
    (hr0 : ∀ j, 0 ≤ r j) (hr : ∀ j, r j ≤ C*((j : ℝ)+1)) :
    (∑ i ∈ blocks, (screenWork r 0 (width i) +
      validationWork r 0 (width i))) ≤ 8*C*(blocks.card : ℝ) := by
  classical
  calc
    _ ≤ ∑ i ∈ blocks, (8*C) := by
      apply Finset.sum_le_sum
      intro i _
      have hs := screenWork_bound r C hC hr 0 (width i)
      have hv := validationWork_le_screenWork r hr0 0 (width i)
      norm_num at hs
      linarith
    _ = _ := by simp; ring

#print axioms errorMass_exact
#print axioms errorMass_le_one
#print axioms screenWork_bound
#print axioms validationWork_le_screenWork
#print axioms validationWork_formula
#print axioms total_marginal_work_bound
end Nightfall.PaperVIIEliminationBudget
