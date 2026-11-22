import Mathlib

/-!
# NIGHTFALL prime-zeta: analytic shift and first-strip coefficient bridges

This module is a deliberately *scoped* Lean formalization of the new paper-level
prime-zeta deduction. It does NOT construct the prime zeta function and does NOT
prove its meromorphic continuation, natural boundary or the analytic continuation
of the shifted Dirichlet series. Those source-specific analytic obligations remain
open. All assertions below are exact kernel-checked consequences of the stated
`AnalyticAt` premises, with no new axioms.

Analytic bridge: for A(s) = s * P(s+1) + H(s), at any s != 0 where H is
analytic, A is analytic iff P is analytic at s+1. This is the local
non-cancellation step used in the natural boundary transfer.

Arithmetic bridge: if the logarithmic monodromy coefficient is s*A/D for
an integer numerator A and nonzero integer denominator D, its vanishing is
equivalent to A=0 (provided s!=0). The **existence and completeness** of
the real prime-zeta source fiber are not established by this module.
-/

namespace Nightfall.PrimeZetaAnalyticBridge

noncomputable section

/-- The analytic *expression* appearing in the shifted prime-zeta first-layer
decomposition. Functions are arbitrary: this is a conditional transfer theorem,
not the construction of prime zeta. -/
def shiftedTerm (P H : ℂ → ℂ) (s : ℂ) : ℂ :=
  s * P (s + 1) + H s

/-- A holomorphic first-layer remainder and a nonvanishing shift factor
make the holomorphy of the shifted expression equivalent to that of
the source P at the translated coordinate. -/
theorem analyticAt_shifted_iff (P H : ℂ → ℂ) (s : ℂ)
    (hs : s ≠ 0) (hH : AnalyticAt ℂ H s) :
    AnalyticAt ℂ (shiftedTerm P H) s ↔ AnalyticAt ℂ P (s + 1) := by
  constructor
  · intro hA
    have hm : AnalyticAt ℂ (fun t : ℂ => t * P (t + 1)) s := by
      have hh := hA.fun_sub hH
      convert hh using 1
      ext t
      simp only [shiftedTerm]
      ring
    have hid : AnalyticAt ℂ (fun t : ℂ => t) s := by fun_prop
    have hpShift : AnalyticAt ℂ (fun t : ℂ => P (t + 1)) s := by
      exact (analyticAt_iff_analytic_fun_mul hid hs).2 hm
    have htranslate : AnalyticAt ℂ (fun w : ℂ => w - 1) (s + 1) := by fun_prop
    have hp : AnalyticAt ℂ (fun w : ℂ => P ((w - 1) + 1)) (s + 1) := by
      apply AnalyticAt.fun_comp_of_eq hpShift htranslate
      ring
    convert hp using 1
    ext w
    congr 1
    ring
  · intro hP
    have htranslate : AnalyticAt ℂ (fun t : ℂ => t + 1) s := by fun_prop
    have hpShift : AnalyticAt ℂ (fun t : ℂ => P (t + 1)) s :=
      by
        apply AnalyticAt.fun_comp_of_eq hP htranslate
        ring
    have hid : AnalyticAt ℂ (fun t : ℂ => t) s := by fun_prop
    have hprod : AnalyticAt ℂ (fun t : ℂ => t * P (t + 1)) s :=
      hid.fun_mul hpShift
    have hsum := hprod.fun_add hH
    change AnalyticAt ℂ (fun t : ℂ => t * P (t + 1) + H t) s
    exact hsum

/-- Exact pointwise analytic-obstruction transfer for a given branch.
To derive a NATURAL BOUNDARY of a specific Dirichlet series, one must
separately establish a no-extension premise for *every* local branch. -/
theorem shifted_not_analytic_of_source_not_analytic (P H : ℂ → ℂ) (s : ℂ)
    (hs : s ≠ 0) (hH : AnalyticAt ℂ H s)
    (hP : ¬ AnalyticAt ℂ P (s + 1)) :
    ¬ AnalyticAt ℂ (shiftedTerm P H) s := by
  intro hA
  exact hP ((analyticAt_shifted_iff P H s hs hH).mp hA)

/-- At a nonzero first-strip basepoint, the coefficient of the log germ
vanishes iff the source residue vanishes. -/
theorem shifted_log_coefficient_eq_zero_iff (s M : ℂ) (hs : s ≠ 0) :
    s * M = 0 ↔ M = 0 := by
  simp [hs]

/-- The integer-cleared certificate has exactly the same zero set as the
shifted complex coefficient, when the denominator and shift are nonzero.
This does not certify that a particular integer A came from actual ζ zeros. -/
theorem cleared_integer_coefficient_eq_zero_iff (s : ℂ) (A D : ℤ)
    (hs : s ≠ 0) (hD : D ≠ 0) :
    s * ((A : ℂ) / (D : ℂ)) = 0 ↔ A = 0 := by
  simp [hs, hD]

#print axioms Nightfall.PrimeZetaAnalyticBridge.analyticAt_shifted_iff
#print axioms Nightfall.PrimeZetaAnalyticBridge.shifted_not_analytic_of_source_not_analytic
#print axioms Nightfall.PrimeZetaAnalyticBridge.shifted_log_coefficient_eq_zero_iff
#print axioms Nightfall.PrimeZetaAnalyticBridge.cleared_integer_coefficient_eq_zero_iff
#print Nightfall.PrimeZetaAnalyticBridge.analyticAt_shifted_iff
#print Nightfall.PrimeZetaAnalyticBridge.cleared_integer_coefficient_eq_zero_iff

end

end Nightfall.PrimeZetaAnalyticBridge
