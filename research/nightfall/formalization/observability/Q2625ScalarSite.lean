import Mathlib

/-!
# Degree-two coupled site envelope

No unproved measure statement. This is a deterministic algebraic
implication with explicit local fourth-moment tradeoff premise.
-/

namespace Nightfall.Q2625ScalarSite

/-- An exact pointwise improvement that keeps the energy cap, and
uses the L1-L2-L4 tradeoff only where the singleton is small. -/
theorem coupled_site
    (a u z s c T rho delta gamma : ℝ)
    (hT : 0 ≤ T) (ha : 0 ≤ a) (haT : a ≤ T)
    (hc : 0 ≤ c) (hrho : 1 ≤ rho) (hdelta : 0 ≤ delta)
    (hgamma : 0 ≤ gamma) (hrd : 2 * rho * delta = 1)
    (hJensen : a ≤ u) (hnoise : z ≤ u + a)
    (henergy : s ≤ T^2)
    (htrade : s ≤ rho * T * z + gamma * T * c) :
    a^2 + s ≤
      T * (rho * u + (rho + delta) * a + gamma * c) := by
  by_cases hsmall : a ≤ delta * T
  · have hsq : a^2 ≤ delta*T*a := by
      nlinarith [mul_nonneg ha (sub_nonneg.mpr hsmall)]
    have hrT : 0 ≤ rho*T := mul_nonneg (by linarith) hT
    have hz := mul_le_mul_of_nonneg_left hnoise hrT
    nlinarith
  · have hlarge : delta*T ≤ a := le_of_lt (lt_of_not_ge hsmall)
    have hupper : a ≤ 2*rho*T := by
      nlinarith [mul_nonneg hT (sub_nonneg.mpr hrho)]
    have hfactor : 0 ≤ (a-delta*T)*(2*rho*T-a) :=
      mul_nonneg (by linarith) (by linarith)
    have hidentity : 2*rho*delta*T^2 = T^2 := by
      nlinarith [congrArg (fun v : ℝ => v*T^2) hrd]
    have hrT : 0 ≤ rho*T := mul_nonneg (by linarith) hT
    have hu := mul_le_mul_of_nonneg_left hJensen hrT
    have hgc : 0 ≤ gamma*T*c :=
      mul_nonneg (mul_nonneg hgamma hT) hc
    nlinarith [hfactor, hu]

end Nightfall.Q2625ScalarSite
