import Mathlib

/-!
# Finite per-coordinate measurable membership-vector labels

A finite family of measurable tests at finitely many genuine source
coordinates can be encoded without replacing the source law.

For each retained coordinate j in F and each k : Fin n, the Boolean
label records membership in the original measurable test set S j k.
The label type is finite even when the original source coordinate
types or the index set are infinite. This is the exact finite-alphabet
representation step needed between finite Boolean-cell density and
native finite-table Q2; density of these labels itself remains separate.
-/

namespace Nightfall.InfinitePiQ2FiniteBitLabels

universe u v

variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- A measurable finite-bit label at each coordinate of F, with an
exact original-coordinate membership interpretation. -/
noncomputable def sourceFiniteBitLabels (F : Finset ι) (n : ℕ)
    (tests : (j : F) → Fin n → Set (X j))
    (x : (i : ι) → X i) : (j : F) → Fin n → Bool :=
  fun j k => if x j ∈ tests j k then true else false

/-- No finite-alphabet hypothesis on the original source:
a finite coordinate set and finitely many tests induce finite labels. -/
theorem sourceFiniteBitLabels_finite (F : Finset ι) (n : ℕ) :
    Finite ((j : F) → Fin n → Bool) := inferInstance

/-- Every original coordinate test can be read back exactly from
one bit of its source-faithful label. -/
theorem sourceFiniteBitLabels_recovers
    (F : Finset ι) (n : ℕ)
    (tests : (j : F) → Fin n → Set (X j))
    (j : F) (k : Fin n) (x : (i : ι) → X i) :
    sourceFiniteBitLabels F n tests x j k = true ↔ x j ∈ tests j k := by
  classical
  simp [sourceFiniteBitLabels]

/-- The full finite label map is measurable under the original
heterogeneous product measurable structure. -/
theorem sourceFiniteBitLabels_measurable
    [MeasurableSpace Bool]
    (F : Finset ι) (n : ℕ)
    (tests : (j : F) → Fin n → Set (X j))
    (htests : ∀ j k, MeasurableSet (tests j k)) :
    Measurable (sourceFiniteBitLabels F n tests) := by
  classical
  apply Measurable.of_eval
  intro j
  apply Measurable.of_eval
  intro k
  change Measurable (fun x : (i : ι) → X i =>
    if x j ∈ tests j k then true else false)
  exact Measurable.ite
    ((htests j k).preimage (measurable_pi_apply (j : ι)))
    measurable_const measurable_const

/-- Every original one-coordinate test is measurable in the actual
finite-label sigma algebra, not merely in finite-coordinate information. -/
theorem sourceFiniteBitLabels_test_in_label_sigma
    [MeasurableSpace Bool] [MeasurableSingletonClass Bool]
    (F : Finset ι) (n : ℕ)
    (tests : (j : F) → Fin n → Set (X j))
    (j : F) (k : Fin n) :
    MeasurableSet[
      MeasurableSpace.comap (sourceFiniteBitLabels F n tests)
        (inferInstance : MeasurableSpace ((j : F) → Fin n → Bool))]
        {x : (i : ι) → X i | x j ∈ tests j k} := by
  have heval : Measurable
      (fun y : (j : F) → Fin n → Bool => y j k) :=
    (measurable_pi_apply k).comp (measurable_pi_apply j)
  have hset : MeasurableSet
      {y : (j : F) → Fin n → Bool | y j k = true} :=
    heval (measurableSet_singleton true)
  have heq :
      {x : (i : ι) → X i | x j ∈ tests j k} =
      (sourceFiniteBitLabels F n tests) ⁻¹'
        {y : (j : F) → Fin n → Bool | y j k = true} := by
    ext x
    change (x j ∈ tests j k) ↔
      (sourceFiniteBitLabels F n tests x j k = true)
    exact (sourceFiniteBitLabels_recovers F n tests j k x).symm
  rw [heq]
  exact ⟨_, hset, rfl⟩

#print axioms Nightfall.InfinitePiQ2FiniteBitLabels.sourceFiniteBitLabels_finite
#print axioms Nightfall.InfinitePiQ2FiniteBitLabels.sourceFiniteBitLabels_recovers
#print axioms Nightfall.InfinitePiQ2FiniteBitLabels.sourceFiniteBitLabels_measurable
#print axioms Nightfall.InfinitePiQ2FiniteBitLabels.sourceFiniteBitLabels_test_in_label_sigma

end Nightfall.InfinitePiQ2FiniteBitLabels
