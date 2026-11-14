import Mathlib.Probability.ProductMeasure
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Actual Measure.infinitePi finite-marginal bridge on arbitrary index sets

These are strict named kernel targets that instantiate Mathlib's product
measure on the actual input family (no surrogate law or finite-index
assumption). They give genuine finite restrictions and exact integration
of cylindrical real observables and squared centered observables.

They do NOT prove full L2 cylinder density or the conditional Jensen
influence bound for an arbitrary L2 function. These still must be
discharged before the unconditional arbitrary-index Efron–Stein endpoint.
-/

namespace Nightfall.InfinitePiSourceBridge

open MeasureTheory
open MeasureTheory.Measure

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

theorem source_finite_marginal
    (F : Finset ι) :
    Measure.map F.restrict (Measure.infinitePi μ) =
      Measure.pi (fun (i : F) => μ i) := by
  exact Measure.infinitePi_map_restrict μ

theorem source_single_coordinate
    (i : ι) :
    Measure.map (fun x : (j : ι) → X j => x i)
      (Measure.infinitePi μ) = μ i := by
  exact Measure.infinitePi_map_eval μ i

theorem source_cylinder_mass
    (F : Finset ι)
    (S : Set ((i : F) → X i))
    (hS : MeasurableSet S) :
    (Measure.infinitePi μ) (cylinder F S) =
      (Measure.pi (fun (i : F) => μ i)) S := by
  exact Measure.infinitePi_cylinder μ hS

theorem source_cylinder_integral
    (F : Finset ι)
    (g : ((i : F) → X i) → ℝ)
    (hg : AEStronglyMeasurable g (Measure.pi fun (i : F) => μ i)) :
    (∫ x : (i : ι) → X i, g (F.restrict x) ∂ Measure.infinitePi μ) =
      ∫ y : (i : F) → X i, g y ∂ Measure.pi (fun (i : F) => μ i) := by
  exact integral_restrict_infinitePi μ hg

theorem source_cylinder_squared_integral
    (F : Finset ι)
    (g : ((i : F) → X i) → ℝ)
    (hg : AEStronglyMeasurable
      (fun y : (i : F) → X i => (g y)^2)
      (Measure.pi fun (i : F) => μ i)) :
    (∫ x : (i : ι) → X i, (g (F.restrict x))^2 ∂ Measure.infinitePi μ) =
      ∫ y : (i : F) → X i, (g y)^2
        ∂ Measure.pi (fun (i : F) => μ i) := by
  exact integral_restrict_infinitePi μ hg

theorem source_cylinder_centered_square
    (F : Finset ι)
    (g : ((i : F) → X i) → ℝ)
    (m : ℝ)
    (hg : AEStronglyMeasurable
      (fun y : (i : F) → X i => (g y - m)^2)
      (Measure.pi fun (i : F) => μ i)) :
    (∫ x : (i : ι) → X i,
      (g (F.restrict x) - m)^2 ∂ Measure.infinitePi μ) =
      ∫ y : (i : F) → X i, (g y - m)^2
        ∂ Measure.pi (fun (i : F) => μ i) := by
  exact integral_restrict_infinitePi μ hg

end Nightfall.InfinitePiSourceBridge
