import Mathlib
import Mathlib.Analysis.Calculus.ImplicitContDiff

/-!
# Time-oriented local zero graph at a spatially invertible endpoint

For a C-infinity Euclidean family F(t,x) in which the spatial derivative
D_x F(t0,x0) is invertible, the implicit-function theorem produces
an actual local zero-set graph x=g(t), with time as the graph coordinate.

This is the analytically correct halfspace-chart precursor at t=0:
restrict t to nonnegative values to obtain the boundary-side chart.
It avoids the false ContDiffAt-infinity-to-common-neighborhood inference.

It does NOT create an OpenPartialHomeomorph of the full physical
zero-fiber subtype, prove boundary compatibility, or assert ProductSphereZero.
-/

open scoped Topology ContDiff

namespace Nightfall.ProductBUTimeOrientedIFT

noncomputable section

/-- Exact source-local graph around a time-boundary zero, with
time as the free coordinate and an explicit smooth implicit solution.
The source neighborhood is the genuine ambient neighborhood around
(t0,x0), and the equivalence characterizes actual zeros therein. -/
theorem exists_time_oriented_zero_graph
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [CompleteSpace E]
    (F : ℝ × E → E) (t₀ : ℝ) (x₀ : E)
    (hF : ContDiffAt ℝ (∞ : ℕ∞ω) F (t₀, x₀))
    (hzero : F (t₀, x₀) = 0)
    (hspatial : (fderiv ℝ F (t₀, x₀) ∘L
      ContinuousLinearMap.inr ℝ ℝ E).IsInvertible) :
    ∃ g : ℝ → E,
      g t₀ = x₀ ∧
      ContDiffAt ℝ (∞ : ℕ∞ω) g t₀ ∧
      ∀ᶠ y : ℝ × E in 𝓝 (t₀, x₀),
        (F y = 0 ↔ y.2 = g y.1) := by
  let g : ℝ → E := hF.implicitFunction (by simp) hspatial
  have hbase : g t₀ = x₀ :=
    hF.implicitFunction_apply_self (by simp) hspatial
  have hsmooth : ContDiffAt ℝ (∞ : ℕ∞ω) g t₀ :=
    hF.contDiffAt_implicitFunction (by simp) hspatial
  have hgraph : ∀ᶠ y : ℝ × E in 𝓝 (t₀, x₀),
      F y = F (t₀, x₀) ↔ g y.1 = y.2 :=
    hF.eventually_apply_eq_iff_implicitFunction (by simp) hspatial
  refine ⟨g, hbase, hsmooth, ?_⟩
  filter_upwards [hgraph] with y hy
  constructor
  · intro hz
    exact (hy.mp (by simpa [hzero] using hz)).symm
  · intro hy'
    have hh : F y = F (t₀, x₀) := hy.mpr hy'.symm
    simpa [hzero] using hh

#check exists_time_oriented_zero_graph
#print axioms exists_time_oriented_zero_graph

end
end Nightfall.ProductBUTimeOrientedIFT
