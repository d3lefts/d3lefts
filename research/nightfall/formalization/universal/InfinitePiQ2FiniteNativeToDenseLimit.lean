import InfinitePiQ2DenseLabelLimit
import InfinitePiQ2NativeSupportedTerminal

/-!
# Finite C105.416 to arbitrary original-product dense-label limit

This is a transitive Lean application of the **unconditional finite
original-source C105.416 theorem**, on positive-support native tables,
to the arbitrary-index **true original-product L² finite-label limit**.

The only unproved bridge is made explicit as source-faithful approximate
finite-native model data: source-L² closeness, exact mean and variance
transport, original native marginal normalization, degree two on
positive support, a supported bound, and native influence control.

Unlike the old InfinitePiQ2Limit.source_q2_quadratic_limit, this uses
genuine finite-LABEL approximants, not necessarily finite-COORDINATE
conditional projections; these differ for nonatomic source factors.

This theorem is conditional on model-data existence. It does NOT assert
that arbitrary quadratic L² functions already possess the required
finite-label models, or claim the unconditional infinite Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2FiniteNativeToDenseLimit

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2DenseLabelLimit
open Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
open Nightfall.InfinitePiQ2NativeSupportedTerminal

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Concrete native finite tables that approximate f in genuine source
L². No numerical finite Q2 inequality is supplied: the theorem
below derives it from the independently certified finite C105.

The active-coordinate map is injective and each native atom weight is\nthe literal pushforward of the corresponding ORIGINAL source marginal.\nThe approximant is almost everywhere the original-source pullback of\nthe finite native table, so arbitrary unrelated surrogate laws or\nvariance-matched toy tables cannot satisfy this witness. Additional\nexact mean/variance transport and native influence/degree/bound proofs\nare still required before declaring model existence.\n\nNonempty Fin alphabets avoid transporting Fintype witnesses in this\ninterface; they can encode heterogeneous finite native alphabets. -/
def NativeFiniteQ2ApproxData
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (B M ε : ℝ) : Prop :=
  ∃ n m : ℕ,
    ∃ (active : Fin (n + 1) → ι)
      (φ : ∀ i, X i → Fin (m + 1))
      (p : Fin (n + 1) → Fin (m + 1) → ℝ)
      (g : (Fin (n + 1) → Fin (m + 1)) → ℝ)
      (h : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)),
      Function.Injective active ∧
      (∀ i, Measurable (φ i)) ∧
      (∀ i a, p i a = ((μ (active i)).map (φ (active i))).real {a}) ∧
      (fun x : (i : ι) → X i => h x) =ᵐ[Measure.infinitePi μ]
        (fun x => g (fun i => φ (active i) (x (active i)))) ∧
      ‖f - h‖ < ε ∧
      (∫ x, h x ∂ Measure.infinitePi μ) =
        (∫ x, f x ∂ Measure.infinitePi μ) ∧
      sourceL2Variance μ h =
        nativeVariance (fun _ : Fin (n + 1) => Fin (m + 1)) p g ∧
      (∀ i a, 0 ≤ p i a) ∧
      (∀ i, ∑ a : Fin (m + 1), p i a = 1) ∧
      NativeSupportedDegreeTwo
        (fun _ : Fin (n + 1) => Fin (m + 1)) p g ∧
      (∀ y, NativeSupported (fun _ : Fin (n + 1) => Fin (m + 1)) p y →
        |g y| ≤ B) ∧
      (∀ i, nativeInfluence
        (fun _ : Fin (n + 1) => Fin (m + 1)) p g i ≤ M)

/-- A genuine composition: all hypothetical model data are *structural*
finite-table/source-faithfulness statements, not the finite inequality
itself. Apply the certified finite heterogeneous C105 theorem first,
transport its variance to original-source L², and only then invoke the
certified arbitrary-index dense-label limit. -/
theorem source_q2_C105_from_finite_native_label_models
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (B M : ℝ) (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hmodels : ∀ ε : ℝ, 0 < ε →
      NativeFiniteQ2ApproxData μ f B M ε) :
    (sourceL2Variance μ f)^2 ≤
      ((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M := by
  classical
  apply source_q2_bound_of_approximate_finite_labels μ f
    (((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M)
  intro ε hε
  obtain ⟨n, m, active, φ, p, g, h, hinj, hφ, hsourceMass,
    hsourceRep, hclose, hmean, hvariance, hp, hp1, hdegree,
    hbound, hI⟩ := hmodels ε hε
  let A : Fin (n + 1) → Type := fun _ => Fin (m + 1)
  have hfinite :
      (nativeVariance A p g)^2 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M :=
    native_heterogeneous_q2_105416_supported_unconditional
      A p hp hp1 g hdegree B hB hbound M hM hI
  refine ⟨h, hclose, hmean, ?_⟩
  rw [hvariance]
  exact hfinite

#print axioms Nightfall.InfinitePiQ2FiniteNativeToDenseLimit.source_q2_C105_from_finite_native_label_models

end Nightfall.InfinitePiQ2FiniteNativeToDenseLimit
