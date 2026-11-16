import Mathlib

/-!
NIGHTFALL: full finite-tensor character factorization, no hidden averaging oracle.

For every dimension d (including d=0), every complex phase ω, every
family of local quantum-operator matrix entries F, the character-weighted
expectation factors over independent ternary coordinates. A single
vanishing local character moment therefore kills the global component.

This is the combinatorial tensor-character cancellation operator, not
yet the explicit ternary GHZ coefficient calculation.
-/

namespace Nightfall.Quantum.TensorCharacter

open scoped BigOperators

theorem ternary_tensor_sum_factor
    (d : ℕ) (G : Fin d → Fin 3 → ℂ) :
    (∑ x : Fin d → Fin 3, ∏ j, G j (x j)) =
      ∏ j, (∑ s : Fin 3, G j s) := by
  classical
  simpa only [Fintype.piFinset_univ] using
    (Finset.sum_prod_piFinset (ι := Fin d)
      (s := (Finset.univ : Finset (Fin 3))) (g := G))

theorem character_weighted_tensor_sum
    (d : ℕ) (ω : ℂ) (F : Fin d → Fin 3 → ℂ) :
    (∑ x : Fin d → Fin 3,
      (∏ j, ω ^ (x j).val) * (∏ j, F j (x j))) =
    ∏ j, (∑ s : Fin 3, ω ^ s.val * F j s) := by
  classical
  calc
    (∑ x : Fin d → Fin 3,
      (∏ j, ω ^ (x j).val) * (∏ j, F j (x j))) =
      ∑ x : Fin d → Fin 3, ∏ j,
        ω ^ (x j).val * F j (x j) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.prod_mul_distrib]
    _ = ∏ j, (∑ s : Fin 3, ω ^ s.val * F j s) :=
      ternary_tensor_sum_factor d _

theorem local_moment_zero_kills_tensor
    (d : ℕ) (G : Fin d → Fin 3 → ℂ)
    (j : Fin d) (hzero : (∑ s : Fin 3, G j s) = 0) :
    (∑ x : Fin d → Fin 3, ∏ k, G k (x k)) = 0 := by
  rw [ternary_tensor_sum_factor]
  exact Finset.prod_eq_zero (Finset.mem_univ j) hzero

theorem weighted_local_zero_kills_tensor
    (d : ℕ) (ω : ℂ) (F : Fin d → Fin 3 → ℂ)
    (j : Fin d)
    (hzero : (∑ s : Fin 3, ω ^ s.val * F j s) = 0) :
    (∑ x : Fin d → Fin 3,
      (∏ k, ω ^ (x k).val) * (∏ k, F k (x k))) = 0 := by
  rw [character_weighted_tensor_sum]
  exact Finset.prod_eq_zero (Finset.mem_univ j) hzero

#print axioms Nightfall.Quantum.TensorCharacter.ternary_tensor_sum_factor
#print axioms Nightfall.Quantum.TensorCharacter.character_weighted_tensor_sum
#print axioms Nightfall.Quantum.TensorCharacter.local_moment_zero_kills_tensor
#print axioms Nightfall.Quantum.TensorCharacter.weighted_local_zero_kills_tensor

end Nightfall.Quantum.TensorCharacter
