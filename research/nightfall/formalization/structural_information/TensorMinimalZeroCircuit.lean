import Mathlib

/-!
# Extract a minimal zero-relation from any finite nonempty zero-relation

For any additive commutative group (not only characteristic two), every
nonempty finite zero-sum set contains an inclusion-minimal nonempty
zero-sum subset (a "binary circuit" when rows are distinct nonzero
vectors in an exponent-two linear space).

This is the exact finite combinatorial existence statement used by the
six-site all-frequency reduction. It does NOT assert Lovitz-Petrov's
tensor-specific active-factor bound, nor give a whole-set partition.
-/

namespace Nightfall.StructuralInformation.TensorMinimalZeroCircuit

variable {I G : Type*} [DecidableEq I] [AddCommGroup G]

def IsMinimalZeroCircuit (f : I → G) (E : Finset I) : Prop :=
  E.Nonempty ∧ (∑ i ∈ E, f i) = 0 ∧
    ∀ T : Finset I, T ⊂ E → T.Nonempty → (∑ i ∈ T, f i) ≠ 0

/-- A finite nonempty zero-sum set always contains an inclusion-minimal
zero-sum circuit. This uses well-founded induction on proper subsets
and *no* unproved mathematical axiom. -/
theorem exists_minimal_zero_circuit
    (f : I → G) (S : Finset I) (hne : S.Nonempty)
    (hzero : (∑ i ∈ S, f i) = 0) :
    ∃ E : Finset I, E ⊆ S ∧ IsMinimalZeroCircuit f E := by
  classical
  induction S using Finset.strongInductionOn with
  | _ S ih =>
    by_cases hminimal : ∀ T : Finset I, T ⊂ S → T.Nonempty →
        (∑ i ∈ T, f i) ≠ 0
    · exact ⟨S, Finset.Subset.refl S, hne, hzero, hminimal⟩
    · push_neg at hminimal
      obtain ⟨T, hproper, htne, htzero⟩ := hminimal
      obtain ⟨E, hET, hcert⟩ := ih T hproper htne htzero
      exact ⟨E, hET.trans hproper.subset, hcert⟩

/-- In an exponent-two group, a nonempty zero-XOR subset cannot have
cardinality one when every original row is nonzero. -/
theorem no_singleton_zero_circuit
    (f : I → G) (hnonzero : ∀ i, f i ≠ 0)
    (E : Finset I) (hE : IsMinimalZeroCircuit f E) :
    E.card ≠ 1 := by
  intro hcard
  obtain ⟨i, rfl⟩ := Finset.card_eq_one.mp hcard
  have hz : f i = 0 := by simpa [IsMinimalZeroCircuit] using hE.2.1
  exact hnonzero i hz

/-- Every nonempty zero-sum finite set admits removal of a minimal
zero-sum circuit, leaving another (possibly empty) zero-sum set.
The remainder is a *proper subset*, certifying structural descent. -/
theorem remove_minimal_circuit_preserves_zero
    (f : I → G) (S : Finset I) (hne : S.Nonempty)
    (hzero : (∑ i ∈ S, f i) = 0) :
    ∃ E : Finset I,
      E ⊆ S ∧ IsMinimalZeroCircuit f E ∧
      (∑ i ∈ S \ E, f i) = 0 ∧ S \ E ⊂ S := by
  classical
  obtain ⟨E, hES, hEcirc⟩ := exists_minimal_zero_circuit f S hne hzero
  have hsum : (∑ i ∈ S \ E, f i) + (∑ i ∈ E, f i) =
      ∑ i ∈ S, f i :=
    Finset.sum_sdiff (s₁ := E) (s₂ := S) (f := f) hES
  have hrest : (∑ i ∈ S \ E, f i) = 0 := by
    rw [hEcirc.2.1, add_zero, hzero] at hsum
    exact hsum
  have hproper : S \ E ⊂ S := by
    refine Finset.ssubset_iff_subset_ne.mpr ⟨Finset.sdiff_subset, ?_⟩
    intro heq
    obtain ⟨i, hi⟩ := hEcirc.1
    have hiS : i ∈ S := hES hi
    have hiD : i ∈ S \ E := heq.symm ▸ hiS
    exact (Finset.mem_sdiff.mp hiD).2 hi
  exact ⟨E, hES, hEcirc, hrest, hproper⟩

#print axioms Nightfall.StructuralInformation.TensorMinimalZeroCircuit.remove_minimal_circuit_preserves_zero
#print axioms Nightfall.StructuralInformation.TensorMinimalZeroCircuit.exists_minimal_zero_circuit
#print axioms Nightfall.StructuralInformation.TensorMinimalZeroCircuit.no_singleton_zero_circuit

end Nightfall.StructuralInformation.TensorMinimalZeroCircuit
