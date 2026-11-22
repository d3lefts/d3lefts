import Mathlib

/-!
# Symmetric-difference XOR bookkeeping for primitive tensor exchanges

In an exponent-two additive group, if two FINITE sets of row labels
have equal XOR, the union of their nonshared rows has XOR zero.
This is the exact algebraic starting point of the disjoint-circuit
decomposition in the six-site tensor bound.

The theorem does NOT construct a circuit decomposition or prove the
published Lovitz-Petrov tensor circuit support bound.
-/

namespace Nightfall.StructuralInformation.TensorSymmetricDifferenceXor

variable {I : Type*} {G : Type*} [AddCommGroup G]

/-- Equal total row sums imply equal sums of the two nonshared
parts. This holds even without exponent-two; it is useful for
source-level generalization to other finite fields. -/
theorem equal_sums_imply_equal_differences
    (C D : Finset I) (f : I → G)
    (heq : (∑ x ∈ C, f x) = ∑ x ∈ D, f x) :
    (∑ x ∈ C \ D, f x) = ∑ x ∈ D \ C, f x := by
  classical
  have hCdiff : C \ (C ∩ D) = C \ D := by
    ext x
    simp only [Finset.mem_sdiff, Finset.mem_inter]
    tauto
  have hDdiff : D \ (C ∩ D) = D \ C := by
    ext x
    simp only [Finset.mem_sdiff, Finset.mem_inter]
    tauto
  have hC : (∑ x ∈ C \ D, f x) + (∑ x ∈ C ∩ D, f x)
      = ∑ x ∈ C, f x := by
    simpa [hCdiff] using
      (Finset.sum_sdiff (s₁ := C ∩ D) (s₂ := C) (f := f)
        (Finset.inter_subset_left))
  have hD : (∑ x ∈ D \ C, f x) + (∑ x ∈ C ∩ D, f x)
      = ∑ x ∈ D, f x := by
    simpa [hDdiff] using
      (Finset.sum_sdiff (s₁ := C ∩ D) (s₂ := D) (f := f)
        (Finset.inter_subset_right))
  apply add_right_cancel
  calc
    (∑ x ∈ C \ D, f x) + (∑ x ∈ C ∩ D, f x)
        = ∑ x ∈ C, f x := hC
    _ = ∑ x ∈ D, f x := heq
    _ = (∑ x ∈ D \ C, f x) + (∑ x ∈ C ∩ D, f x) := hD.symm

/-- Exact zero-relation identity for XOR labels.
The explicit hypothesis h₂ is discharged when G is the binary tensor
vector space; it is not introduced as an axiom. -/
theorem equal_sums_imply_zero_symmetric_difference
    (h₂ : ∀ v : G, v + v = 0)
    (C D : Finset I) (f : I → G)
    (heq : (∑ x ∈ C, f x) = ∑ x ∈ D, f x) :
    (∑ x ∈ (C \ D) ∪ (D \ C), f x) = 0 := by
  classical
  have hd : Disjoint (C \ D) (D \ C) := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    exact (Finset.mem_sdiff.mp hy).2 (Finset.mem_sdiff.mp hx).1
  have h := equal_sums_imply_equal_differences C D f heq
  rw [Finset.sum_union hd, h]
  exact h₂ _

#print axioms Nightfall.StructuralInformation.TensorSymmetricDifferenceXor.equal_sums_imply_equal_differences
#print axioms Nightfall.StructuralInformation.TensorSymmetricDifferenceXor.equal_sums_imply_zero_symmetric_difference

end Nightfall.StructuralInformation.TensorSymmetricDifferenceXor
