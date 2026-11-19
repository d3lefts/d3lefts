import ShiftedC4Bernstein

/-! Intentionally invalid proof with the original theorem TYPE intact. -/
namespace Nightfall.ShiftedC4Scalar

theorem shifted_c4_from_strong_moments
    (a s c u e q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hc : 0 ≤ c) (hu : 0 ≤ u)
    (he : e = a^2+s)
    (hholder : e^3 ≤ u^2*q)
    (hfourth : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/4 := by
  exact True.intro

end Nightfall.ShiftedC4Scalar
