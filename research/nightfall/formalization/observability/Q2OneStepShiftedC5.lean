import Mathlib

/-!
# NIGHTFALL: exact one-increment shifted reverse-L1 inequality

The coefficient c/5 is certified *for one bounded centered increment*.
This is NOT the universal multi-increment owner inequality needed for
the unconditional Q2 variance-influence coefficient 99.263.

Two essential scalar facts suffice:
 (1) t² = E||h+Y||² ≤ (||h||+c) E||h+Y|| = (a+c)u;
 (2) a=||h||≤u by Jensen and E[Y]=0.
The first uses ||Y||≤c pointwise, and has no independence beyond
a single centered random vector.

The proof below is entirely an exact sum-of-squares calculation.
-/

namespace Nightfall.Q2OneStep

/-- Pure algebraic transfer from one-step support and centered Jensen.
For a genuinely bounded centered Hilbert vector, t is the L2 norm,
u is the L1 norm, a is the shift norm and c its pointwise increment cap. -/
theorem single_increment_shifted_c5
    (t a u c : ℝ)
    (ht : 0 ≤ t) (ha : 0 ≤ a) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hsecond : t^2 ≤ (a+c)*u)
    (hjensen : a ≤ u) :
    t ≤ Real.sqrt 3*u+c/5 := by
  let r : ℝ := Real.sqrt 3
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hr2 : r^2 = 3 := Real.sq_sqrt (by norm_num)
  have hrlo : (5:ℝ)/3 ≤ r := by
    nlinarith [hr0, hr2]
  have huv : 0 ≤ r*u+c/5 := by positivity
  have hsum : t^2 ≤ (u+c)*u := by
    calc
      t^2 ≤ (a+c)*u := hsecond
      _ ≤ (u+c)*u :=
        mul_le_mul_of_nonneg_right (by linarith [hjensen] : a+c ≤ u+c) hu
  have hidentity :
      (r*u+c/5)^2-(u+c)*u =
       2*(u-c/12)^2+(47/1800)*c^2+
          (2/5)*(r-5/3)*u*c := by
    calc
      (r*u+c/5)^2-(u+c)*u =
        (r^2-3)*u^2+
        2*(u-c/12)^2+(47/1800)*c^2+
          (2/5)*(r-5/3)*u*c := by ring
      _ = 2*(u-c/12)^2+(47/1800)*c^2+
          (2/5)*(r-5/3)*u*c := by rw [hr2]; ring
  have hpos : 0 ≤
      2*(u-c/12)^2+(47/1800)*c^2+
          (2/5)*(r-5/3)*u*c := by
    have ha : 0 ≤ r-5/3 := sub_nonneg.mpr hrlo
    positivity
  have hsquare : t^2 ≤ (r*u+c/5)^2 := by
    linarith [hidentity, hpos, hsum]
  have hlinear : t ≤ r*u+c/5 := by nlinarith
  exact hlinear

/-- The exact one-step SOS identity can be audited independently. -/
theorem one_increment_sos_identity
    (r u c : ℝ) (hr : r^2=3) :
    (r*u+c/5)^2-(u+c)*u =
      2*(u-c/12)^2+(47/1800)*c^2+
        (2/5)*(r-5/3)*u*c := by
  calc
    (r*u+c/5)^2-(u+c)*u =
      (r^2-3)*u^2+
       2*(u-c/12)^2+(47/1800)*c^2+
        (2/5)*(r-5/3)*u*c := by ring
    _ = _ := by rw [hr]; ring

end Nightfall.Q2OneStep
