import Mathlib
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
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  indicatorConstLp 2
    ((source_finite_cylinders_measure_dense μ).measurable s hs)
    (measure_ne_top (Measure.infinitePi μ) s) c

/-- No auxiliary probability or density oracle in this generator set. -/
noncomputable def sourceCylinderGenerators :
    Set (Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :=
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
  letI : Fact ((2 : ENNReal) ≠ ⊤) := ⟨by norm_num⟩
  let ν := Measure.infinitePi μ
  let S := sourceCylinderGenerators μ
  let U : Submodule ℝ (Lp ℝ (2 : ENNReal) ν) :=
    Submodule.span ℝ S
  let hA := source_finite_cylinders_measure_dense μ
  have hAll : ∀ f : Lp ℝ (2 : ENNReal) ν,
      f ∈ U.topologicalClosure := by
    refine Lp.induction (μ := ν) (p := (2 : ENNReal))
      (by norm_num)
      (motive := fun f => f ∈ U.topologicalClosure) ?_ ?_
      U.isClosed_topologicalClosure
    · intro c s hs hνs
      rw [Lp.simpleFunc.coe_indicatorConst]
      have hmem :
          indicatorConstLp (2 : ENNReal) hs hνs.ne c ∈
          closure {indicatorConstLp (2 : ENNReal)
            (hA.measurable t ht) hνt c |
            (t : Set ((i : ι) → X i))
            (ht : t ∈ measurableCylinders X) (hνt : ν t ≠ ⊤)} :=
        (hA.indicatorConstLp_subset_closure (p := (2 : ENNReal)) c)
          ⟨s, hs, hνs.ne, rfl⟩
      have hsub :
          {indicatorConstLp (2 : ENNReal)
            (hA.measurable t ht) hνt c |
            (t : Set ((i : ι) → X i))
            (ht : t ∈ measurableCylinders X) (hνt : ν t ≠ ⊤)} ⊆ S := by
        rintro _ ⟨t, ht, hνt, rfl⟩
        exact ⟨t, ht, c, rfl⟩
      have hc := closure_mono hsub hmem
      exact (Submodule.closure_subset_topologicalClosure_span (R := ℝ) S) hc
    · intro f g hf hg hfg hUf hUg
      exact U.topologicalClosure.add_mem hUf hUg
  apply top_unique
  intro f hf
  exact hAll f


/-- Every original-product L² random variable has an arbitrarily close
finite real-linear combination of genuine finite-cylinder indicators.
This is the epsilon approximation interface needed for the subsequent
finite-information projection limit; it has no oracle hypotheses. -/
theorem source_finite_cylinders_L2_approx
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ),
      g ∈ Submodule.span ℝ (sourceCylinderGenerators μ) ∧
      ‖f - g‖ < ε := by
  have hmem :
      f ∈ (Submodule.span ℝ (sourceCylinderGenerators μ)).topologicalClosure := by
    rw [source_finite_cylinders_L2_dense μ]
    trivial
  rw [← SetLike.mem_coe, Submodule.topologicalClosure_coe,
    Metric.mem_closure_iff] at hmem
  obtain ⟨g, hg, hnear⟩ := hmem ε hε
  exact ⟨g, hg, by simpa only [dist_eq_norm] using hnear⟩


/-- The information generated by an arbitrary finite coordinate set is
a sub-σ-algebra of the original product σ-algebra. -/
def sourceFiniteCoordinateSigma (F : Finset ι) :
    MeasurableSpace ((i : ι) → X i) :=
  MeasurableSpace.comap
    (fun x : (i : ι) → X i => F.restrict x)
    (inferInstance : MeasurableSpace ((i : F) → X i))

theorem sourceFiniteCoordinateSigma_le (F : Finset ι) :
    sourceFiniteCoordinateSigma (X := X) F ≤
      (inferInstance : MeasurableSpace ((i : ι) → X i)) := by
  exact (Finset.measurable_restrict F).comap_le

/-- The true finite-information conditional expectation is L²
contractive for arbitrary product laws, including uncountable indices. -/
theorem source_finite_info_L2_contract
    (F : Finset ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    ‖(condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ ≤ ‖f‖ := by
  exact norm_condExpL2_coe_le
    (sourceFiniteCoordinateSigma_le (X := X) F) f


/-- Each actual finite-cylinder event is measurable for its finite
coordinate-information sigma-algebra. -/
theorem source_finite_info_cylinder_measurable
    (F : Finset ι) (S : Set ((i : F) → X i))
    (hS : MeasurableSet S) :
    MeasurableSet[sourceFiniteCoordinateSigma (X := X) F] (cylinder F S) := by
  exact ⟨S, hS, rfl⟩

/-- Finite-coordinate conditional expectation fixes the indicator of
every measurable cylinder supported on those coordinates. -/
theorem source_finite_info_fixes_cylinder
    (F : Finset ι) (S : Set ((i : F) → X i))
    (hS : MeasurableSet S) (c : ℝ) :
    (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F)
      (sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c) :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c := by
  have hs := source_finite_info_cylinder_measurable (X := X) F S hS
  simpa only [sourceCylinderIndicator] using
    (condExpL2_indicator_of_measurable
      (sourceFiniteCoordinateSigma_le (X := X) F) hs
      (measure_ne_top (Measure.infinitePi μ) (cylinder F S)) c)

/-- An original-product finite-information conditional expectation has
exactly the original source mean, not merely an assumed expectation. -/
theorem source_finite_info_preserves_mean
    (F : Finset ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    (∫ x, (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) x ∂ Measure.infinitePi μ) =
    (∫ x, f x ∂ Measure.infinitePi μ) := by
  have h := integral_condExpL2_eq (𝕜 := ℝ)
    (sourceFiniteCoordinateSigma_le (X := X) F) f
    (MeasurableSet.univ :
      MeasurableSet[sourceFiniteCoordinateSigma (X := X) F] Set.univ)
    (measure_ne_top (Measure.infinitePi μ) Set.univ)
  simpa only [MeasureTheory.setIntegral_univ] using h


end Nightfall.InfinitePiQ2Density
