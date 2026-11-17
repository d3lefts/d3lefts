import InfinitePiQ2FiniteBooleanTestFactor
import InfinitePiQ2OriginalLabelTransport
import Mathlib

/-!
# Exact finite-label realization of finite original-coordinate Boolean tests

The finite source Boolean test factor from PR #746 is not merely an
abstract finite Boolean algebra. This module builds an ACTUAL measurable,
finite-valued coordinate-local label map φ_i on each original source
space X_i. It recovers every original local Boolean test exactly after
restricting its label word to a finite active coordinate set.

This uses the finite test set T itself as the finite Boolean bit
alphabet T → Bool, avoiding a cardinality-based enumeration. All
coordinates not involved in T receive constant false bits, so there is
no countability or finite-index assumption. The induced label law is
the literal original pushforward product law.

The theorem does not equate the Hilbert adjoint to finite-label
conditional expectation or assert final infinite-product Q2.
-/

namespace Nightfall.InfinitePiQ2FiniteTestLabelRealization

open MeasureTheory
open Nightfall.InfinitePiQ2FiniteBooleanTestFactor
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable [MeasurableSpace Bool]

/-- One finite-valued source coordinate label records every test
in T targeting its own original coordinate. Tests targeting other
sites are recorded as false at this coordinate. -/
noncomputable def sourceTestLabel
    (T : Finset (CoordinateTest (X := X)))
    (i : ι) (a : X i) : T → Bool := by
  classical
  exact fun t =>
    if h : t.1.1 = i then
      if a ∈ (h ▸ t.1.2.1) then true else false
    else false

/-- The original source alphabet can be infinite, nonatomic or have
null events: the actually used test-label type remains finite. -/
theorem sourceTestLabel_finite
    (T : Finset (CoordinateTest (X := X))) :
    Finite (T → Bool) := inferInstance

/-- The Boolean bit corresponding to an original coordinate test
is recovered exactly at the coordinate where that test lives. -/
theorem sourceTestLabel_recovers
    (T : Finset (CoordinateTest (X := X)))
    (x : (i : ι) → X i) (t : T) :
    sourceTestLabel T t.1.1 (x t.1.1) t =
      evalTests T x t := by
  classical
  simp [sourceTestLabel, evalTests]

/-- Each individual finite-bit label map is measurable in the actual
source coordinate's original measurable space. -/
theorem sourceTestLabel_measurable
    (T : Finset (CoordinateTest (X := X))) (i : ι) :
    Measurable (sourceTestLabel T i) := by
  classical
  apply Measurable.of_eval
  intro t
  by_cases h : t.1.1 = i
  · have hs : MeasurableSet (h ▸ t.1.2.1) := by
      cases h
      exact t.1.2.2
    change Measurable
      (fun a : X i => if a ∈ (h ▸ t.1.2.1) then true else false)
    exact Measurable.ite hs measurable_const measurable_const
  · change Measurable (fun _ : X i => (false : Bool))
    exact measurable_const

/-- Exact finite coordinate support of the original source tests. -/
noncomputable def sourceTestSupport
    (T : Finset (CoordinateTest (X := X))) : Finset ι := by
  classical
  exact T.image (fun t => t.1)

/-- Each true original source test has its coordinate in the finite
support used by the induced finite native product label table. -/
theorem sourceTestSite_mem
    (T : Finset (CoordinateTest (X := X))) (t : T) :
    t.1.1 ∈ sourceTestSupport T := by
  classical
  unfold sourceTestSupport
  exact Finset.mem_image.mpr ⟨t.1, t.2, rfl⟩

/-- Read back a finite test vector from the finite native product
of its active source-coordinate label rows. -/
noncomputable def readSourceTests
    (T : Finset (CoordinateTest (X := X)))
    (y : (i : sourceTestSupport T) → (T → Bool)) : T → Bool :=
  fun t => y ⟨t.1.1, sourceTestSite_mem T t⟩ t

/-- Exact source-original finite-table pullback:
the restricted coordinate label word determines every original test
bit with no error, no null-word qualification, and no new law. -/
theorem readSourceTests_sourceFiniteLabels
    (T : Finset (CoordinateTest (X := X)))
    (x : (i : ι) → X i) :
    readSourceTests T
      ((sourceTestSupport T).restrict
        (sourceLabelMap (fun i => sourceTestLabel T i) x)) =
      evalTests T x := by
  classical
  funext t
  exact sourceTestLabel_recovers T x t

/-- Every finite family of genuine original-product Boolean cell
events factors through one finite-coordinate finite-alphabet label
word, with its EXACT original membership predicates. -/
theorem finiteFamily_sourceCells_factor_finiteLabel
    (S : Finset (Set ((i : ι) → X i)))
    (hS : ∀ s ∈ S, s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ T : Finset (CoordinateTest (X := X)),
      ∀ s ∈ S, ∃ U : Set (T → Bool),
        ∀ x : (i : ι) → X i,
          (x ∈ s ↔
            readSourceTests T
              ((sourceTestSupport T).restrict
                (sourceLabelMap (fun i => sourceTestLabel T i) x))
              ∈ U) := by
  obtain ⟨T, hT⟩ :=
    finiteFamily_sourceCells_commonTests S hS
  refine ⟨T, ?_⟩
  intro s hs
  obtain ⟨U, hU⟩ := hT s hs
  refine ⟨U, ?_⟩
  intro x
  rw [readSourceTests_sourceFiniteLabels]
  exact hU x

/-- The law of the actually constructed finite Boolean source test
labels is precisely the finite product of the ORIGINAL pushed-forward
source marginals. No assumed law or stochastic substitute is used. -/
theorem sourceTestFiniteLabelLaw_exact
    (μ : (i : ι) → Measure (X i))
    [∀ i, IsProbabilityMeasure (μ i)]
    (T : Finset (CoordinateTest (X := X))) :
    (Measure.infinitePi μ).map
      (fun x : (i : ι) → X i =>
        (sourceTestSupport T).restrict
          (sourceLabelMap (fun i => sourceTestLabel T i) x)) =
    Measure.pi (fun j : sourceTestSupport T =>
      (μ j).map (sourceTestLabel T j)) := by
  exact sourceFiniteLabelLaw_exact μ (sourceTestSupport T)
    (fun i => sourceTestLabel T i)
    (fun i => sourceTestLabel_measurable T i)

#print axioms Nightfall.InfinitePiQ2FiniteTestLabelRealization.sourceTestLabel_recovers
#print axioms Nightfall.InfinitePiQ2FiniteTestLabelRealization.sourceTestLabel_measurable
#print axioms Nightfall.InfinitePiQ2FiniteTestLabelRealization.readSourceTests_sourceFiniteLabels
#print axioms Nightfall.InfinitePiQ2FiniteTestLabelRealization.finiteFamily_sourceCells_factor_finiteLabel
#print axioms Nightfall.InfinitePiQ2FiniteTestLabelRealization.sourceTestFiniteLabelLaw_exact

end Nightfall.InfinitePiQ2FiniteTestLabelRealization
