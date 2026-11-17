import Mathlib

/-!
# Infinite-field fixed-design obstruction: source port only

This is a scoped *algebra-only* port of the existing kernel-certified F9
complement lower-bound source, replacing an unnecessary F9-specific algebra
instance by [Field K]. Source originals:
- research/nightfall/formalization/finite_field/F9OracleBridge.lean
- research/nightfall/formalization/finite_field/F9NonadaptiveLower.lean
No new mathematical argument is introduced.
-/

namespace Nightfall.InfiniteFieldPhase.FixedLower
open scoped BigOperators
noncomputable section

variable {K : Type*} [Field K]
variable {m k : ℕ}

def dot (a x : Fin k → K) : K := ∑ j, a j * x j

theorem dot_add (a u v : Fin k → K) :
    dot a (u + v) = dot a u + dot a v := by
  simp [dot, Pi.add_apply, mul_add, Finset.sum_add_distrib]

theorem dot_sub (a u v : Fin k → K) :
    dot a (u - v) = dot a u - dot a v := by
  simp [dot, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

theorem complement_kernel_collision
    (rows : Fin m → Fin k → K) (u v : Fin k → K)
    (hpartition : ∀ r, dot (rows r) u = 0 ∨ dot (rows r) v = 0) :
    ∀ r, (dot (rows r) (u + v)) ^ 2 =
      (dot (rows r) (u - v)) ^ 2 := by
  intro r
  rw [dot_add, dot_sub]
  rcases hpartition r with hu | hv
  · rw [hu]
    ring
  · rw [hv]
    ring

theorem complement_witness_not_sign_equivalent
    (u v : Fin k → K) (hu : u ≠ 0) (hv : v ≠ 0)
    (h2 : (2 : K) ≠ 0) :
    u + v ≠ u - v ∧ u + v ≠ -(u - v) := by
  constructor
  · intro heq
    apply hv
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) heq
    have hzero : (2 : K) * v j = 0 := by
      dsimp [Pi.add_apply, Pi.sub_apply] at hj
      linear_combination hj
    exact (mul_eq_zero.mp hzero).resolve_left h2
  · intro heq
    apply hu
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) heq
    have hzero : (2 : K) * u j = 0 := by
      dsimp [Pi.add_apply, Pi.sub_apply, Pi.neg_apply] at hj
      linear_combination hj
    exact (mul_eq_zero.mp hzero).resolve_left h2


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
    change rows i j * (c * x j) = c * (rows i j * x j)
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


theorem concatenated_short_row_designs_fail
    {s t k : ℕ} (hs : s < k) (ht : t < k)
    (rows : Fin (s + t) → Fin k → K)
    (h2 : (2 : K) ≠ 0) :
    ∃ x y : Fin k → K,
      x ≠ y ∧ x ≠ -y ∧
      ∀ i : Fin (s + t),
        (dot (rows i) x) ^ 2 = (dot (rows i) y) ^ 2 := by
  let rowsS : Fin s → Fin k → K := fun i => rows (Fin.castAdd t i)
  let rowsT : Fin t → Fin k → K := fun i => rows (Fin.natAdd s i)
  obtain ⟨x, y, hxy, hxneg, hS, hT⟩ :=
    all_short_row_partitions_fail_square_recovery hs ht rowsS rowsT h2
  refine ⟨x, y, hxy, hxneg, ?_⟩
  intro i
  exact Fin.addCases
    (motive := fun i : Fin (s+t) =>
      (dot (rows i) x) ^ 2 = (dot (rows i) y) ^ 2)
    (fun j => hS j) (fun j => hT j) i

theorem all_short_fixed_designs_fail
    {m k : ℕ} (hk : 2 ≤ k) (hm : m ≤ 2 * k - 2)
    (rows : Fin m → Fin k → K) (h2 : (2 : K) ≠ 0) :
    ∃ x y : Fin k → K,
      x ≠ y ∧ x ≠ -y ∧
      ∀ i : Fin m,
        (dot (rows i) x) ^ 2 = (dot (rows i) y) ^ 2 := by
  let s := min m (k - 1)
  let t := m - s
  have hs : s < k := by
    dsimp [s]
    omega
  have ht : t < k := by
    dsimp [t, s]
    omega
  have hsum : s + t = m := by
    dsimp [s, t]
    omega
  let subrows : Fin (s + t) → Fin k → K :=
    fun i => rows (Fin.cast hsum i)
  obtain ⟨x, y, hxy, hxneg, hall⟩ :=
    concatenated_short_row_designs_fail hs ht subrows h2
  refine ⟨x, y, hxy, hxneg, ?_⟩
  intro i
  have hi := hall (Fin.cast hsum.symm i)
  have hcast : Fin.cast hsum (Fin.cast hsum.symm i) = i := by
    apply Fin.ext
    rfl
  simpa only [subrows, hcast] using hi


def fixedSquareSeparates {m k : ℕ}
    (rows : Fin m → Fin k → K) : Prop :=
  ∀ x y : Fin k → K,
    (∀ i : Fin m, (dot (rows i) x) ^ 2 = (dot (rows i) y) ^ 2) →
      x = y ∨ x = -y

theorem same_oracle_nonadaptive_lower
    {m k : ℕ} (hk : 2 ≤ k)
    (rows : Fin m → Fin k → K)
    (h2 : (2 : K) ≠ 0)
    (hsep : fixedSquareSeparates rows) :
    2 * k - 1 ≤ m := by
  by_contra h
  have hsmall : m ≤ 2 * k - 2 := by omega
  obtain ⟨x, y, hxy, hneg, hcoll⟩ :=
    all_short_fixed_designs_fail hk hsmall rows h2
  rcases hsep x y hcoll with heq | hsign
  · exact hxy heq
  · exact hneg hsign


#print axioms Nightfall.InfiniteFieldPhase.FixedLower.same_oracle_nonadaptive_lower
#print axioms Nightfall.InfiniteFieldPhase.FixedLower.all_short_fixed_designs_fail
end
end Nightfall.InfiniteFieldPhase.FixedLower
