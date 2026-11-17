import InfinitePiQ2FiniteCellDensity
import Mathlib.MeasureTheory.Constructions.Cylinders
import Mathlib.MeasureTheory.SetAlgebra

/-!
# Exact finite-test representation of original-product finite-cell events

The original-product finite Boolean cell algebra has a stronger
representation than merely a finite-coordinate measurable cylinder:
every event is determined by FINITELY MANY coordinate-local measurable
yes/no tests. This is the correct representation input for constructing
finite-valued per-coordinate label maps under the original source law.

No countability, positive atom floor, finite source alphabet, or
finite-index condition is assumed. This theorem is not the final
infinite-product Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2FiniteBooleanTestFactor

open MeasureTheory
open Nightfall.InfinitePiQ2FiniteCellDensity

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- Original coordinate-local measurable Boolean observation, including
the coordinate itself and its true measurable event. -/
abbrev CoordinateTest : Type (max u v) :=
  Σ i : ι, {s : Set (X i) // MeasurableSet s}

/-- Evaluate a finite collection of source coordinate-local tests.
Each test uses exactly one original source coordinate. -/
noncomputable def evalTests (T : Finset (CoordinateTest (X := X)))
    (x : (i : ι) → X i) : T → Bool := by
  classical
  exact fun t => if x t.1.1 ∈ t.1.2.1 then true else false

/-- A set of source words is recognizable by a finite Boolean vector
of genuine source-coordinate measurable membership tests. -/
def HasFiniteTests (s : Set ((i : ι) → X i)) : Prop :=
  ∃ (T : Finset (CoordinateTest (X := X)))
    (U : Set (T → Bool)),
      ∀ x, x ∈ s ↔ evalTests T x ∈ U

private theorem finiteTests_empty :
    HasFiniteTests (X := X) ∅ := by
  classical
  refine ⟨∅, ∅, ?_⟩
  intro x
  simp

private theorem finiteTests_compl
    (s : Set ((i : ι) → X i))
    (hs : HasFiniteTests (X := X) s) :
    HasFiniteTests (X := X) sᶜ := by
  obtain ⟨T, U, hU⟩ := hs
  refine ⟨T, Uᶜ, ?_⟩
  intro x
  change (¬ x ∈ s) ↔ (¬ evalTests T x ∈ U)
  exact not_congr (hU x)

private theorem finiteTests_union
    (s t : Set ((i : ι) → X i))
    (hs : HasFiniteTests (X := X) s)
    (ht : HasFiniteTests (X := X) t) :
    HasFiniteTests (X := X) (s ∪ t) := by
  classical
  obtain ⟨T, U, hU⟩ := hs
  obtain ⟨R, V, hV⟩ := ht
  let W : Finset (CoordinateTest (X := X)) := T ∪ R
  have hT : T ⊆ W := Finset.subset_union_left
  have hR : R ⊆ W := Finset.subset_union_right
  let toT : (W → Bool) → (T → Bool) :=
    fun b j => b ⟨j.1, hT j.2⟩
  let toR : (W → Bool) → (R → Bool) :=
    fun b j => b ⟨j.1, hR j.2⟩
  let Uunion : Set (W → Bool) :=
    {b | toT b ∈ U ∨ toR b ∈ V}
  refine ⟨W, Uunion, ?_⟩
  intro x
  have hleft : toT (evalTests W x) = evalTests T x := by
    funext j
    rfl
  have hright : toR (evalTests W x) = evalTests R x := by
    funext j
    rfl
  change (x ∈ s ∨ x ∈ t) ↔
    (toT (evalTests W x) ∈ U ∨ toR (evalTests W x) ∈ V)
  rw [hleft, hright]
  exact or_congr (hU x) (hV x)

/-- Finite-test source events form a genuine finite Boolean algebra,
with finite test lists merged by union, not by a hypothetical
countable generating family. -/
theorem finiteTests_isSetAlgebra :
    IsSetAlgebra {s : Set ((i : ι) → X i) | HasFiniteTests (X := X) s} := by
  refine ⟨finiteTests_empty (X := X), ?_, ?_⟩
  · intro s hs
    exact finiteTests_compl s hs
  · intro s t hs ht
    exact finiteTests_union s t hs ht

/-- Each elementary measurable coordinate rectangle admits a literal
finite list of one-site Boolean tests. -/
theorem squareCylinder_hasFiniteTests
    (s : Set ((i : ι) → X i))
    (hs : s ∈ squareCylinders
      (fun i => {t : Set (X i) | MeasurableSet t})) :
    HasFiniteTests (X := X) s := by
  classical
  rcases hs with ⟨F, t, ht, rfl⟩
  let test : F → CoordinateTest (X := X) := fun j =>
    ⟨(j : ι), ⟨t (j : ι), ht (j : ι) j.property⟩⟩
  let T : Finset (CoordinateTest (X := X)) :=
    Finset.univ.image test
  have hmem (j : F) : test j ∈ T :=
    Finset.mem_image.mpr ⟨j, Finset.mem_univ _, rfl⟩
  let U : Set (T → Bool) :=
    {b | ∀ j : F, b ⟨test j, hmem j⟩ = true}
  refine ⟨T, U, ?_⟩
  intro x
  have htest (j : F) :
      evalTests T x ⟨test j, hmem j⟩ = true ↔
      x (j : ι) ∈ t (j : ι) := by
    change (if x (j : ι) ∈ t (j : ι) then true else false) = true ↔
      x (j : ι) ∈ t (j : ι)
    by_cases h : x (j : ι) ∈ t (j : ι) <;> simp [h]
  change (∀ i, i ∈ F → x i ∈ t i) ↔
    (∀ j : F, evalTests T x ⟨test j, hmem j⟩ = true)
  constructor
  · intro hx j
    exact (htest j).2 (hx j j.property)
  · intro hx i hi
    exact (htest ⟨i, hi⟩).1 (hx ⟨i, hi⟩)

/-- Main exact source finite Boolean-cell representation theorem.
Any member of the same genuine source finite-cell algebra used in
the already-certified L² density result factors through finitely
many coordinate-local measurable Boolean tests. -/
theorem sourceFiniteCellAlgebra_hasFiniteTests
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    HasFiniteTests (X := X) s := by
  exact (IsSetAlgebra.generateSetAlgebra_subset
    (fun t ht => squareCylinder_hasFiniteTests t ht)
    (finiteTests_isSetAlgebra (X := X))) hs

end Nightfall.InfinitePiQ2FiniteBooleanTestFactor
