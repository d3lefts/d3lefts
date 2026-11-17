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

/-- Enlarging a finite coordinate set enlarges the corresponding
information σ-algebra; this is the ordering needed for the directed
finite-information approximation, with arbitrary ambient index type. -/
theorem sourceFiniteCoordinateSigma_mono
    {F G : Finset ι} (hFG : F ⊆ G) :
    sourceFiniteCoordinateSigma (X := X) F ≤
      sourceFiniteCoordinateSigma (X := X) G := by
  unfold sourceFiniteCoordinateSigma
  refine MeasurableSpace.comap_le_comap_of_eq_comp
    (Finset.restrict₂ hFG) (Finset.measurable_restrict₂ hFG) ?_
  funext x i
  rfl

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


/-- A cylinder stays fixed by every larger finite-coordinate conditional
expectation, enabling directed, not merely pointwise, approximation. -/
theorem source_finite_info_fixes_cylinder_of_subset
    (F G : Finset ι) (hFG : F ⊆ G)
    (S : Set ((i : F) → X i))
    (hS : MeasurableSet S) (c : ℝ) :
    (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G)
      (sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c) :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c := by
  have hs : MeasurableSet[sourceFiniteCoordinateSigma (X := X) G] (cylinder F S) :=
    (sourceFiniteCoordinateSigma_mono (X := X) hFG)
      _ (source_finite_info_cylinder_measurable (X := X) F S hS)
  simpa only [sourceCylinderIndicator] using
    (condExpL2_indicator_of_measurable
      (sourceFiniteCoordinateSigma_le (X := X) G) hs
      (measure_ne_top (Measure.infinitePi μ) (cylinder F S)) c)

/-- Any member of the source-cylinder generating set is exactly fixed
by all sufficiently large finite-coordinate conditional expectations. -/
theorem source_cylinder_generator_eventually_fixed
    (g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hg : g ∈ sourceCylinderGenerators μ) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) g :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g := by
  obtain ⟨s, hs, c, rfl⟩ := hg
  obtain ⟨F, S, hS, rfl⟩ := (mem_measurableCylinders s).mp hs
  refine ⟨F, ?_⟩
  intro G hFG
  exact source_finite_info_fixes_cylinder_of_subset μ F G hFG S hS c


/-- Every finite real-linear combination of original-source finite-cylinder
indicators is fixed by all sufficiently large finite-information
orthogonal projections. This is the bridge from generators to their
dense linear span, for arbitrary coordinate index types. -/
theorem source_cylinder_span_eventually_fixed
    (g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hg : g ∈ Submodule.span ℝ (sourceCylinderGenerators μ)) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) g :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g := by
  classical
  induction hg using Submodule.span_induction with
  | mem g hg =>
      exact source_cylinder_generator_eventually_fixed μ g hg
  | zero =>
      refine ⟨∅, ?_⟩
      intro G hG
      simp
  | add x y hx hy hx' hy' =>
      obtain ⟨F, hF⟩ := hx'
      obtain ⟨H, hH⟩ := hy'
      refine ⟨F ∪ H, ?_⟩
      intro G hG
      have hFG : F ⊆ G := Finset.Subset.trans Finset.subset_union_left hG
      have hHG : H ⊆ G := Finset.Subset.trans Finset.subset_union_right hG
      simpa only [map_add, Submodule.coe_add, hF G hFG, hH G hHG]
  | smul c x hx hx' =>
      obtain ⟨F, hF⟩ := hx'
      refine ⟨F, ?_⟩
      intro G hG
      simpa only [map_smul, Submodule.coe_smul, hF G hG]


/-- Unconditional directed finite-information L² approximation under the
actual infinite product measure. Given any L² observable and accuracy ε,
a finite coordinate set F exists so that EVERY larger finite
conditional-expectation projection is ε-close to the observable.
No oracle, countability or finite-coordinate approximation assumption. -/
theorem source_finite_info_L2_approx
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      ‖f - (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ < ε := by
  obtain ⟨g, hg, hclose⟩ :=
    source_finite_cylinders_L2_approx μ f (ε / 3) (by linarith)
  obtain ⟨F, hfixed⟩ := source_cylinder_span_eventually_fixed μ g hg
  refine ⟨F, ?_⟩
  intro G hFG
  let P : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    fun h => (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) h :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  have hfixedg : (P g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g :=
    hfixed G hFG
  have hlinear : (P (g - f) : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (P g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) -
        (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
    simp [P, map_sub]
  have hcalc : (P (g - f) : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      g - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
    rw [hlinear, hfixedg]
  have hbridge : ‖g - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ ≤
      ‖g - f‖ := by
    rw [← hcalc]
    exact source_finite_info_L2_contract μ G (g - f)
  have htriangle : ‖f - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ ≤
      ‖f - g‖ + ‖g - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ := by
    calc
      ‖f - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ =
          ‖(f - g) + (g - (P f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)))‖ := by
            congr 1
            abel
      _ ≤ _ := norm_add_le _ _
  have hsymm : ‖g - f‖ = ‖f - g‖ := norm_sub_rev _ _
  linarith

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



/-- The original-product L² variance written using the actual product mean
and the squared Hilbert norm. Its equality to the corresponding centered
integral is the standard probability-space L² identity. -/
noncomputable def sourceL2Variance
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) : ℝ :=
  ‖f‖ ^ 2 - (∫ x, f x ∂ Measure.infinitePi μ) ^ 2

/-- The true source-projection variance is arbitrarily close to the
unprojected L² variance, uniformly for every sufficiently large finite
coordinate information set, with no approximation hypothesis. -/
theorem source_finite_info_variance_approx
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      sourceL2Variance μ f ≤
        sourceL2Variance μ
          (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) f :
            Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) + ε := by
  have hdenom : 0 < 2 * (‖f‖ + 1) := by positivity
  have hδ : 0 < ε / (2 * (‖f‖ + 1)) := div_pos hε hdenom
  obtain ⟨F, happrox⟩ :=
    source_finite_info_L2_approx μ f (ε / (2 * (‖f‖ + 1))) hδ
  refine ⟨F, ?_⟩
  intro G hFG
  let P : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) G) f :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  have hPnorm : ‖P‖ ≤ ‖f‖ := source_finite_info_L2_contract μ G f
  have hclose : ‖f - P‖ < ε / (2 * (‖f‖ + 1)) :=
    happrox G hFG
  have htriangle : ‖f‖ ≤ ‖f - P‖ + ‖P‖ := by
    calc
      ‖f‖ = ‖(f - P) + P‖ := by congr 1; abel
      _ ≤ ‖f - P‖ + ‖P‖ := norm_add_le _ _
  have hdiff : ‖f‖ - ‖P‖ ≤ ‖f - P‖ := by linarith
  have hsum : ‖f‖ + ‖P‖ ≤ 2 * (‖f‖ + 1) := by
    have hf : 0 ≤ ‖f‖ := norm_nonneg f
    linarith
  have hmul :
      (‖f‖ - ‖P‖) * (‖f‖ + ‖P‖) ≤
        ‖f - P‖ * (2 * (‖f‖ + 1)) := by
    calc
      (‖f‖ - ‖P‖) * (‖f‖ + ‖P‖) ≤
          ‖f - P‖ * (‖f‖ + ‖P‖) :=
        mul_le_mul_of_nonneg_right hdiff (by positivity)
      _ ≤ ‖f - P‖ * (2 * (‖f‖ + 1)) :=
        mul_le_mul_of_nonneg_left hsum (norm_nonneg _)
  have hsmall : ‖f - P‖ * (2 * (‖f‖ + 1)) < ε :=
    (lt_div_iff₀ hdenom).mp hclose
  have hmean :
      (∫ x, P x ∂ Measure.infinitePi μ) =
        (∫ x, f x ∂ Measure.infinitePi μ) :=
    source_finite_info_preserves_mean μ G f
  change ‖f‖ ^ 2 - (∫ x, f x ∂ Measure.infinitePi μ) ^ 2 ≤
    ‖P‖ ^ 2 - (∫ x, P x ∂ Measure.infinitePi μ) ^ 2 + ε
  rw [hmean]
  nlinarith


/-- The source-centered L² energy used above is exactly Mathlib's
genuine variance of the observable under the original infinite product
measure. This removes any ambiguity about the variance normalization. -/
theorem sourceL2Variance_eq_actual_variance
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceL2Variance μ f =
      ProbabilityTheory.variance (fun x => f x) (Measure.infinitePi μ) := by
  have hnorm :
      ‖f‖ ^ 2 =
        ∫ x, (f x) ^ 2 ∂ Measure.infinitePi μ := by
    calc
      ‖f‖ ^ 2 = inner ℝ f f :=
        (real_inner_self_eq_norm_sq f).symm
      _ = ∫ x, (f x) ^ 2 ∂ Measure.infinitePi μ := by
        rw [L2.inner_def]
        congr 1
        funext x
        simp [real_inner_self_eq_norm_sq, Real.norm_eq_abs, sq_abs]
  rw [ProbabilityTheory.variance_eq_sub (Lp.memLp f)]
  unfold sourceL2Variance
  rw [hnorm]

end Nightfall.InfinitePiQ2Density
