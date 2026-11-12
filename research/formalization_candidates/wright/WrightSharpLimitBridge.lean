import Mathlib

/-!
# Wright full-manuscript proof obligations: exact sharp constants and limit closure

This file contains **actual proved Lean lemmas** at two interfaces:
(1) exact algebra of the sharp resampling constant rho = 4 - 2 sqrt 3,
    including a three-point equality witness and the median mixed-moment
    numerical bound; and
(2) finite-bound-to-limit closure for an abstract sequence of finite
    approximations, without swapping a supremum and a limit.

These declarations do NOT prove the missing analytic sharp finite-alphabet
median/row-cost/resampling inequalities, nor construct the finite rectangular
conditional expectation approximants on arbitrary measurable products.
They are not the full Wright manuscript theorem.
-/

namespace Nightfall.Wright.SharpLimit

open Filter

noncomputable def rho : ℝ := 4 - 2 * Real.sqrt 3
noncomputable def extremalMass : ℝ := (Real.sqrt 3 - 1) / 2

/-- The exact scalar identity at the core of Wright's sharp resampling
coefficient, with no numerical approximation. -/
theorem rho_square_identity (z : ℝ) :
    rho * (1 / 2 + z) - 2 * z * (1 - z) =
      2 * (z - extremalMass) ^ 2 := by
  have hs : (Real.sqrt (3 : ℝ)) ^ 2 = 3 :=
    Real.sq_sqrt (by norm_num)
  unfold rho extremalMass
  nlinarith

/-- The underlying scalar quadratic bound is globally nonnegative. -/
theorem rho_scalar_nonnegative (z : ℝ) :
    2 * z * (1 - z) ≤ rho * (1 / 2 + z) := by
  have h := rho_square_identity z
  nlinarith [sq_nonneg (z - extremalMass)]

/-- The exact three-atom mass used in the sharpness witness. -/
theorem extremal_mass_nonnegative : 0 ≤ extremalMass := by
  have hs : (Real.sqrt (3 : ℝ)) ^ 2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hs0 : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  unfold extremalMass
  nlinarith

/-- The center atom of the three-point witness has positive mass. -/
theorem extremal_center_positive : 0 < 1 - 2 * extremalMass := by
  have hs : (Real.sqrt (3 : ℝ)) ^ 2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hs0 : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  unfold extremalMass
  nlinarith

/-- Three-point equality in the exact resampling bound; together with
the preceding masses this certifies the numerical sharpness example. -/
theorem rho_three_atom_equality :
    2 * extremalMass ^ 2 +
        2 * extremalMass * (1 - 2 * extremalMass) =
      rho * (2 * extremalMass + (1 - 2 * extremalMass) / 2) := by
  have hs : (Real.sqrt (3 : ℝ)) ^ 2 = 3 :=
    Real.sq_sqrt (by norm_num)
  unfold rho extremalMass
  nlinarith

/-- Exact mixed-moment numerical optimization used in the stronger
two-sided median calculation (a=A^(2/3), b=B^(2/3)). -/
theorem mixed_median_bound (a b : ℝ)
    (ha0 : 0 ≤ a) (hb0 : 0 ≤ b)
    (ha1 : a ≤ 1) (hb1 : b ≤ 1)
    (hab : a * b ≤ 1 / 4) :
    a + b ≤ 5 / 4 := by
  have h := mul_nonneg (sub_nonneg.mpr ha1) (sub_nonneg.mpr hb1)
  nlinarith

/-- The manuscript's row-cost and resampling factors combine to the
exact denominator rho * pi^4 * d^6. -/
theorem sharp_denominator_identity (r p d : ℝ) :
    (4 * r * d ^ 2) * ((p ^ 2 * d ^ 2) / 2) ^ 2 =
      r * p ^ 4 * d ^ 6 := by
  ring

/-- A variance-power inequality survives any convergent sequence of
finite partitions if its right side is uniform. This is an abstract limit
lemma, NOT a construction of conditional expectations. -/
theorem finite_bounds_pass_to_limit
    (c : ℝ) {v : ℕ → ℝ} {V D : ℝ}
    (hv : Tendsto v atTop (nhds V))
    (hn : ∀ n, c * (v n) ^ 5 ≤ D) :
    c * V ^ 5 ≤ D := by
  have ht : Tendsto (fun n => c * (v n) ^ 5) atTop
        (nhds (c * V ^ 5)) :=
    tendsto_const_nhds.mul (hv.pow 5)
  exact le_of_tendsto ht (Filter.Eventually.of_forall hn)

/-- Do not select a single finite-stage influential coordinate in advance:
a uniform bound on all coordinate influences suffices to pass the exact
finite-stage inequality to the limit. This works for an arbitrary (even
uncountable) index type J, conditional on the approximation and finite-stage
premises explicitly supplied here. -/
theorem finite_witnesses_pass_to_limit
    {J : Type*} (c d V M : ℝ) (v : ℕ → ℝ) (I : J → ℝ)
    (hd : 0 ≤ d) (hM0 : 0 ≤ M)
    (hI0 : ∀ i, 0 ≤ I i)
    (hIM : ∀ i, I i ≤ M)
    (hv : Tendsto v atTop (nhds V))
    (hstage : ∀ n, ∃ i : J, c * (v n) ^ 5 ≤
      d ^ 12 * (I i) ^ 2) :
    c * V ^ 5 ≤ d ^ 12 * M ^ 2 := by
  have hD : 0 ≤ d ^ 12 := pow_nonneg hd _
  apply finite_bounds_pass_to_limit c hv
  intro n
  obtain ⟨i, hi⟩ := hstage n
  have hi2 : (I i) ^ 2 ≤ M ^ 2 := by
    have hh := mul_nonneg (sub_nonneg.mpr (hIM i))
      (add_nonneg (hI0 i) hM0)
    nlinarith
  exact le_trans hi (mul_le_mul_of_nonneg_left hi2 hD)

end Nightfall.Wright.SharpLimit
