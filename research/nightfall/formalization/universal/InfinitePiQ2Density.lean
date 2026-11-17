import Mathlib.MeasureTheory.Measure.SeparableMeasure
import Mathlib.MeasureTheory.Constructions.ProjectiveFamilyContent
import Mathlib.Probability.ProductMeasure

/-!
# Source-product finite-cylinder approximation

The finite measurable cylinders already form a set algebra generating
the product σ-algebra. For an arbitrary (even uncountable) index type
and arbitrary factor probability measures, they are measure-dense.
This is a genuine source-product consequence of existing Mathlib
measure-density machinery, with no externally supplied density
hypothesis, no cardinality restriction, and no coordinate atom floor.

The independent measure-dense declaration is a prerequisite for the
Q2 L² conditional-expectation limit. It does not alone certify Q2.
-/

namespace Nightfall.InfinitePiQ2Density

open MeasureTheory

universe u v

variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Every measurable event in the actual product probability space
can be approximated in symmetric-difference measure by events depending
on finitely many coordinates; no countability hypotheses. -/
theorem source_finite_cylinders_measure_dense :
    (Measure.infinitePi μ).MeasureDense (measurableCylinders X) := by
  exact Measure.MeasureDense.of_generateFrom_isSetAlgebra_finite
    (μ := Measure.infinitePi μ)
    isSetAlgebra_measurableCylinders
    (generateFrom_measurableCylinders).symm

end Nightfall.InfinitePiQ2Density
