import Mathlib

/-!
# NIGHTFALL Forrelation — information-to-mixture quantitative terminals

This file formalizes the *final information-capacity-to-exponential*
implications in the Gaussian-sign Forrelation argument. It does NOT derive
the Gaussian sign-correlation identity, the bilinear exponential-moment
bound, the KL variational inequality, the mixture data-processing/entropy
capacity inequality, or finite-alphabet entropy continuity.

Instead, those indispensable upstream inequalities are **explicitly
named hypotheses** in the types below. Therefore a successful Lean run
certifies only these conditional terminals, NOT the full exponential
Forrelation obstruction. This separation is deliberate and fail-closed.

The true input distribution is the unconditioned Gaussian-sign law on
two N-bit blocks; the scalar N is the size of *each* block. All logarithms
are natural, and the TV-robust statement requires an eta-dependent
strictly smaller exponent.
-/

namespace Nightfall.Forrelation.EntropyCore

/-- The analytic invariant needed for the exact Forrelation lower bound.
`alpha` is the mean of the normalized Forrelation statistic under P,
`I` is the mutual information (equal to D(P||U) for uniform block
marginals), and M is the number of full-coordinate product components.

The assumptions `variational` and `latentCapacity` are NOT Lean-proved
here; they are substantive outstanding formalization targets. -/
theorem exact_conditional_terminal
    (N M : ℕ) (hM : 0 < M) (alpha I : ℝ)
    (hCorrelation : (2 : ℝ) / Real.pi ≤ alpha)
    (hVariational : (N : ℝ) * alpha ^ 2 / 2 ≤ I)
    (hLatentCapacity : I ≤ Real.log (M : ℝ)) :
    Real.exp (2 * (N : ℝ) / Real.pi ^ 2) ≤ (M : ℝ) := by
  have hpi : 0 < Real.pi := Real.pi_pos
  have hpi0 : Real.pi ≠ 0 := ne_of_gt hpi
  have hMreal : (0 : ℝ) < M := by exact_mod_cast hM
  have hbase : (0 : ℝ) ≤ 2 / Real.pi := by positivity
  have hsquare : ((2 : ℝ) / Real.pi) ^ 2 ≤ alpha ^ 2 := by
    nlinarith
  have hscaled :
      (N : ℝ) * ((2 : ℝ) / Real.pi) ^ 2 / 2
        ≤ (N : ℝ) * alpha ^ 2 / 2 := by
    apply div_le_div_of_nonneg_right _ (by norm_num)
    exact mul_le_mul_of_nonneg_left hsquare (Nat.cast_nonneg N)
  have heq :
      (N : ℝ) * ((2 : ℝ) / Real.pi) ^ 2 / 2
        = 2 * (N : ℝ) / Real.pi ^ 2 := by
    field_simp
    <;> ring
  have hlog : 2 * (N : ℝ) / Real.pi ^ 2 ≤ Real.log (M : ℝ) := by
    calc
      _ = (N : ℝ) * ((2 : ℝ) / Real.pi) ^ 2 / 2 := heq.symm
      _ ≤ (N : ℝ) * alpha ^ 2 / 2 := hscaled
      _ ≤ I := hVariational
      _ ≤ Real.log (M : ℝ) := hLatentCapacity
  calc
    Real.exp (2 * (N : ℝ) / Real.pi ^ 2)
        ≤ Real.exp (Real.log (M : ℝ)) := Real.exp_le_exp.mpr hlog
    _ = (M : ℝ) := Real.exp_log hMreal

/-- TV-robust conditional terminal. The final exponent is
`(N/2) * (2/pi - 2*eta)^2 - 2*eta*N*log(2) - 2*h(eta)`,
where `h(eta)` is supplied as a scalar (the binary entropy in nats).

`hVariational` contains the *approximate* KL-vs-mgf bound, and
`hFiniteContinuityAndCapacity` combines mutual-information capacity with
two marginal entropy-continuity bounds. Neither is silently assumed true. -/
theorem tv_robust_conditional_terminal
    (N M : ℕ) (hM : 0 < M)
    (eta alpha D hEta : ℝ)
    (hEta0 : 0 ≤ eta)
    (hEtaSmall : 2 * eta < (2 : ℝ) / Real.pi)
    (hCorrelation : (2 : ℝ) / Real.pi ≤ alpha)
    (hVariational : (N : ℝ) / 2 * (alpha - 2 * eta) ^ 2 ≤ D)
    (hFiniteContinuityAndCapacity :
       D ≤ Real.log (M : ℝ) +
         2 * eta * (N : ℝ) * Real.log 2 + 2 * hEta) :
    Real.exp
        ((N : ℝ) / 2 * ((2 : ℝ) / Real.pi - 2 * eta) ^ 2 -
         2 * eta * (N : ℝ) * Real.log 2 - 2 * hEta)
      ≤ (M : ℝ) := by
  have hMreal : (0 : ℝ) < M := by exact_mod_cast hM
  have hleft : (0 : ℝ) ≤ (2 : ℝ) / Real.pi - 2 * eta :=
    le_of_lt (sub_pos.mpr hEtaSmall)
  have hdiff :
      (2 : ℝ) / Real.pi - 2 * eta ≤ alpha - 2 * eta := by
    linarith
  have hsquare :
      ((2 : ℝ) / Real.pi - 2 * eta) ^ 2 ≤ (alpha - 2 * eta) ^ 2 := by
    nlinarith
  have hN2 : (0 : ℝ) ≤ (N : ℝ) / 2 := by positivity
  have hscaled :
      (N : ℝ) / 2 * ((2 : ℝ) / Real.pi - 2 * eta) ^ 2
        ≤ (N : ℝ) / 2 * (alpha - 2 * eta) ^ 2 :=
    mul_le_mul_of_nonneg_left hsquare hN2
  have hlog :
      (N : ℝ) / 2 * ((2 : ℝ) / Real.pi - 2 * eta) ^ 2 -
      2 * eta * (N : ℝ) * Real.log 2 - 2 * hEta
      ≤ Real.log (M : ℝ) := by
    linarith
  calc
    Real.exp
        ((N : ℝ) / 2 * ((2 : ℝ) / Real.pi - 2 * eta) ^ 2 -
         2 * eta * (N : ℝ) * Real.log 2 - 2 * hEta)
      ≤ Real.exp (Real.log (M : ℝ)) := Real.exp_le_exp.mpr hlog
    _ = (M : ℝ) := Real.exp_log hMreal

end Nightfall.Forrelation.EntropyCore

#print axioms Nightfall.Forrelation.EntropyCore.exact_conditional_terminal
#print axioms Nightfall.Forrelation.EntropyCore.tv_robust_conditional_terminal
