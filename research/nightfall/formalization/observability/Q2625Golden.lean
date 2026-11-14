import Mathlib

/-!
# Exact golden-ratio polynomial dual for Q2 fourth moment

This file establishes only the scalar homogeneous support inequality.
It does not yet connect the moment cubic to the actual product law.
-/

namespace Nightfall.Q2625Golden

noncomputable def tau : ℝ := (Real.sqrt 5 - 1) / 2

noncomputable def gamma : ℝ :=
  Real.sqrt ((5 * Real.sqrt 5 - 11) / 6)

theorem tau_sq : tau^2 = 1 - tau := by
  unfold tau
  have h : (Real.sqrt (5 : ℝ))^2 = 5 :=
    Real.sq_sqrt (by norm_num)
  nlinarith

theorem tau_nonneg : 0 ≤ tau := by
  unfold tau
  have h : (Real.sqrt (5 : ℝ))^2 = 5 :=
    Real.sq_sqrt (by norm_num)
  have hroot : 0 ≤ Real.sqrt (5 : ℝ) := Real.sqrt_nonneg _
  nlinarith

theorem tau_cube : tau^3 = 2*tau-1 := by
  calc
    tau^3 = tau*tau^2 := by ring
    _ = tau*(1-tau) := by rw [tau_sq]
    _ = 2*tau-1 := by nlinarith [tau_sq]

theorem tau_fourth : tau^4 = 2-3*tau := by
  calc
    tau^4 = tau*tau^3 := by ring
    _ = tau*(2*tau-1) := by rw [tau_cube]
    _ = 2-3*tau := by nlinarith [tau_sq]

theorem tau_fifth : tau^5 = 5*tau-3 := by
  calc
    tau^5 = tau*tau^4 := by ring
    _ = tau*(2-3*tau) := by rw [tau_fourth]
    _ = 5*tau-3 := by nlinarith [tau_sq]

theorem gamma_nonneg : 0 ≤ gamma := by
  unfold gamma
  exact Real.sqrt_nonneg _

theorem gamma_sq : 3*gamma^2 = tau^5 := by
  have hroot : (Real.sqrt (5 : ℝ))^2 = 5 :=
    Real.sq_sqrt (by norm_num)
  have hroot0 : 0 ≤ Real.sqrt (5 : ℝ) := Real.sqrt_nonneg _
  have hrad : 0 ≤ (5 * Real.sqrt (5 : ℝ) - 11) / 6 := by
    nlinarith
  have hgamma : gamma^2 =
      (5 * Real.sqrt (5 : ℝ) - 11) / 6 := by
    unfold gamma
    exact Real.sq_sqrt hrad
  have ht : tau = (Real.sqrt (5 : ℝ)-1)/2 := rfl
  rw [hgamma, tau_fifth, ht]
  ring

theorem homogeneous_golden_dual
    (X Y : ℝ) (hX : 0 ≤ X) (hY : 0 ≤ Y) :
    Y^2 * (X-Y) ≤ 3*gamma^2*X^2*(X+Y) := by
  have hcoef1 : -1 - tau^3 + 2*tau = 0 := by
    rw [tau_cube]
    ring
  have hcoef2 : tau^5-tau^2+2*tau^4 = 0 := by
    rw [tau_fifth, tau_sq, tau_fourth]
    ring
  have hfactor :
      3*gamma^2*X^2*(X+Y)-Y^2*(X-Y) =
        (Y-tau*X)^2*(Y+tau^3*X) := by
    calc
      3*gamma^2*X^2*(X+Y)-Y^2*(X-Y) =
        tau^5*X^2*(X+Y)-Y^2*(X-Y) := by rw [← gamma_sq]
      _ = (Y-tau*X)^2*(Y+tau^3*X) +
            (-1-tau^3+2*tau)*X*Y^2 +
            (tau^5-tau^2+2*tau^4)*X^2*Y := by ring
      _ = (Y-tau*X)^2*(Y+tau^3*X) := by rw [hcoef1, hcoef2]; ring
  have hfacnonneg : 0 ≤
      (Y-tau*X)^2*(Y+tau^3*X) :=
    mul_nonneg (sq_nonneg _)
      (add_nonneg hY (mul_nonneg (pow_nonneg tau_nonneg _) hX))
  linarith

end Nightfall.Q2625Golden
