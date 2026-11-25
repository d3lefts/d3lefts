import TensorMinimalZeroCircuit

/-!
# Exact finite partition into minimal zero-sum circuits

An arbitrary zero-sum finite set over an additive commutative group is a
disjoint union of minimal nonempty zero-sum sets.  We formalize an indexed
finite list decomposition; the exact sum-of-cardinalities identity certifies
that no row was reused across the blocks.

This closes the **finite circuit-decomposition** component of the all-frequency
six-site bound, without asserting the published Lovitz-Petrov bound for each
tensor circuit.  The latter is a separate still-unformalized dependency.
-/

namespace Nightfall.StructuralInformation.TensorZeroCircuitDecomposition

open Nightfall.StructuralInformation.TensorMinimalZeroCircuit

variable {I G : Type*} [DecidableEq I] [AddCommGroup G]

def blocksUnion : List (Finset I) → Finset I
  | [] => ∅
  | E :: rest => E ∪ blocksUnion rest

/-- Zero-sum original-row sets admit an actual finite decomposition
into minimal circuits, with exact row-cost accounting. In particular,
the sum of circuit sizes equals the size of the original zero set,
so different blocks cannot overlap. -/
theorem exists_disjoint_minimal_circuit_partition
    (f : I → G) (S : Finset I)
    (hzero : (∑ i ∈ S, f i) = 0) :
    ∃ parts : List (Finset I),
      (∀ E ∈ parts, IsMinimalZeroCircuit f E) ∧
      (parts.map Finset.card).sum = S.card ∧
      blocksUnion parts = S := by
  classical
  induction S using Finset.strongInductionOn with
  | _ S ih =>
    by_cases hs : S = ∅
    · subst S
      refine ⟨[], ?_, ?_, ?_⟩
      · simp
      · simp
      · rfl
    · have hne : S.Nonempty := Finset.nonempty_iff_ne_empty.mpr hs
      obtain ⟨E, hES, hE, hrest, hproper⟩ :=
        remove_minimal_circuit_preserves_zero f S hne hzero
      obtain ⟨ps, hcert, hcard, hunion⟩ := ih (S \ E) hproper hrest
      have hd : Disjoint E (S \ E) := by
        apply Finset.disjoint_left.mpr
        intro x hxE hxD
        exact (Finset.mem_sdiff.mp hxD).2 hxE
      have hU : E ∪ (S \ E) = S := by
        ext x
        constructor
        · intro hx
          rcases Finset.mem_union.mp hx with hE' | hD'
          · exact hES hE'
          · exact (Finset.mem_sdiff.mp hD').1
        · intro hxS
          by_cases hxE : x ∈ E
          · exact Finset.mem_union.mpr (Or.inl hxE)
          · exact Finset.mem_union.mpr (Or.inr
              (Finset.mem_sdiff.mpr ⟨hxS, hxE⟩))
      have hsumcard : E.card + (S \ E).card = S.card := by
        have h := Finset.card_union_of_disjoint hd
        rw [hU] at h
        omega
      refine ⟨E :: ps, ?_, ?_, ?_⟩
      · intro F hF
        simp only [List.mem_cons] at hF
        rcases hF with hFE | hFp
        · subst F
          exact hE
        · exact hcert F hFp
      · simpa only [List.map_cons, List.sum_cons, hcard] using hsumcard
      · simp only [blocksUnion, hunion, hU]

#print axioms Nightfall.StructuralInformation.TensorZeroCircuitDecomposition.exists_disjoint_minimal_circuit_partition

end Nightfall.StructuralInformation.TensorZeroCircuitDecomposition
