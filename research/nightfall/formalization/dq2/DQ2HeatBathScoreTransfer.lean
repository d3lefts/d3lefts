import Mathlib

/-!
# DQ2 heat-bath score-duality interface (scalar, scope-limited)

This file kernel-proves scalar score-duality and Q2 transfer *assuming* the
explicit covariance / heat-bath / influence comparison hypotheses. It is
NOT an unconditional finite dependent-law theorem, and does NOT prove the
Dobrushin Poincare inequality itself. All inputs remain in theorem types.
-/

namespace Nightfall.DQ2

/-- Cauchy + Poincare + score correlation implies a lower covariance bound. -/
theorem score_duality_from_heatbath_contract
    (q v γ L covariance scoreEnergy cross : ℝ)
    (hq : 0 ≤ q) (hv : 0 < v) (hγ : 0 < γ)
    (hcov : 0 ≤ covariance)
    (hCross : v * q ≤ cross)
    (hCauchy : cross ^ 2 ≤ covariance * scoreEnergy)
    (hHeatBath : γ * scoreEnergy ≤ L ^ 2 * q) :
    (v ^ 2 * γ) * q ≤ L ^ 2 * covariance := by
  by_cases hq0 : q = 0
  · subst q
    simp only [mul_zero]
    exact mul_nonneg (sq_nonneg _) hcov
  have hqpos : 0 < q := lt_of_le_of_ne hq (Ne.symm hq0)
  have hvq : 0 ≤ v * q := mul_nonneg (le_of_lt hv) hq
  have hcross0 : 0 ≤ cross := le_trans hvq hCross
  have hsq : (v * q) ^ 2 ≤ cross ^ 2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hCross)
      (add_nonneg hvq hcross0)]
  have hchain : γ * (v * q) ^ 2 ≤ covariance * (L ^ 2 * q) := by
    calc
      γ * (v * q) ^ 2 ≤ γ * cross ^ 2 :=
        mul_le_mul_of_nonneg_left hsq (le_of_lt hγ)
      _ ≤ γ * (covariance * scoreEnergy) :=
        mul_le_mul_of_nonneg_left hCauchy (le_of_lt hγ)
      _ = covariance * (γ * scoreEnergy) := by ring
      _ ≤ covariance * (L ^ 2 * q) :=
        mul_le_mul_of_nonneg_left hHeatBath hcov
  have hrewrite : (v ^ 2 * γ * q) * q ≤
      (L ^ 2 * covariance) * q := by
    calc
      (v ^ 2 * γ * q) * q = γ * (v * q) ^ 2 := by ring
      _ ≤ covariance * (L ^ 2 * q) := hchain
      _ = (L ^ 2 * covariance) * q := by ring
  exact (mul_le_mul_iff_of_pos_right hqpos).mp hrewrite

/-- Assumption-transparent Q2 transport from a product reference law. -/
theorem reference_q2_transfer
    (Vdep Vprod Idep Iprod K B κ η : ℝ)
    (hVdep : 0 ≤ Vdep) (hVprod : 0 ≤ Vprod)
    (hK : 0 ≤ K) (hκ : 0 ≤ κ) (hη : 0 ≤ η)
    (hVar : Vdep ≤ κ * Vprod)
    (hProductQ2 : Vprod ^ 2 ≤ K * B ^ 2 * Iprod)
    (hInfluence : η * Iprod ≤ Idep) :
    η * Vdep ^ 2 ≤ κ ^ 2 * K * B ^ 2 * Idep := by
  have hκVprod : 0 ≤ κ * Vprod := mul_nonneg hκ hVprod
  have hsq : Vdep ^ 2 ≤ (κ * Vprod) ^ 2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVar)
      (add_nonneg hVdep hκVprod)]
  have hcoef : 0 ≤ κ ^ 2 * K * B ^ 2 :=
    mul_nonneg (mul_nonneg (sq_nonneg κ) hK) (sq_nonneg B)
  calc
    η * Vdep ^ 2 ≤ η * (κ * Vprod) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq hη
    _ = κ ^ 2 * (η * Vprod ^ 2) := by ring
    _ ≤ κ ^ 2 * (η * (K * B ^ 2 * Iprod)) :=
      mul_le_mul_of_nonneg_left
        (mul_le_mul_of_nonneg_left hProductQ2 hη) (sq_nonneg κ)
    _ = (κ ^ 2 * K * B ^ 2) * (η * Iprod) := by ring
    _ ≤ (κ ^ 2 * K * B ^ 2) * Idep :=
      mul_le_mul_of_nonneg_left hInfluence hcoef
    _ = κ ^ 2 * K * B ^ 2 * Idep := by ring

/-- Bias-aware DQ2 v4 transfer, with all operator estimates as hypotheses.
The denominator-free form keeps coefficient positivity explicit. -/
theorem biased_heatbath_q2_scalar_terminal
    (Vdep Vprod Idep Iprod K B γ β v L : ℝ)
    (hVdep : 0 ≤ Vdep) (hVprod : 0 ≤ Vprod)
    (hK : 0 ≤ K) (hγ : 0 < γ) (hβ : 0 < β) (hv : 0 < v)
    (hVar : γ ^ 2 * β ^ 2 * Vdep ≤ 2 * Vprod)
    (hInfluence : v ^ 3 * γ * Iprod ≤ L ^ 2 * Idep)
    (hProductQ2 : Vprod ^ 2 ≤ K * B ^ 2 * Iprod) :
    (γ ^ 5 * β ^ 4 * v ^ 3) * Vdep ^ 2 ≤
      4 * L ^ 2 * K * B ^ 2 * Idep := by
  have hleft : 0 ≤ γ ^ 2 * β ^ 2 * Vdep := by positivity
  have hright : 0 ≤ 2 * Vprod := by positivity
  have hsq : (γ ^ 2 * β ^ 2 * Vdep) ^ 2 ≤ (2 * Vprod) ^ 2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVar)
      (add_nonneg hleft hright)]
  have hcoef : 0 ≤ v ^ 3 * γ := by positivity
  have hfour : 0 ≤ 4 * K * B ^ 2 := by positivity
  calc
    (γ ^ 5 * β ^ 4 * v ^ 3) * Vdep ^ 2 =
        (v ^ 3 * γ) * (γ ^ 2 * β ^ 2 * Vdep) ^ 2 := by ring
    _ ≤ (v ^ 3 * γ) * (2 * Vprod) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq hcoef
    _ = 4 * (v ^ 3 * γ) * Vprod ^ 2 := by ring
    _ ≤ 4 * (v ^ 3 * γ) * (K * B ^ 2 * Iprod) :=
      mul_le_mul_of_nonneg_left hProductQ2 (by positivity)
    _ = (4 * K * B ^ 2) * (v ^ 3 * γ * Iprod) := by ring
    _ ≤ (4 * K * B ^ 2) * (L ^ 2 * Idep) :=
      mul_le_mul_of_nonneg_left hInfluence hfour
    _ = 4 * L ^ 2 * K * B ^ 2 * Idep := by ring

#print axioms Nightfall.DQ2.score_duality_from_heatbath_contract
#print axioms Nightfall.DQ2.reference_q2_transfer
#print axioms Nightfall.DQ2.biased_heatbath_q2_scalar_terminal

/-- The marginal-variance parameter is redundant once the native conditional
variance floor is available. Exact scalar coefficient is K0*4*L²/(gamma⁵*v⁷),
still conditional on the stated variance/influence operator comparisons. -/
theorem local_floor_heatbath_q2_scalar_terminal
    (Vdep Vprod Idep Iprod K B γ v L : ℝ)
    (hVdep : 0 ≤ Vdep) (hVprod : 0 ≤ Vprod)
    (hK : 0 ≤ K) (hγ : 0 < γ) (hv : 0 < v)
    (hVar : γ ^ 2 * v ^ 2 * Vdep ≤ 2 * Vprod)
    (hInfluence : v ^ 3 * γ * Iprod ≤ L ^ 2 * Idep)
    (hProductQ2 : Vprod ^ 2 ≤ K * B ^ 2 * Iprod) :
    (γ ^ 5 * v ^ 7) * Vdep ^ 2 ≤
      4 * L ^ 2 * K * B ^ 2 * Idep := by
  calc
    (γ ^ 5 * v ^ 7) * Vdep ^ 2 =
        (γ ^ 5 * v ^ 4 * v ^ 3) * Vdep ^ 2 := by ring
    _ ≤ 4 * L ^ 2 * K * B ^ 2 * Idep :=
      biased_heatbath_q2_scalar_terminal Vdep Vprod Idep Iprod
        K B γ v v L hVdep hVprod hK hγ hv hv
        hVar hInfluence hProductQ2

#print axioms Nightfall.DQ2.local_floor_heatbath_q2_scalar_terminal

end Nightfall.DQ2
