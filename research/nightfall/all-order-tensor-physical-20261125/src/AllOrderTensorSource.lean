import AllOrderTensorLocalization
import Mathlib.Algebra.BigOperators.Pi

namespace Nightfall.AllOrder.Geometry
open Finset
variable {I J K : Type*} [DecidableEq I] [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

/-- The standard coefficient-array representation of a pure tensor over F₂. -/
def coordTensor (f : I → J → NonzeroFactor K) (i : I) (v : J → K) : ZMod 2 :=
    ∏ j, (f i j).val (v j)

theorem eval_coordTensor (f : I → J → NonzeroFactor K) (i : I) (x : J → K → ZMod 2) :
    evalTensor f dot i x = ∑ v : J → K, coordTensor f i v * ∏ j, x j (v j) := by
  classical
  unfold evalTensor dot coordTensor
  simp_rw [← Finset.prod_mul_distrib]
  symm
  simpa only [Fintype.piFinset_univ] using
    (Finset.sum_prod_piFinset (ι := J) (s := (Finset.univ : Finset K))
      (g := fun j k => (f i j).val k * x j k))

theorem eval_probeTensor (f : I → J → NonzeroFactor K) (i : I) (v : J → K) :
    evalTensor f dot i (fun j => probe (v j)) = coordTensor f i v := by
  unfold evalTensor coordTensor
  simp_rw [dot_probe]

theorem coord_sum_apply (E : Finset I) (g : I → (J → K) → ZMod 2) (v : J → K) :
    (∑ i ∈ E, g i) v = ∑ i ∈ E, g i v := by
  classical
  induction E using Finset.induction_on with
  | empty => simp
  | insert a s ha ih => simp [Finset.sum_insert, ha, Pi.add_apply, ih]

theorem coord_zero_iff_eval_zero (f : I → J → NonzeroFactor K) (E : Finset I) :
    (∑ i ∈ E, coordTensor f i) = 0 ↔ (∑ i ∈ E, evalTensor f dot i) = 0 := by
  classical
  constructor
  · intro h
    funext x
    rw [sum_eval, Pi.zero_apply]
    simp_rw [eval_coordTensor]
    rw [Finset.sum_comm]
    simp_rw [← Finset.sum_mul, ← coord_sum_apply, h, Pi.zero_apply, zero_mul, Finset.sum_const_zero]
  · intro h
    funext v
    rw [coord_sum_apply, Pi.zero_apply]
    have he := congrFun h (fun j => probe (v j))
    rw [sum_eval, Pi.zero_apply] at he
    simpa only [eval_probeTensor] using he

theorem coord_minimal_varying_site_bound (f : I → J → NonzeroFactor K) (E : Finset I)
    (hm : MinimalZero (coordTensor f) E) :
    (varyingSites f E).card ≤ (E.card-1)*(Fintype.card (NonzeroFactor K))^E.card := by
  apply binary_tensor_varying_site_bound f E
  refine ⟨hm.1, (coord_zero_iff_eval_zero f E).mp hm.2.1, ?_⟩
  intro D hd hne hz
  exact hm.2.2 D hd hne ((coord_zero_iff_eval_zero f D).mpr hz)

/-- Hamming distance of local-factor strings. -/
noncomputable def ham {A : Type*} [DecidableEq A] (u v : J → A) : ℕ :=
  (univ.filter (fun j => u j ≠ v j)).card

theorem ham_refl {A : Type*} [DecidableEq A] (u : J → A) : ham u u = 0 := by simp [ham]

theorem ham_symm {A : Type*} [DecidableEq A] (u v : J → A) : ham u v = ham v u := by
  unfold ham
  congr 1
  ext j
  simp [ne_comm]

theorem ham_triangle {A : Type*} [DecidableEq A] (u v w : J → A) : ham u w ≤ ham u v + ham v w := by
  classical
  unfold ham
  have hs : univ.filter (fun j => u j ≠ w j) ⊆ (univ.filter (fun j => u j ≠ v j)) ∪ (univ.filter (fun j => v j ≠ w j)) := by
    intro j hj
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union] at *
    by_contra! hh
    exact hj (hh.1.trans hh.2)
  exact (Finset.card_le_card hs).trans (Finset.card_union_le _ _)

theorem circuit_hamming_bound (f : I → J → NonzeroFactor K) (E : Finset I)
    (hm : MinimalZero (coordTensor f) E) (i j : I) (hi : i ∈ E) (hj : j ∈ E) :
    ham (f i) (f j) ≤ (E.card-1)*(Fintype.card (NonzeroFactor K))^E.card := by
  refine (Finset.card_le_card ?_).trans (coord_minimal_varying_site_bound f E hm)
  intro k hk
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, i,hi,j,hj,(Finset.mem_filter.mp hk).2⟩

#print axioms eval_coordTensor
#print axioms coord_zero_iff_eval_zero
#print axioms coord_minimal_varying_site_bound
#print axioms circuit_hamming_bound
#print axioms ham_triangle
end Nightfall.AllOrder.Geometry
