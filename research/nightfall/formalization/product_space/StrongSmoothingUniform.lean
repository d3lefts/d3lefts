import StrongSmoothingPolynomial

/-!
# Uniform smoothed failure-event polynomial: analytic base + cubic amplification

This replaces the claimed Hoeffding/binomial smoothing lemma by an explicit
nonnegative polynomial. The base function B_k(z)=1-(1-z²)^k separates
|z|≤ε from |z|≥2ε whenever kε²≤5/16 and 4kε²≥1.
The cubic amplifier gives error at most (3/4)^(2^n)/3 in both regions
using degree at most 2k*3^(n+3).

The bounds are uniform over z∈[-1,1], using no Bernstein,
Hoeffding, spectral tail theorem, or assumed derivative estimate.
-/
namespace Nightfall.StrongSmoothing

open Polynomial

def baseValue (k : ℕ) (z : ℝ) : ℝ := 1 - (1 - z ^ 2) ^ k

theorem baseValue_mem_unit (k : ℕ) {z : ℝ}
    (hz : |z| ≤ 1) :
    0 ≤ baseValue k z ∧ baseValue k z ≤ 1 := by
  have hz0 : 0 ≤ 1 - z ^ 2 := by
    have h := mul_nonneg (sub_nonneg.mpr ((abs_le.mp hz).2))
      (show 0 ≤ 1 + z by linarith [(abs_le.mp hz).1])
    nlinarith
  have hz1 : 1 - z ^ 2 ≤ 1 := by nlinarith [sq_nonneg z]
  have hpow0 := pow_nonneg hz0 k
  have hpow1 : (1 - z ^ 2) ^ k ≤ (1 : ℝ) := by
    calc
      (1 - z ^ 2) ^ k ≤ (1 : ℝ) ^ k :=
        pow_le_pow_left₀ hz0 hz1 k
      _ = 1 := one_pow _
  dsimp [baseValue]
  constructor <;> linarith

theorem baseValue_le_mul (k : ℕ) {z : ℝ}
    (hz : |z| ≤ 1) :
    baseValue k z ≤ (k : ℝ) * z ^ 2 := by
  have hzsq : z ^ 2 ≤ 1 := by
    have hb := abs_le.mp hz
    nlinarith [mul_nonneg (sub_nonneg.mpr hb.2)
      (show 0 ≤ 1 + z by linarith [hb.1])]
  have hneg : (-2 : ℝ) ≤ -(z ^ 2) := by linarith
  have hbern := one_add_mul_le_pow hneg k
  have hb : 1 - (k : ℝ) * z ^ 2 ≤ (1 - z ^ 2) ^ k := by
    convert hbern using 1 <;> ring
  dsimp [baseValue]
  linarith

theorem complement_pow_le_two_fifths
    (k : ℕ) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hk : 1 ≤ (k : ℝ) * t) :
    (1 - t) ^ k ≤ (2 / 5 : ℝ) := by
  have hbase : 0 ≤ 1 - t := by linarith
  have hexp : 1 - t ≤ Real.exp (-t) := by
    have h := Real.add_one_le_exp (-t)
    linarith
  have hpow : (1 - t) ^ k ≤ (Real.exp (-t)) ^ k :=
    pow_le_pow_left₀ hbase hexp k
  have hxp : (Real.exp (-t)) ^ k =
      Real.exp (-((k : ℝ) * t)) := by
    rw [← Real.exp_nat_mul]
    congr 1
    ring
  have hq0 : 0 ≤ (k : ℝ) * t := by linarith
  have hquad := Real.quadratic_le_exp_of_nonneg hq0
  have hlarge : (5 / 2 : ℝ) ≤ Real.exp ((k : ℝ) * t) := by
    nlinarith [sq_nonneg ((k : ℝ) * t - 1)]
  have hprod : Real.exp (-((k : ℝ) * t)) *
      Real.exp ((k : ℝ) * t) = 1 := by
    rw [← Real.exp_add]
    simp
  have hneg : 0 ≤ Real.exp (-((k : ℝ) * t)) :=
    (Real.exp_pos _).le
  have hmult := mul_nonneg (sub_nonneg.mpr hlarge) hneg
  have hsmall : Real.exp (-((k : ℝ) * t)) ≤ (2 / 5 : ℝ) := by
    nlinarith [hprod, hmult]
  calc
    (1 - t) ^ k ≤ (Real.exp (-t)) ^ k := hpow
    _ = Real.exp (-((k : ℝ) * t)) := hxp
    _ ≤ 2 / 5 := hsmall

theorem baseValue_ge_three_fifths
    (k : ℕ) {z : ℝ}
    (hz : |z| ≤ 1)
    (hk : 1 ≤ (k : ℝ) * z ^ 2) :
    (3 / 5 : ℝ) ≤ baseValue k z := by
  have hb := complement_pow_le_two_fifths k
    (sq_nonneg z) (by
      have hzabs := abs_le.mp hz
      nlinarith [mul_nonneg (sub_nonneg.mpr hzabs.2)
        (show 0 ≤ 1 + z by linarith [hzabs.1])]) hk
  dsimp [baseValue]
  linarith

noncomputable def basePoly (k : ℕ) : Polynomial ℝ :=
  1 - (1 - X ^ 2) ^ k

theorem basePoly_eval (k : ℕ) (z : ℝ) :
    (basePoly k).eval z = baseValue k z := by
  simp [basePoly, baseValue]

theorem basePoly_natDegree_le (k : ℕ) :
    (basePoly k).natDegree ≤ 2 * k := by
  unfold basePoly
  have hx : ((1 : Polynomial ℝ) - X ^ 2).natDegree ≤ 2 := by
    have hm := Polynomial.natDegree_sub_le (1 : Polynomial ℝ)
      (X ^ 2 : Polynomial ℝ)
    have hx2 : (X ^ 2 : Polynomial ℝ).natDegree ≤ 2 := by simp
    have h1 : (1 : Polynomial ℝ).natDegree ≤ 2 := by simp
    omega
  have hp := Polynomial.natDegree_pow_le
    (p := ((1 : Polynomial ℝ) - X ^ 2)) (n := k)
  have hpow : (((1 : Polynomial ℝ) - X ^ 2) ^ k).natDegree ≤ 2 * k := by
    calc
      (((1 : Polynomial ℝ) - X ^ 2) ^ k).natDegree ≤
          k * ((1 : Polynomial ℝ) - X ^ 2).natDegree := hp
      _ ≤ k * 2 := Nat.mul_le_mul_left k hx
      _ = 2 * k := by omega
  have hb := Polynomial.natDegree_sub_le (1 : Polynomial ℝ)
    (((1 : Polynomial ℝ) - X ^ 2) ^ k)
  have h1 : (1 : Polynomial ℝ).natDegree = 0 := by simp
  omega

noncomputable def smoothPoly (k n : ℕ) : Polynomial ℝ :=
  (ampPoly (n + 3)).comp (basePoly k)

theorem smoothPoly_eval (k n : ℕ) (z : ℝ) :
    (smoothPoly k n).eval z =
      amp (n + 3) (baseValue k z) := by
  simp [smoothPoly, Polynomial.eval_comp, ampPoly_eval, basePoly_eval]

theorem smoothPoly_natDegree_le (k n : ℕ) :
    (smoothPoly k n).natDegree ≤ 2 * k * 3 ^ (n + 3) := by
  have hc := Polynomial.natDegree_comp_le
    (p := ampPoly (n + 3)) (q := basePoly k)
  have hpa := ampPoly_natDegree_le (n + 3)
  have hpb := basePoly_natDegree_le k
  unfold smoothPoly
  have hm := Nat.mul_le_mul hpa hpb
  nlinarith [hc, hm]

theorem smoothPoly_mem_unit
    (k n : ℕ) {z : ℝ} (hz : |z| ≤ 1) :
    0 ≤ (smoothPoly k n).eval z ∧
    (smoothPoly k n).eval z ≤ 1 := by
  rw [smoothPoly_eval]
  exact amp_mem_unit (n + 3)
    (baseValue_mem_unit k hz).1
    (baseValue_mem_unit k hz).2

/-- Uniform inner tail; the elementary numeric k-condition can be
satisfied by k=ceil(1/(4ε²)) when 0<ε≤1/4. -/
theorem smoothPoly_small
    (k n : ℕ) {z ε : ℝ}
    (hε : 0 ≤ ε) (hεmax : ε ≤ 1 / 4)
    (hz : |z| ≤ ε)
    (hk : (k : ℝ) * ε ^ 2 ≤ 5 / 16) :
    3 * (smoothPoly k n).eval z ≤ (3 / 4 : ℝ) ^ (2 ^ n) := by
  have hz1 : |z| ≤ 1 := by linarith
  have hzsq : z ^ 2 ≤ ε ^ 2 := by
    have hsq := mul_nonneg (sub_nonneg.mpr hz)
      (add_nonneg hε (abs_nonneg z))
    nlinarith [sq_abs z]
  have hbase : baseValue k z ≤ (2 / 5 : ℝ) := by
    have hb := baseValue_le_mul k hz1
    have hkn : 0 ≤ (k : ℝ) := Nat.cast_nonneg _
    nlinarith [mul_le_mul_of_nonneg_left hzsq hkn]
  rw [smoothPoly_eval]
  exact amp_low_tail n (baseValue_mem_unit k hz1).1 hbase

/-- Uniform outer tail, with the very same polynomial. -/
theorem smoothPoly_large
    (k n : ℕ) {z ε : ℝ}
    (hε : 0 ≤ ε) (hεmax : ε ≤ 1 / 4)
    (hz1 : |z| ≤ 1)
    (hz : 2 * ε ≤ |z|)
    (hk : 1 ≤ 4 * (k : ℝ) * ε ^ 2) :
    3 * (1 - (smoothPoly k n).eval z) ≤ (3 / 4 : ℝ) ^ (2 ^ n) := by
  have hsq : (2 * ε) ^ 2 ≤ z ^ 2 := by
    have hsq := mul_nonneg (sub_nonneg.mpr hz)
      (add_nonneg (mul_nonneg (by norm_num : 0 ≤ (2 : ℝ)) hε) (abs_nonneg z))
    nlinarith [sq_abs z]
  have hkn : 0 ≤ (k : ℝ) := Nat.cast_nonneg _
  have hgap : 1 ≤ (k : ℝ) * z ^ 2 := by
    nlinarith [mul_le_mul_of_nonneg_left hsq hkn]
  rw [smoothPoly_eval]
  exact amp_high_tail n (baseValue_ge_three_fifths k hz1 hgap)
    (baseValue_mem_unit k hz1).2

end Nightfall.StrongSmoothing
