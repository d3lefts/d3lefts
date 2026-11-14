import InfinitePiCountableSupport
import Mathlib

/-!
# Arbitrary-index real observable countable coordinate support

For any dependent measurable product, a measurable real observable is
pointwise determined by a countable set of coordinates. This is a
structural transition from arbitrary directed finite cylinder systems
to countable coordinate filtrations.

No assumption of standard Borel factor alphabets. This is a classical
product sigma-algebra fact, not a claim of original mathematics.

This theorem does NOT prove cylinder L2 density, the real original-source
conditional-Jensen contraction, or unrestricted Efron–Stein.
-/

namespace Nightfall.InfinitePiRealCountableSupport

open MeasureTheory
open Nightfall.InfinitePiCountableSupport

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- Every measurable REAL observable depends on countably many input
coordinates, even with an uncountable original index set. -/
theorem source_measurable_real_countable_support
    (f : ((i : ι) → X i) → ℝ)
    (hf : Measurable f) :
    ∃ (J : Set ι), J.Countable ∧
      ∀ x y : (i : ι) → X i,
        J.restrict x = J.restrict y → f x = f y := by
  classical
  have hq (q : ℚ) :
      MeasurableSet {x : (i : ι) → X i | (q : ℝ) < f x} := by
    exact measurableSet_lt measurable_const hf
  choose J T hJ hT using
    (fun q : ℚ =>
      source_measurable_event_countable_support
        ({x : (i : ι) → X i | (q : ℝ) < f x}) (hq q))
  refine ⟨⋃ q : ℚ, J q, Set.countable_iUnion hJ, ?_⟩
  intro x y hxy
  apply eq_of_forall_rat_lt_iff_lt
  intro q
  have hsub : (J q).restrict x = (J q).restrict y := by
    funext j
    have hj : (j : ι) ∈ ⋃ q : ℚ, J q :=
      Set.mem_iUnion.mpr ⟨q, j.property⟩
    exact congrFun hxy ⟨j, hj⟩
  have hx :
      (q : ℝ) < f x ↔ (J q).restrict x ∈ T q := by
    have heq := congrArg (fun S : Set ((i : ι) → X i) => x ∈ S) (hT q)
    simpa only [Set.mem_setOf_eq, Set.mem_preimage] using heq.to_iff
  have hy :
      (q : ℝ) < f y ↔ (J q).restrict y ∈ T q := by
    have heq := congrArg (fun S : Set ((i : ι) → X i) => y ∈ S) (hT q)
    simpa only [Set.mem_setOf_eq, Set.mem_preimage] using heq.to_iff
  calc
    (q : ℝ) < f x ↔ (J q).restrict x ∈ T q := hx
    _ ↔ (J q).restrict y ∈ T q := by rw [hsub]
    _ ↔ (q : ℝ) < f y := hy.symm

end Nightfall.InfinitePiRealCountableSupport
