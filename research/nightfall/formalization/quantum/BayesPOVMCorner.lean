import Mathlib

/-!
NIGHTFALL: exact finite-outcome optimal Bayes-energy bound for the
GHZ-corner of the ternary pure-qubit ensemble.

All scalar constraints have a physical meaning: α, β are POVM-effect
diagonals on the two GHZ basis rays, γ is their real coherence,
w is the total Born probability, and γ²≤αβ is the principal
positive-semidefinite compression inequality.

**Important proof scope:** This module proves the complete optimizing
real inequality for every finite outcome family satisfying those constraints,
and constructs an equality point. It DOES NOT yet kernel-prove that arbitrary
complex Hilbert-space POVMs induce these constraints; nor construct the
physical complex measurement. Those are separate required transitive gates.
-/

namespace Nightfall.Quantum.BayesCorner

open scoped BigOperators

private theorem gram_weight_bound
    (u v a b g w : ℝ)
    (hu : 0 < u) (hv : 0 < v)
    (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hg : g ^ 2 ≤ a * b)
    (hw : u * a + v * b ≤ w) :
    g ^ 2 * (u + v) ^ 2 ≤ w * (u * b + v * a) := by
  have hcross : 0 ≤ u * v * (a - b) ^ 2 :=
    mul_nonneg (mul_nonneg hu.le hv.le) (sq_nonneg (a - b))
  have hid :
      (u * a + v * b) * (u * b + v * a) =
        (u + v) ^ 2 * (a * b) + u * v * (a - b) ^ 2 := by
    ring
  have hmain :
      (u + v) ^ 2 * (a * b) ≤
        (u * a + v * b) * (u * b + v * a) := by
    rw [hid]
    linarith
  have hcoef : 0 ≤ u * b + v * a :=
    add_nonneg (mul_nonneg hu.le hb) (mul_nonneg hv.le ha)
  calc
    g ^ 2 * (u + v) ^ 2 ≤ (a * b) * (u + v) ^ 2 :=
      mul_le_mul_of_nonneg_right hg (sq_nonneg _)
    _ ≤ (u * a + v * b) * (u * b + v * a) := by
      nlinarith [hmain]
    _ ≤ w * (u * b + v * a) :=
      mul_le_mul_of_nonneg_right hw hcoef

theorem single_outcome_bayes_bound
    (u v a b g w : ℝ)
    (hu : 0 < u) (hv : 0 < v)
    (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hg : g ^ 2 ≤ a * b)
    (hw : u * a + v * b ≤ w) :
    g ^ 2 / w ≤ (u * b + v * a) / (u + v) ^ 2 := by
  have hwm : 0 ≤ w :=
    (add_nonneg (mul_nonneg hu.le ha) (mul_nonneg hv.le hb)).trans hw
  by_cases hzero : w = 0
  · have hsum : u * a + v * b = 0 := by
      apply le_antisymm
      · simpa [hzero] using hw
      · exact add_nonneg (mul_nonneg hu.le ha) (mul_nonneg hv.le hb)
    have haMul : u * a = 0 := by
      have hvb : 0 ≤ v * b := mul_nonneg hv.le hb
      nlinarith
    have hbMul : v * b = 0 := by
      have hua : 0 ≤ u * a := mul_nonneg hu.le ha
      nlinarith
    have ha0 : a = 0 := (mul_eq_zero.mp haMul).resolve_left hu.ne'
    have hb0 : b = 0 := (mul_eq_zero.mp hbMul).resolve_left hv.ne'
    have hg0 : g = 0 := by
      rw [ha0, hb0] at hg
      nlinarith [sq_nonneg g]
    simp [hzero, ha0, hb0, hg0]
  · have hwpos : 0 < w := lt_of_le_of_ne hwm (Ne.symm hzero)
    have huv : 0 < u + v := add_pos hu hv
    have hsquare : 0 < (u + v) ^ 2 := sq_pos_of_pos huv
    apply (div_le_div_iff₀ hwpos hsquare).2
    have h := gram_weight_bound u v a b g w hu hv ha hb hg hw
    nlinarith [h]

theorem finite_povm_bayes_bound
    {Out : Type*} [Fintype Out]
    (u v : ℝ) (hu : 0 < u) (hv : 0 < v)
    (a b g w : Out → ℝ)
    (ha : ∀ z, 0 ≤ a z) (hb : ∀ z, 0 ≤ b z)
    (hg : ∀ z, (g z) ^ 2 ≤ a z * b z)
    (hw : ∀ z, u * a z + v * b z ≤ w z)
    (haSum : (∑ z, a z) = 1)
    (hbSum : (∑ z, b z) = 1) :
    (∑ z, (g z) ^ 2 / w z) ≤ 1 / (u + v) := by
  classical
  have hs :
      (∑ z, (g z) ^ 2 / w z) ≤
        ∑ z, (u * b z + v * a z) / (u + v) ^ 2 := by
    exact Finset.sum_le_sum fun z _ =>
      single_outcome_bayes_bound u v (a z) (b z) (g z) (w z)
        hu hv (ha z) (hb z) (hg z) (hw z)
  have hn : (∑ z, (u * b z + v * a z)) = u + v := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [haSum, hbSum]
    ring
  have hden : u + v ≠ 0 := (add_pos hu hv).ne'
  have heq :
      (∑ z, (u * b z + v * a z) / (u + v) ^ 2) =
        1 / (u + v) := by
    rw [← Finset.sum_div, hn]
    field_simp
    <;> ring
  exact hs.trans_eq heq

theorem physical_bayes_gain_upper
    {Out : Type*} [Fintype Out]
    (u v t : ℝ) (hu : 0 < u) (hv : 0 < v)
    (a b g w : Out → ℝ)
    (ha : ∀ z, 0 ≤ a z) (hb : ∀ z, 0 ≤ b z)
    (hg : ∀ z, (g z) ^ 2 ≤ a z * b z)
    (hw : ∀ z, u * a z + v * b z ≤ w z)
    (haSum : (∑ z, a z) = 1)
    (hbSum : (∑ z, b z) = 1) :
    (∑ z, (2 * t * g z) ^ 2 / w z) ≤
      4 * t ^ 2 / (u + v) := by
  have hbase := finite_povm_bayes_bound u v hu hv
      a b g w ha hb hg hw haSum hbSum
  have hterm : ∀ z, (2 * t * g z) ^ 2 / w z =
      (4 * t ^ 2) * ((g z) ^ 2 / w z) := by
    intro z
    ring
  simp_rw [hterm, ← Finset.mul_sum]
  calc
    4 * t ^ 2 * (∑ z, (g z) ^ 2 / w z) ≤
      4 * t ^ 2 * (1 / (u + v)) :=
      mul_le_mul_of_nonneg_left hbase (by positivity)
    _ = 4 * t ^ 2 / (u + v) := by ring

def ghzAlpha (z : Fin 3) : ℝ :=
  if z = 2 then 0 else 1 / 2

def ghzBeta (z : Fin 3) : ℝ := ghzAlpha z

def ghzGamma (z : Fin 3) : ℝ :=
  if z = 0 then 1 / 2 else if z = 1 then -(1 / 2) else 0

def ghzWeight (u v : ℝ) (z : Fin 3) : ℝ :=
  if z = 2 then 1 - u - v else (u + v) / 2

theorem ghz_three_outcome_normalized (u v : ℝ)
    (hu : 0 < u) (hv : 0 < v) (hsum : u + v ≤ 1) :
    (∀ z, 0 ≤ ghzAlpha z) ∧
    (∀ z, 0 ≤ ghzBeta z) ∧
    (∀ z, ghzGamma z ^ 2 ≤ ghzAlpha z * ghzBeta z) ∧
    (∀ z, u * ghzAlpha z + v * ghzBeta z ≤ ghzWeight u v z) ∧
    ((∑ z : Fin 3, ghzAlpha z) = 1) ∧
    ((∑ z : Fin 3, ghzBeta z) = 1) ∧
    ((∑ z : Fin 3, ghzWeight u v z) = 1) := by
  constructor
  · intro z
    fin_cases z <;> norm_num [ghzAlpha]
  constructor
  · intro z
    fin_cases z <;> norm_num [ghzBeta, ghzAlpha]
  constructor
  · intro z
    fin_cases z <;> norm_num [ghzAlpha, ghzBeta, ghzGamma]
  constructor
  · intro z
    fin_cases z <;> simp [ghzAlpha, ghzBeta, ghzWeight] <;> nlinarith
  constructor
  · norm_num [Fin.sum_univ_three, ghzAlpha]
  constructor
  · norm_num [Fin.sum_univ_three, ghzBeta, ghzAlpha]
  · simp [Fin.sum_univ_three, ghzWeight]
    <;> ring

theorem ghz_three_outcome_attains (u v t : ℝ)
    (hu : 0 < u) (hv : 0 < v) :
    (∑ z : Fin 3,
      (2 * t * ghzGamma z) ^ 2 / ghzWeight u v z) =
      4 * t ^ 2 / (u + v) := by
  have hden : u + v ≠ 0 := (add_pos hu hv).ne'
  simp [Fin.sum_univ_three, ghzGamma, ghzWeight]
  field_simp
  <;> ring

theorem ghz_three_outcome_optimal (u v t : ℝ)
    (hu : 0 < u) (hv : 0 < v) (hsum : u + v ≤ 1) :
    (∑ z : Fin 3,
      (2 * t * ghzGamma z) ^ 2 / ghzWeight u v z) =
      4 * t ^ 2 / (u + v) ∧
    (∀ {Out : Type*} [Fintype Out]
      (a b g w : Out → ℝ),
      (∀ z, 0 ≤ a z) →
      (∀ z, 0 ≤ b z) →
      (∀ z, g z ^ 2 ≤ a z * b z) →
      (∀ z, u * a z + v * b z ≤ w z) →
      (∑ z, a z) = 1 →
      (∑ z, b z) = 1 →
      (∑ z, (2 * t * g z) ^ 2 / w z) ≤
        (∑ z : Fin 3,
          (2 * t * ghzGamma z) ^ 2 / ghzWeight u v z)) := by
  constructor
  · exact ghz_three_outcome_attains u v t hu hv
  · intro Out _ a b g w ha hb hg hw haSum hbSum
    rw [ghz_three_outcome_attains u v t hu hv]
    exact physical_bayes_gain_upper u v t hu hv
      a b g w ha hb hg hw haSum hbSum

#print axioms Nightfall.Quantum.BayesCorner.ghz_three_outcome_normalized
#print axioms Nightfall.Quantum.BayesCorner.ghz_three_outcome_attains
#print axioms Nightfall.Quantum.BayesCorner.ghz_three_outcome_optimal

#print axioms Nightfall.Quantum.BayesCorner.single_outcome_bayes_bound
#print axioms Nightfall.Quantum.BayesCorner.finite_povm_bayes_bound
#print axioms Nightfall.Quantum.BayesCorner.physical_bayes_gain_upper

end Nightfall.Quantum.BayesCorner
