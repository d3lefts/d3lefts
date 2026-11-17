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

/-- A source-cylinder indicator, interpreted as an actual element of
the original infinite-product L². -/
noncomputable def sourceCylinderIndicator
    (s : Set ((i : ι) → X i))
    (hs : s ∈ measurableCylinders X)
    (c : ℝ) :
    Lp ℝ (2 : ℝ≥0∞) (Measure.infinitePi μ) :=
  indicatorConstLp 2
    ((source_finite_cylinders_measure_dense μ).measurable s hs)
    (measure_ne_top (Measure.infinitePi μ) s) c

/-- No auxiliary probability or density oracle in this generator set. -/
noncomputable def sourceCylinderGenerators :
    Set (Lp ℝ (2 : ℝ≥0∞) (Measure.infinitePi μ)) :=
  {v | ∃ (s : Set ((i : ι) → X i))
    (hs : s ∈ measurableCylinders X) (c : ℝ),
      v = sourceCylinderIndicator μ s hs c}

/-- Full L² density of finite-cylinder simple functions, over an
arbitrary source product with potentially uncountably many coordinates.
Proof: Mathlib's measurable-cylinder algebra is measure-dense, then
the induction principle for L² and closure of the real-linear span.
There is no finite-coordinate density hypothesis in the theorem. -/
theorem source_finite_cylinders_L2_dense :
    (Submodule.span ℝ (sourceCylinderGenerators μ)).topologicalClosure = ⊤ := by
  classical
  let ν := Measure.infinitePi μ
  let S := sourceCylinderGenerators μ
  let U : Submodule ℝ (Lp ℝ (2 : ℝ≥0∞) ν) :=
    Submodule.span ℝ S
  let hA := source_finite_cylinders_measure_dense μ
  have hAll : ∀ f : Lp ℝ (2 : ℝ≥0∞) ν,
      f ∈ U.topologicalClosure := by
    refine Lp.induction (μ := ν) (p := (2 : ℝ≥0∞))
      (by norm_num)
      (motive := fun f => f ∈ U.topologicalClosure) ?_ ?_
      U.isClosed_topologicalClosure
    · intro c s hs hνs
      rw [Lp.simpleFunc.coe_indicatorConst]
      have hmem :
          indicatorConstLp (2 : ℝ≥0∞) hs hνs.ne c ∈
          closure {indicatorConstLp (2 : ℝ≥0∞)
            (hA.measurable t ht) hνt c |
            (t : Set ((i : ι) → X i))
            (ht : t ∈ measurableCylinders X) (hνt : ν t ≠ ∞)} :=
        (hA.indicatorConstLp_subset_closure (p := (2 : ℝ≥0∞)) c)
          ⟨s, hs, hνs.ne, rfl⟩
      have hsub :
          {indicatorConstLp (2 : ℝ≥0∞)
            (hA.measurable t ht) hνt c |
            (t : Set ((i : ι) → X i))
            (ht : t ∈ measurableCylinders X) (hνt : ν t ≠ ∞)} ⊆ S := by
        rintro _ ⟨t, ht, hνt, rfl⟩
        exact ⟨t, ht, c, rfl⟩
      have hc := closure_mono hsub hmem
      exact (Submodule.closure_subset_topologicalClosure_span (R := ℝ) S) hc
    · intro f g hf hg hfg hUf hUg
      exact U.topologicalClosure.add_mem hUf hUg
  apply top_unique
  intro f hf
  exact hAll f


end Nightfall.InfinitePiQ2Density
