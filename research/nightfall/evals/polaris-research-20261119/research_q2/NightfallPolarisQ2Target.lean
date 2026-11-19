import ShiftedC4Scalar

/-!
Trusted statement for the Polaris research-level shifted-c/4 interpolation task.
The candidate supplies only the imported lemma.
This file is evaluator-owned and pinned by its Git blob.
-/

namespace Nightfall.Polaris.ResearchQ2

theorem locked_shifted_c4_interpolation
    (a s c u e q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hc : 0 ≤ c) (hu : 0 ≤ u)
    (he : e = a^2+s)
    (hholder : e^3 ≤ u^2*q)
    (hfourth : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/4 := by
  exact Nightfall.ShiftedC4Scalar.shifted_c4_from_strong_moments
    a s c u e q ha hs hc hu he hholder hfourth

end Nightfall.Polaris.ResearchQ2
