import Mathlib

/-!
# Infinite-field adaptive squared-oracle rank obstruction

This proves the complete zero-transcript collision for every causal adaptive
protocol with strictly fewer than n measurements. It does not establish the
critical n-query obstruction; do NOT cite it as A(n) >= n+1.
-/

namespace Nightfall.InfiniteFieldPhase.AdaptiveLower
open scoped BigOperators
noncomputable section
variable {K : Type*} [Field K]
variable {n : ℕ}

def dot (a x : Fin n → K) : K := ∑ j, a j * x j

/-- A causal squared-linear measurement transcript. Query j sees ONLY the
prior list of j observations. The list is stored newest-first. -/
def history (policy : List K → Fin n → K) (x : Fin n → K) :
    ℕ → List K
  | 0 => []
  | j + 1 =>
      let prev := history policy x j
      (dot (policy prev) x) ^ 2 :: prev

theorem history_zero (policy : List K → Fin n → K) (m : ℕ) :
    history policy (0 : Fin n → K) m = List.replicate m (0 : K) := by
  induction m with
  | zero => rfl
  | succ m ih =>
      simp [history, ih, dot, List.replicate_succ]

theorem history_of_zero_path (policy : List K → Fin n → K)
    (x : Fin n → K) (m : ℕ)
    (hzero : ∀ j : ℕ, j < m →
      dot (policy (List.replicate j (0 : K))) x = 0) :
    history policy x m = List.replicate m (0 : K) := by
  induction m with
  | zero => rfl
  | succ m ih =>
      have hp : ∀ j : ℕ, j < m →
          dot (policy (List.replicate j (0 : K))) x = 0 := by
        intro j hj
        exact hzero j (by omega)
      have him := ih hp
      have hm : dot (policy (List.replicate m (0 : K))) x = 0 :=
        hzero m (by omega)
      simp [history, him, hm, List.replicate_succ]

def zeroPathRows (policy : List K → Fin n → K) (m : ℕ) :
    Fin m → Fin n → K :=
  fun i => policy (List.replicate (i : ℕ) 0)

def rowMap {m : ℕ} (rows : Fin m → Fin n → K) :
    (Fin n → K) →ₗ[K] (Fin m → K) where
  toFun x i := dot (rows i) x
  map_add' := by
    intro x y
    funext i
    simp [dot, Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' := by
    intro c x
    funext i
    simp only [Pi.smul_apply, smul_eq_mul, dot, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    change rows i j * (c * x j) = c * (rows i j * x j)
    ring

theorem short_rows_have_kernel {m : ℕ}
    (rows : Fin m → Fin n → K) (hm : m < n) :
    ∃ v : Fin n → K, v ≠ 0 ∧ ∀ i : Fin m, dot (rows i) v = 0 := by
  classical
  have hdim : Module.finrank K (Fin m → K) <
      Module.finrank K (Fin n → K) := by
    simpa only [Module.finrank_fin_fun] using hm
  have hker : (rowMap rows).ker ≠ ⊥ :=
    LinearMap.ker_ne_bot_of_finrank_lt hdim
  obtain ⟨v, hv, hnonzero⟩ :=
    (Submodule.ne_bot_iff (rowMap rows).ker).mp hker
  refine ⟨v, hnonzero, ?_⟩
  intro i
  have heq := congrArg (fun a : Fin m → K => a i)
    (LinearMap.mem_ker.mp hv)
  simpa [rowMap] using heq

/-- Any causal squared-linear strategy with m<n queries has a collision
between the zero vector and a nonzero vector, on its zero-observation path. -/
theorem short_adaptive_strategy_fails {m : ℕ} (hm : m < n)
    (policy : List K → Fin n → K) :
    ∃ x y : Fin n → K,
      x ≠ y ∧ x ≠ -y ∧
      history policy x m = history policy y m := by
  obtain ⟨v, hv, hker⟩ :=
    short_rows_have_kernel (zeroPathRows policy m) hm
  have hz : ∀ j : ℕ, j < m →
      dot (policy (List.replicate j (0 : K))) v = 0 := by
    intro j hj
    exact hker ⟨j, hj⟩
  refine ⟨v, 0, hv, ?_, ?_⟩
  · simpa using hv
  · rw [history_zero]
    exact history_of_zero_path policy v m hz

#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.history_zero
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.history_of_zero_path
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.short_adaptive_strategy_fails

end
end Nightfall.InfiniteFieldPhase.AdaptiveLower
