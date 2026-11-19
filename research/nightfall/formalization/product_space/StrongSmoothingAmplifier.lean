import Mathlib

/-!
# Cubic tail amplifier for a strong failure-event polynomial

A *fully elementary* alternative to binomial/Hoeffding approximation.
The map x ↦ 3x² − 2x³ preserves [0,1], exchanges 0 and 1 by reflection,
and repeated amplification drives initial values in [0,2/5] to 0
with a double-exponentially decreasing envelope.

This source is a scalar building block. The construction of a
low-degree initial separator and the polynomial-degree composition
are separate obligations; the strong product/mixture theorem is NOT
claimed here.
-/
namespace Nightfall.StrongSmoothing

def cubic (x : ℝ) : ℝ := x ^ 2 * (3 - 2 * x)

theorem cubic_nonneg {x : ℝ} (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ cubic x := by
  unfold cubic
  exact mul_nonneg (sq_nonneg _) (by linarith)

theorem cubic_compl (x : ℝ) : cubic (1 - x) = 1 - cubic x := by
  unfold cubic
  ring

theorem cubic_le_one {x : ℝ} (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    cubic x ≤ 1 := by
  have h := cubic_nonneg (show 0 ≤ 1 - x by linarith)
    (show 1 - x ≤ 1 by linarith)
  rw [cubic_compl] at h
  linarith

theorem cubic_mono {x y : ℝ}
    (hx : 0 ≤ x) (hxy : x ≤ y) (hy : y ≤ 1) :
    cubic x ≤ cubic y := by
  have hy0 : 0 ≤ y := le_trans hx hxy
  have hx1 : x ≤ 1 := le_trans hxy hy
  have hx2 : x ^ 2 ≤ x := by nlinarith [mul_nonneg hx (sub_nonneg.mpr hx1)]
  have hy2 : y ^ 2 ≤ y := by nlinarith [mul_nonneg hy0 (sub_nonneg.mpr hy)]
  have hxy2 : 2 * x * y ≤ x ^ 2 + y ^ 2 := by
    nlinarith [sq_nonneg (x - y)]
  have hbracket :
      0 ≤ 3 * (x + y) - 2 * (x ^ 2 + x * y + y ^ 2) := by
    nlinarith
  have hprod := mul_nonneg (sub_nonneg.mpr hxy) hbracket
  have heq :
      cubic y - cubic x =
        (y - x) * (3 * (x + y) - 2 * (x ^ 2 + x * y + y ^ 2)) := by
    unfold cubic
    ring
  linarith

def amp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => cubic (amp n x)

theorem amp_mem_unit (n : ℕ) {x : ℝ}
    (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ amp n x ∧ amp n x ≤ 1 := by
  induction n with
  | zero => exact ⟨hx, hx1⟩
  | succ n ih =>
      change 0 ≤ cubic (amp n x) ∧ cubic (amp n x) ≤ 1
      exact ⟨cubic_nonneg ih.1 ih.2, cubic_le_one ih.1 ih.2⟩

theorem amp_compl (n : ℕ) (x : ℝ) :
    amp n (1 - x) = 1 - amp n x := by
  induction n with
  | zero => rfl
  | succ n ih =>
      change cubic (amp n (1 - x)) = 1 - cubic (amp n x)
      rw [ih, cubic_compl]

theorem amp_three_le_quarter {x : ℝ}
    (hx : 0 ≤ x) (hmax : x ≤ 2 / 5) :
    amp 3 x ≤ 1 / 4 := by
  have hx1 : x ≤ 1 := by linarith
  have hc1 : 0 ≤ cubic x := cubic_nonneg hx hx1
  have h1 : cubic x ≤ (9 / 25 : ℝ) := by
    calc
      cubic x ≤ cubic (2 / 5) :=
        cubic_mono hx hmax (by norm_num)
      _ ≤ 9 / 25 := by norm_num [cubic]
  have hc2 : 0 ≤ cubic (cubic x) :=
    cubic_nonneg hc1 (le_trans h1 (by norm_num))
  have h2 : cubic (cubic x) ≤ (3 / 10 : ℝ) := by
    calc
      cubic (cubic x) ≤ cubic (9 / 25) :=
        cubic_mono hc1 h1 (by norm_num)
      _ ≤ 3 / 10 := by norm_num [cubic]
  have h3 : cubic (cubic (cubic x)) ≤ (1 / 4 : ℝ) := by
    calc
      cubic (cubic (cubic x)) ≤ cubic (3 / 10) :=
        cubic_mono hc2 h2 (by norm_num)
      _ ≤ 1 / 4 := by norm_num [cubic]
  exact h3

theorem cubic_quadratic_bound {x : ℝ} (hx : 0 ≤ x) :
    3 * cubic x ≤ (3 * x) ^ 2 := by
  unfold cubic
  nlinarith [pow_nonneg hx 3]

noncomputable def tailBound : ℕ → ℝ
  | 0 => 3 / 4
  | n + 1 => (tailBound n) ^ 2

theorem tailBound_nonneg (n : ℕ) : 0 ≤ tailBound n := by
  induction n with
  | zero => norm_num [tailBound]
  | succ n ih =>
      change 0 ≤ (tailBound n) ^ 2
      positivity

theorem tailBound_eq (n : ℕ) :
    tailBound n = (3 / 4 : ℝ) ^ (2 ^ n) := by
  induction n with
  | zero => norm_num [tailBound]
  | succ n ih =>
      change tailBound n ^ 2 = (3 / 4 : ℝ) ^ (2 ^ (n + 1))
      rw [ih, ← pow_mul]
      congr 1

theorem amp_tail
    (n : ℕ) {x : ℝ} (hx : 0 ≤ x) (hmax : x ≤ 2 / 5) :
    3 * amp (n + 3) x ≤ tailBound n := by
  induction n with
  | zero =>
      have h := amp_three_le_quarter hx hmax
      change 3 * amp 3 x ≤ 3 / 4
      linarith
  | succ n ih =>
      have hu : 0 ≤ amp (n + 3) x :=
        (amp_mem_unit (n + 3) hx (by linarith)).1
      have hq := cubic_quadratic_bound hu
      have hsum : 0 ≤ 3 * amp (n + 3) x + tailBound n :=
        add_nonneg (mul_nonneg (by norm_num) hu) (tailBound_nonneg n)
      have hsquare :
          (3 * amp (n + 3) x) ^ 2 ≤ tailBound n ^ 2 := by
        nlinarith [mul_nonneg (sub_nonneg.mpr ih) hsum]
      change 3 * cubic (amp (n + 3) x) ≤ tailBound n ^ 2
      exact le_trans hq hsquare

theorem amp_low_tail (n : ℕ) {x : ℝ}
    (hx : 0 ≤ x) (hmax : x ≤ 2 / 5) :
    3 * amp (n + 3) x ≤ (3 / 4 : ℝ) ^ (2 ^ n) := by
  rw [← tailBound_eq]
  exact amp_tail n hx hmax

theorem amp_high_tail (n : ℕ) {x : ℝ}
    (hx : 3 / 5 ≤ x) (hx1 : x ≤ 1) :
    3 * (1 - amp (n + 3) x) ≤ (3 / 4 : ℝ) ^ (2 ^ n) := by
  have hlow := amp_low_tail n
    (show 0 ≤ 1 - x by linarith)
    (show 1 - x ≤ 2 / 5 by linarith)
  rw [amp_compl] at hlow
  exact hlow

end Nightfall.StrongSmoothing
