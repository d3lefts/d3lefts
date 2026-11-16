import Mathlib
import F9OracleBridge

/-!
An all-dimension, source-level nonadaptive obstruction for the **same**
squared K-linear oracle. Every fixed design split into two row families of
sizes s<k and t<k has a non-sign-equivalent collision. No assumption that
the kernel witnesses are linearly independent is needed.

To derive a fully quantified F9 fixed-minimum theorem F(k)>=2k-1,
a final finite-index partition/reindex statement remains to be composed.
-/

namespace Nightfall.FiniteField.F9NonadaptiveLower
open scoped BigOperators
open Nightfall.FiniteField.F9OracleBridge
noncomputable section

variable {K : Type*} [Field K] [Algebra (ZMod 3) K]
variable {m k : ℕ}

def rowMap (rows : Fin m → Fin k → K) :
    (Fin k → K) →ₗ[K] (Fin m → K) where
  toFun x i := dot (rows i) x
  map_add' := by
    intro x y
    funext i
    exact dot_add (rows i) x y
  map_smul' := by
    intro c x
    funext i
    simp only [Pi.smul_apply, smul_eq_mul, dot, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    change rows i j * c * x j = rows i j * x j * c
    ring

theorem short_rows_have_nonzero_kernel
    (rows : Fin m → Fin k → K) (hm : m < k) :
    ∃ u : Fin k → K, u ≠ 0 ∧ ∀ i : Fin m, dot (rows i) u = 0 := by
  classical
  have hdim : Module.finrank K (Fin m → K) <
      Module.finrank K (Fin k → K) := by
    simpa only [Module.finrank_fin_fun] using hm
  have hker : (rowMap rows).ker ≠ ⊥ :=
    LinearMap.ker_ne_bot_of_finrank_lt hdim
  obtain ⟨u, hu, hnonzero⟩ :=
    (Submodule.ne_bot_iff (rowMap rows).ker).mp hker
  refine ⟨u, hnonzero, ?_⟩
  intro i
  have heq := congrArg (fun a : Fin m → K => a i)
    (LinearMap.mem_ker.mp hu)
  simpa [rowMap] using heq

theorem all_short_row_partitions_fail_square_recovery
    {s t k : ℕ} (hs : s < k) (ht : t < k)
    (rowsS : Fin s → Fin k → K) (rowsT : Fin t → Fin k → K)
    (h2 : (2 : K) ≠ 0) :
    ∃ x y : Fin k → K,
      x ≠ y ∧ x ≠ -y ∧
      (∀ i : Fin s, (dot (rowsS i) x) ^ 2 =
        (dot (rowsS i) y) ^ 2) ∧
      (∀ j : Fin t, (dot (rowsT j) x) ^ 2 =
        (dot (rowsT j) y) ^ 2) := by
  obtain ⟨u, hu, hS⟩ := short_rows_have_nonzero_kernel rowsS hs
  obtain ⟨v, hv, hT⟩ := short_rows_have_nonzero_kernel rowsT ht
  have hneq := complement_witness_not_sign_equivalent u v hu hv h2
  refine ⟨u + v, u - v, hneq.1, hneq.2, ?_, ?_⟩
  · intro i
    rw [dot_add, dot_sub, hS i]
    ring
  · intro i
    rw [dot_add, dot_sub, hT i]
    ring

#print axioms Nightfall.FiniteField.F9NonadaptiveLower.rowMap
#print axioms Nightfall.FiniteField.F9NonadaptiveLower.short_rows_have_nonzero_kernel
#print axioms Nightfall.FiniteField.F9NonadaptiveLower.all_short_row_partitions_fail_square_recovery

end
end Nightfall.FiniteField.F9NonadaptiveLower
