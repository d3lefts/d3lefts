import Mathlib

/-!
# NIGHTFALL: branch-aware natural-boundary chart transfer

The main analytic-boundary argument for A⁺ is *not* a claim about a single,
globally chosen value of the multivalued prime zeta function on its boundary.
This module formalizes the correct local-chart statement: for any chosen
source and shifted function on an accessible set U, a holomorphic continuation
of A through s produces a holomorphic continuation of P through s+1,
provided H has a holomorphic local continuation and the factor s is nonzero.

No zeta-specific natural boundary is stated as a Lean axiom. To obtain the
full A⁺ natural boundary one must still prove the actual prime-zeta boundary
and the actual shifted-series identities in Lean for every applicable chart.
-/

namespace Nightfall.PrimeZetaChartExtension

noncomputable section

/-- An analytic extension matching a given function on a specified chart.
The chart can be a slit/punctured subdomain. In applications require it to
contain the previously analytically continued branch; no such existence is
smuggled into this definition. -/
def HasAnalyticChartExtension (f : ℂ → ℂ) (U : Set ℂ) (z : ℂ) : Prop :=
  ∃ F : ℂ → ℂ, AnalyticAt ℂ F z ∧ Set.EqOn F f U

/-- Translate the source chart by one unit so that w = s+1. -/
def translatedChart (U : Set ℂ) : Set ℂ :=
  { w | w - 1 ∈ U }

/-- A shifted analytic continuation forces a source analytic continuation,
with full chart equality rather than merely pointwise differentiability.

This is the genuine algebraic natural-boundary transfer for *any* selected
analytic chart. No assumption that P is already analytic at the boundary is
made. -/
theorem chart_extension_transfer (P A H : ℂ → ℂ) (U : Set ℂ) (s : ℂ)
    (hs : s ≠ 0) (hU : ∀ z ∈ U, z ≠ 0)
    (hidentity : ∀ z ∈ U, A z = z * P (z + 1) + H z)
    (hH : AnalyticAt ℂ H s)
    (hA : HasAnalyticChartExtension A U s) :
    HasAnalyticChartExtension P (translatedChart U) (s + 1) := by
  obtain ⟨F, hF, hEq⟩ := hA
  refine ⟨(fun w : ℂ => (F (w - 1) - H (w - 1)) / (w - 1)), ?_, ?_⟩
  · have hShift : AnalyticAt ℂ (fun w : ℂ => w - 1) (s + 1) := by
      fun_prop
    have hFeval : AnalyticAt ℂ (fun w : ℂ => F (w - 1)) (s + 1) := by
      apply AnalyticAt.fun_comp_of_eq hF hShift
      ring
    have hHeval : AnalyticAt ℂ (fun w : ℂ => H (w - 1)) (s + 1) := by
      apply AnalyticAt.fun_comp_of_eq hH hShift
      ring
    have hnum : AnalyticAt ℂ (fun w : ℂ => F (w - 1) - H (w - 1)) (s + 1) :=
      hFeval.fun_sub hHeval
    have hdenom : (s + 1) - 1 ≠ (0 : ℂ) := by
      simpa only [add_sub_cancel_right] using hs
    exact hnum.fun_div hShift hdenom
  · intro w hw
    change w - 1 ∈ U at hw
    have hnonzero : w - 1 ≠ (0 : ℂ) := hU (w - 1) hw
    have hsource : F (w - 1) = A (w - 1) := hEq (w - 1) hw
    have hdecomp : A (w - 1) = (w - 1) * P ((w - 1) + 1) + H (w - 1) :=
      hidentity (w - 1) hw
    change (F (w - 1) - H (w - 1)) / (w - 1) = P w
    rw [hsource, hdecomp]
    have hshift : w - 1 + 1 = w := by ring
    rw [hshift]
    field_simp [hnonzero]
    ring

/-- All-branch (chart-specific) natural boundary: if no source extension
exists on the translated chart, then no shifted extension can exist on U.

The external classical prime-zeta no-extension premise is EXPLICIT. -/
theorem chart_boundary_transfer (P A H : ℂ → ℂ) (U : Set ℂ) (s : ℂ)
    (hs : s ≠ 0) (hU : ∀ z ∈ U, z ≠ 0)
    (hidentity : ∀ z ∈ U, A z = z * P (z + 1) + H z)
    (hH : AnalyticAt ℂ H s)
    (hBoundary : ¬ HasAnalyticChartExtension P (translatedChart U) (s + 1)) :
    ¬ HasAnalyticChartExtension A U s := by
  intro hA
  exact hBoundary (chart_extension_transfer P A H U s hs hU hidentity hH hA)

#print axioms Nightfall.PrimeZetaChartExtension.chart_extension_transfer
#print axioms Nightfall.PrimeZetaChartExtension.chart_boundary_transfer
#print Nightfall.PrimeZetaChartExtension.chart_extension_transfer
#print Nightfall.PrimeZetaChartExtension.chart_boundary_transfer

end

end Nightfall.PrimeZetaChartExtension
