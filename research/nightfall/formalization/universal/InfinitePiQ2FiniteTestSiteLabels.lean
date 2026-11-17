import InfinitePiQ2FiniteBooleanTestFactor
import InfinitePiQ2OriginalLabelTransport

/-!
# Source-faithful finite coordinate-label encoding of arbitrary Boolean cells

Given finitely many genuine source-coordinate measurable tests, every site
reports a finite Boolean word. A bit is nontrivial only at the original
coordinate to which its test belongs. The complete label product exactly
recovers all tests, and hence every finite Boolean cell event. This
constructs the per-coordinate labels needed by the actual original-law
heat-bath intertwining, without countability or surrogate measures.
-/

namespace Nightfall.InfinitePiQ2FiniteTestSiteLabels

open MeasureTheory
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2FiniteBooleanTestFactor
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- Each original site reports a word over the SAME finite test set.
Bits owned by other coordinates are false; an owned bit is the actual
original measurable membership test. The equality branch transports
the site value along its genuine index equality. -/
noncomputable def siteTestLabel
    (T : Finset (CoordinateTest (X := X)))
    (i : ι) (xi : X i) : T → Bool := by
  classical
  exact fun t =>
    if h : i = t.1.1 then
      if (h ▸ xi) ∈ t.1.2.1 then true else false
    else false

noncomputable def siteTestLabelFamily
    (T : Finset (CoordinateTest (X := X))) :
    (i : ι) → X i → (T → Bool) :=
  fun i => siteTestLabel T i

/-- Every original source coordinate has a finite label alphabet,
including coordinates that never occur in the test family. -/
theorem siteTestLabel_finite
    (T : Finset (CoordinateTest (X := X))) :
    Finite (T → Bool) := inferInstance

/-- Each site label is measurable under the ORIGINAL site sigma algebra. -/
theorem siteTestLabel_measurable
    (T : Finset (CoordinateTest (X := X)))
    (i : ι) : Measurable (siteTestLabel T i) := by
  classical
  apply Measurable.of_eval
  intro t
  by_cases h : i = t.1.1
  · cases h
    have hm : Measurable (fun z : X t.1.1 =>
        if z ∈ t.1.2.1 then true else false) :=
      Measurable.ite t.1.2.2 measurable_const measurable_const
    simpa [siteTestLabel] using hm
  · have hm : Measurable (fun _ : X i => (false : Bool)) :=
      measurable_const
    simpa [siteTestLabel, h] using hm

theorem siteTestLabelFamily_measurable
    (T : Finset (CoordinateTest (X := X))) :
    ∀ i, Measurable (siteTestLabelFamily T i) := by
  intro i
  exact siteTestLabel_measurable T i

/-- The label at a test's actual source site recovers its bit exactly. -/
theorem siteTestLabel_owned_bit
    (T : Finset (CoordinateTest (X := X)))
    (t : T) (x : (i : ι) → X i) :
    siteTestLabel T t.1.1 (x t.1.1) t =
      (if x t.1.1 ∈ t.1.2.1 then true else false) := by
  classical
  simp [siteTestLabel]

/-- The original globally evaluated finite tests factor EXACTLY through
a product of independently constructed coordinate-local finite labels.
No probability assumptions are required for this identity. -/
theorem evalTests_eq_sourceLabelMap
    (T : Finset (CoordinateTest (X := X)))
    (x : (i : ι) → X i) :
    evalTests T x =
      (fun t : T =>
        sourceLabelMap (siteTestLabelFamily T) x t.1.1 t) := by
  funext t
  exact (siteTestLabel_owned_bit T t x).symm

/-- Every source finite Boolean cell event is literally a pullback of a
set of finite-alphabet per-coordinate label words, not just an abstract
measurable or approximate cylinder. -/
theorem sourceFiniteCellAlgebra_factors_through_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ T : Finset (CoordinateTest (X := X)),
      ∃ U : Set ((i : ι) → (T → Bool)),
        ∀ x : (i : ι) → X i,
          (x ∈ s ↔ sourceLabelMap (siteTestLabelFamily T) x ∈ U) := by
  classical
  obtain ⟨T, V, hV⟩ :=
    sourceFiniteCellAlgebra_hasFiniteTests s hs
  refine ⟨T, {z | (fun t : T => z t.1.1 t) ∈ V}, ?_⟩
  intro x
  change x ∈ s ↔
    (fun t : T => sourceLabelMap (siteTestLabelFamily T) x t.1.1 t) ∈ V
  rw [← evalTests_eq_sourceLabelMap T x]
  exact hV x

#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.siteTestLabel_finite
#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.siteTestLabel_measurable
#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.evalTests_eq_sourceLabelMap
#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.sourceFiniteCellAlgebra_factors_through_site_labels


/-- Only finitely many original coordinates own tests from T. -/
noncomputable def siteTestSupport
    (T : Finset (CoordinateTest (X := X))) : Finset ι := by
  classical
  exact T.image (fun t => t.1)

/-- Labels outside the actual finite source support are deterministically
zero, independent of the source coordinates' cardinality or measures. -/
theorem siteTestLabel_zero_outside
    (T : Finset (CoordinateTest (X := X)))
    (i : ι) (hi : i ∉ siteTestSupport T) (xi : X i) :
    siteTestLabel T i xi = (fun _ : T => false) := by
  classical
  funext t
  have ht : t.1.1 ∈ siteTestSupport T := by
    exact Finset.mem_image.mpr ⟨t.1, t.2, rfl⟩
  have hnot : i ≠ t.1.1 := by
    intro heq
    apply hi
    simpa [heq] using ht
  simp [siteTestLabel, hnot]

/-- Stronger finite-model extraction: every event in the genuine
original-product finite-cell algebra is represented by a function of
finite-valued labels on an ACTUAL FINITE coordinate set F. This is an
exact representation, not an approximation and not a surrogate law. -/
theorem sourceFiniteCellAlgebra_factors_through_finite_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      ∃ U : Set ((j : F) → (T → Bool)),
        ∀ x : (i : ι) → X i,
          (x ∈ s ↔ (fun j : F =>
            siteTestLabel T j (x j)) ∈ U) := by
  classical
  obtain ⟨T, V, hV⟩ :=
    sourceFiniteCellAlgebra_hasFiniteTests s hs
  let F := siteTestSupport T
  have ht (t : T) : t.1.1 ∈ F := by
    exact Finset.mem_image.mpr ⟨t.1, t.2, rfl⟩
  refine ⟨F, T, {w | (fun t : T => w ⟨t.1.1, ht t⟩ t) ∈ V}, ?_⟩
  intro x
  change x ∈ s ↔
    (fun t : T => siteTestLabel T t.1.1 (x t.1.1) t) ∈ V
  have hbits :
      (fun t : T => siteTestLabel T t.1.1 (x t.1.1) t) =
        evalTests T x := by
    funext t
    simpa only [evalTests] using siteTestLabel_owned_bit T t x
  rw [hbits]
  exact hV x

#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.siteTestLabel_zero_outside
#print axioms Nightfall.InfinitePiQ2FiniteTestSiteLabels.sourceFiniteCellAlgebra_factors_through_finite_site_labels

end Nightfall.InfinitePiQ2FiniteTestSiteLabels
