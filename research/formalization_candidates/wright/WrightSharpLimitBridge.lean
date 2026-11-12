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

/-- Nonnegativity of the sharp resampling coefficient follows from the
already-certified global scalar inequality. -/
theorem rho_nonnegative : 0 ≤ rho := by
  have h := rho_scalar_nonnegative (1 / 2 : ℝ)
  norm_num at h ⊢
  linarith

/-- Exact coefficient arithmetic for the full Wright sharp theorem.

The three *analytic* hypotheses correspond to the real proof obligations:
(1) the strengthened certificate-to-influence principle (hprinciple),
(2) the improved row cost K ≤ π²d²/2 (hK), and
(3) the total increment L ≤ 4ρd² (hL).
The result eliminates the auxiliary K,L and yields the exact squared
Wright manuscript coefficient. It is conditional on these premises,
not a compiled proof of the full manuscript. -/
theorem sharp_constant_endpoint_of_analytic_inputs
    (V M L K d : ℝ)
    (hM : 0 ≤ M) (hL0 : 0 ≤ L) (hK0 : 0 ≤ K) (hd : 0 ≤ d)
    (hrow : K ≤ Real.pi ^ 2 * d ^ 2 / 2)
    (hincr : L ≤ 4 * rho * d ^ 2)
    (hprinciple :
      15 * ((8 : ℝ) / 5) ^ 3 * V ^ 5 ≤
        (125 * L * K ^ 2 * M) ^ 2) :
    15 * ((8 : ℝ) / 5) ^ 3 * V ^ 5 ≤
      (125 * rho * Real.pi ^ 4 * d ^ 6 * M) ^ 2 := by
  have hrho : 0 ≤ rho := rho_nonnegative
  let T : ℝ := Real.pi ^ 2 * d ^ 2 / 2
  have hT : 0 ≤ T := by dsimp [T]; positivity
  have hK2 : K ^ 2 ≤ T ^ 2 := by
    have hdiff : 0 ≤ (T - K) * (T + K) :=
      mul_nonneg (sub_nonneg.mpr (show K ≤ T from hrow))
        (add_nonneg hT hK0)
    nlinarith
  have hL2 : L * K ^ 2 ≤ rho * Real.pi ^ 4 * d ^ 6 := by
    calc
      L * K ^ 2 ≤ (4 * rho * d ^ 2) * K ^ 2 :=
        mul_le_mul_of_nonneg_right hincr (sq_nonneg K)
      _ ≤ (4 * rho * d ^ 2) * T ^ 2 :=
        mul_le_mul_of_nonneg_left hK2 (by positivity)
      _ = rho * Real.pi ^ 4 * d ^ 6 := by
        dsimp [T]
        ring
  have hQ : 125 * L * K ^ 2 * M ≤
      125 * rho * Real.pi ^ 4 * d ^ 6 * M := by
    calc
      125 * L * K ^ 2 * M = (125 * M) * (L * K ^ 2) := by ring
      _ ≤ (125 * M) * (rho * Real.pi ^ 4 * d ^ 6) :=
        mul_le_mul_of_nonneg_left hL2 (by positivity)
      _ = 125 * rho * Real.pi ^ 4 * d ^ 6 * M := by ring
  have hQ0 : 0 ≤ 125 * L * K ^ 2 * M := by positivity
  have hP0 : 0 ≤ 125 * rho * Real.pi ^ 4 * d ^ 6 * M := by positivity
  have hSquare :
      (125 * L * K ^ 2 * M) ^ 2 ≤
        (125 * rho * Real.pi ^ 4 * d ^ 6 * M) ^ 2 := by
    have hdiff := mul_nonneg (sub_nonneg.mpr hQ) (add_nonneg hQ0 hP0)
    nlinarith
  exact le_trans hprinciple hSquare


end Nightfall.Wright.SharpLimit
