import Mathlib

/-!
# NIGHTFALL Q2: exact four-sample Bernstein certificate

This avoids importing any analytic trigonometric Bernstein theorem:
the derivative functional of a frequency-≤2 real trig polynomial
is represented by four point evaluations whose signed total
variation is exactly 2.

No false source implication is asserted: the separate source rotation
module must prove that the actual product expectation is a
degree-2 trigonometric polynomial and has derivative Σ singleton L².
-/

namespace Nightfall.Q2190
open Finset

noncomputable def r : ℝ := Real.sqrt 2 / 2
noncomputable def A : ℝ := (1 + r) / 2
noncomputable def D : ℝ := (1 - r) / 2

theorem r_nonneg : 0 ≤ r := by
  unfold r
  positivity

theorem r_sq : r ^ 2 = 1 / 2 := by
  unfold r
  have h := Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)
  nlinarith

theorem r_le_one : r ≤ 1 := by
  have h := r_sq
  nlinarith [r_nonneg]

theorem A_nonneg : 0 ≤ A := by
  unfold A
  have h := r_nonneg
  linarith

theorem D_nonneg : 0 ≤ D := by
  unfold D
  have h := r_le_one
  linarith

theorem A_add_D : A + D = 1 := by
  unfold A D
  ring

theorem A_sub_D : A - D = r := by
  unfold A D
  ring

theorem fourpoint_derivative_factor : 2 * r * (A - D) = 1 := by
  rw [A_sub_D]
  nlinarith [r_sq]

/-- The values of c0+c1 cos(t)+s1 sin(t)+c2 cos(2t)+s2 sin(2t)
at π/4, 3π/4, 5π/4 and 7π/4, expressed without transcendental
angles. -/
noncomputable def point1 (c0 c1 s1 c2 s2 : ℝ) : ℝ :=
  c0 + r*c1 + r*s1 + s2

noncomputable def point2 (c0 c1 s1 c2 s2 : ℝ) : ℝ :=
  c0 - r*c1 + r*s1 - s2

noncomputable def point3 (c0 c1 s1 c2 s2 : ℝ) : ℝ :=
  c0 - r*c1 - r*s1 + s2

noncomputable def point4 (c0 c1 s1 c2 s2 : ℝ) : ℝ :=
  c0 + r*c1 - r*s1 - s2

/-- Exact degree-two trigonometric derivative quadrature.
This is an identity in real algebra with sqrt(2)^2 = 2. -/
theorem fourpoint_derivative_exact
    (c0 c1 s1 c2 s2 : ℝ) :
    s1 + 2*s2 =
      A*(point1 c0 c1 s1 c2 s2 - point4 c0 c1 s1 c2 s2) -
      D*(point2 c0 c1 s1 c2 s2 - point3 c0 c1 s1 c2 s2) := by
  dsimp [point1, point2, point3, point4]
  have hs := fourpoint_derivative_factor
  have ht := A_add_D
  nlinarith

/-- The entire four-sample derivative bound with no analytic
Bernstein axiom and no hidden positivity/sampling hypothesis. -/
theorem fourpoint_functional_bound
    (x1 x2 x3 x4 B : ℝ)
    (h1 : |x1| ≤ B) (h2 : |x2| ≤ B)
    (h3 : |x3| ≤ B) (h4 : |x4| ≤ B) :
    |A*(x1-x4) - D*(x2-x3)| ≤ 2*B := by
  have ha := A_nonneg
  have hd := D_nonneg
  have hsum := A_add_D
  obtain ⟨h1lo,h1hi⟩ := abs_le.mp h1
  obtain ⟨h2lo,h2hi⟩ := abs_le.mp h2
  obtain ⟨h3lo,h3hi⟩ := abs_le.mp h3
  obtain ⟨h4lo,h4hi⟩ := abs_le.mp h4
  have hx14hi : A*(x1-x4) ≤ A*(2*B) :=
    mul_le_mul_of_nonneg_left (by linarith) ha
  have hx14lo : -(A*(2*B)) ≤ A*(x1-x4) := by
    have h := mul_le_mul_of_nonneg_left (show -2*B ≤ x1-x4 by linarith) ha
    nlinarith
  have hx23hi : D*(x2-x3) ≤ D*(2*B) :=
    mul_le_mul_of_nonneg_left (by linarith) hd
  have hx23lo : -(D*(2*B)) ≤ D*(x2-x3) := by
    have h := mul_le_mul_of_nonneg_left (show -2*B ≤ x2-x3 by linarith) hd
    nlinarith
  apply abs_le.mpr
  constructor <;> nlinarith

theorem degree_two_fourpoint_bernstein
    (c0 c1 s1 c2 s2 B : ℝ)
    (h1 : |point1 c0 c1 s1 c2 s2| ≤ B)
    (h2 : |point2 c0 c1 s1 c2 s2| ≤ B)
    (h3 : |point3 c0 c1 s1 c2 s2| ≤ B)
    (h4 : |point4 c0 c1 s1 c2 s2| ≤ B) :
    |s1+2*s2| ≤ 2*B := by
  have h := fourpoint_functional_bound
    (point1 c0 c1 s1 c2 s2) (point2 c0 c1 s1 c2 s2)
    (point3 c0 c1 s1 c2 s2) (point4 c0 c1 s1 c2 s2)
    B h1 h2 h3 (by simpa using h4)
  rw [fourpoint_derivative_exact]
  exact h

/-- Normalization of real spherical two-coordinate rotations.
Works for arbitrary finite alphabets, including atoms with zero mass. -/
theorem rotated_mass_normalized
    {α : Type*} [Fintype α] [DecidableEq α]
    (psi v : α → ℝ) (a b sign : ℝ)
    (hpsi : (∑ x : α, (psi x)^2) = 1)
    (hv : (∑ x : α, (v x)^2) = 1)
    (hperp : (∑ x : α, psi x * v x) = 0)
    (hunit : a^2 + b^2 = 1)
    (hsign : sign^2 = 1) :
    (∑ x : α, (a*psi x + sign*b*v x)^2) = 1 := by
  classical
  calc
    (∑ x : α, (a*psi x + sign*b*v x)^2) =
      a^2 * (∑ x : α, (psi x)^2) +
      (2*a*sign*b) * (∑ x : α, psi x*v x) +
      sign^2*b^2 * (∑ x : α, (v x)^2) := by
        rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro x _
        ring
    _ = 1 := by rw [hpsi,hv,hperp,hunit,hsign]; ring

end Nightfall.Q2190
