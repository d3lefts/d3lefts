import InfinitePiSourceBridge

/-!
# Actual-source cylinder variance bridge for arbitrary index sets

Unlike a transfer theorem with an abstract variance oracle, this statement
uses the original measure `Measure.infinitePi μ` on an arbitrary dependent
product, and the actual squared centered observable. Neither the index
set nor the alphabets are assumed finite or countable.

Only finite-cylinder observables are covered. This does NOT prove density
of cylinders in L², commuting projections, or the unrestricted all-L²
Efron–Stein inequality; those remain separate certification obligations.
-/

namespace Nightfall.InfinitePiCylinderVarianceBridge

open MeasureTheory
open MeasureTheory.Measure

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- A finite-cylinder observable has *exactly* the same centered squared
integral under the genuine arbitrary-index product law as under its
actual finite marginal. Both means are computed from the respective
source measures, rather than supplied as an assumed equality. -/
theorem source_cylinder_variance_exact
    (F : Finset ι)
    (g : ((i : F) → X i) → ℝ)
    (hg : AEStronglyMeasurable g
      (Measure.pi (fun (i : F) => μ i)))
    (hcenter : AEStronglyMeasurable
      (fun y : (i : F) → X i =>
        (g y - ∫ z : (i : F) → X i, g z
          ∂ Measure.pi (fun (i : F) => μ i)) ^ 2)
      (Measure.pi (fun (i : F) => μ i))) :
    (∫ x : (i : ι) → X i,
        (g (F.restrict x) -
          ∫ z : (i : ι) → X i, g (F.restrict z)
            ∂ Measure.infinitePi μ) ^ 2
        ∂ Measure.infinitePi μ) =
    (∫ y : (i : F) → X i,
        (g y -
          ∫ z : (i : F) → X i, g z
            ∂ Measure.pi (fun (i : F) => μ i)) ^ 2
        ∂ Measure.pi (fun (i : F) => μ i)) := by
  rw [Nightfall.InfinitePiSourceBridge.source_cylinder_integral μ F g hg]
  exact Nightfall.InfinitePiSourceBridge.source_cylinder_centered_square
    μ F g
    (∫ z : (i : F) → X i, g z ∂ Measure.pi (fun (i : F) => μ i))
    hcenter

end Nightfall.InfinitePiCylinderVarianceBridge
