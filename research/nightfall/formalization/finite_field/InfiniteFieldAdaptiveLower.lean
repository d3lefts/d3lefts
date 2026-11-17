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


/-! ## Pointwise phase collision for a frozen square design -/

theorem dot_add (a x y : Fin n → K) :
    dot a (x + y) = dot a x + dot a y := by
  simp [dot, Pi.add_apply, mul_add, Finset.sum_add_distrib]

theorem dot_sub (a x y : Fin n → K) :
    dot a (x - y) = dot a x - dot a y := by
  simp [dot, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

theorem dot_smul (a x : Fin n → K) (c : K) :
    dot a (c • x) = c * dot a x := by
  unfold dot
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  change a i * (c * x i) = c * (a i * x i)
  ring

theorem dot_neg (a x : Fin n → K) :
    dot a (-x) = -(dot a x) := by
  simp [dot, Pi.neg_apply, mul_neg, Finset.sum_neg_distrib]

/-- If at least two frozen squared-linear readings are nonzero, a square
matrix of rows admits a collision at the given x. One row is sign-flipped,
while one other nonzero row stays fixed. This handles singular designs too. -/
theorem frozen_collision_two_nonzero
    {k : ℕ} [NeZero (2 : K)] (hk : 1 ≤ k)
    (rows : Fin (k + 1) → Fin (k + 1) → K)
    (x : Fin (k + 1) → K)
    (hfirst : dot (rows 0) x ≠ 0)
    (hsecond : dot (rows (Fin.succ (⟨0, by omega⟩ : Fin k))) x ≠ 0) :
    ∃ y : Fin (k + 1) → K,
      y ≠ x ∧ y ≠ -x ∧
      ∀ i, (dot (rows i) y) ^ 2 = (dot (rows i) x) ^ 2 := by
  classical
  have h2 : (2 : K) ≠ 0 := NeZero.ne _
  obtain ⟨v, hv, hvrows⟩ :=
    short_rows_have_kernel (n := k + 1)
      (fun j : Fin k => rows j.succ) (by omega)
  by_cases hvfirst : dot (rows 0) v = 0
  · have hvall : ∀ i : Fin (k + 1), dot (rows i) v = 0 := by
      intro i
      induction i using Fin.cases with
      | zero => exact hvfirst
      | succ j => exact hvrows j
    have hplus : x + v ≠ x := by
      intro heq
      apply hv
      funext i
      have hh := congrArg (fun f : Fin (k + 1) → K => f i) heq
      change x i + v i = x i at hh
      change v i = (0 : K)
      linear_combination hh
    have hminus : x - v ≠ x := by
      intro heq
      apply hv
      funext i
      have hh := congrArg (fun f : Fin (k + 1) → K => f i) heq
      change x i - v i = x i at hh
      change v i = (0 : K)
      linear_combination hh
    have hpm : x + v ≠ x - v := by
      intro heq
      apply hv
      funext i
      have hh := congrArg (fun f : Fin (k + 1) → K => f i) heq
      change x i + v i = x i - v i at hh
      have hzero : (2 : K) * v i = 0 := by linear_combination hh
      exact (mul_eq_zero.mp hzero).resolve_left h2
    have hp (i : Fin (k + 1)) :
        dot (rows i) (x + v) = dot (rows i) x := by
      rw [dot_add, hvall i]
      simp
    have hm (i : Fin (k + 1)) :
        dot (rows i) (x - v) = dot (rows i) x := by
      rw [dot_sub, hvall i]
      simp
    by_cases hneg : x + v = -x
    · refine ⟨x - v, hminus, ?_, ?_⟩
      · intro he
        exact hpm (hneg.trans he.symm)
      · intro i
        rw [hm i]
    · refine ⟨x + v, hplus, hneg, ?_⟩
      intro i
      rw [hp i]
  · let c : K := (-(2 : K) * dot (rows 0) x) / dot (rows 0) v
    let y : Fin (k + 1) → K := x + c • v
    have hc : c * dot (rows 0) v = -(2 : K) * dot (rows 0) x := by
      dsimp [c]
      field_simp
    have hzero0 : dot (rows 0) y = -dot (rows 0) x := by
      calc
        dot (rows 0) y = dot (rows 0) x +
            c * dot (rows 0) v := by simp [y, dot_add, dot_smul]
        _ = -dot (rows 0) x := by rw [hc]; ring
    have htail (j : Fin k) :
        dot (rows j.succ) y = dot (rows j.succ) x := by
      simp [y, dot_add, dot_smul, hvrows j]
    have hnotx : y ≠ x := by
      intro he
      have hh := congrArg (fun z : Fin (k + 1) → K => dot (rows 0) z) he
      rw [hzero0] at hh
      have hzero : (2 : K) * dot (rows 0) x = 0 := by linear_combination -hh
      exact hfirst ((mul_eq_zero.mp hzero).resolve_left h2)
    have hnotneg : y ≠ -x := by
      intro he
      have hh := congrArg
        (fun z : Fin (k + 1) → K =>
          dot (rows (Fin.succ (⟨0, by omega⟩ : Fin k))) z) he
      rw [htail (⟨0, by omega⟩ : Fin k), dot_neg] at hh
      have hzero : (2 : K) *
          dot (rows (Fin.succ (⟨0, by omega⟩ : Fin k))) x = 0 := by
        linear_combination hh
      exact hsecond ((mul_eq_zero.mp hzero).resolve_left h2)
    refine ⟨y, hnotx, hnotneg, ?_⟩
    intro i
    induction i using Fin.cases with
    | zero => rw [hzero0]; ring
    | succ j => rw [htail j]

#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.frozen_collision_two_nonzero



/-! ## Pointwise collisions from a kernel or an inactive row -/

theorem nonzero_dot_witness {d : ℕ} (a : Fin d → K) (ha : a ≠ 0) :
    ∃ x : Fin d → K, dot a x ≠ 0 := by
  classical
  have hi : ∃ i : Fin d, a i ≠ 0 := by
    by_contra h
    apply ha
    funext i
    by_contra hz
    exact h ⟨i, hz⟩
  obtain ⟨i, hi⟩ := hi
  refine ⟨(fun j => if j = i then (1 : K) else 0), ?_⟩
  have he : dot a (fun j => if j = i then (1 : K) else 0) = a i := by
    simp [dot, mul_ite]
  rw [he]
  exact hi

theorem kernel_pointwise_collision {d : ℕ} [NeZero (2 : K)]
    (rows : Fin d → Fin d → K) (x v : Fin d → K)
    (hv : v ≠ 0) (hker : ∀ i, dot (rows i) v = 0) :
    ∃ y : Fin d → K,
      y ≠ x ∧ y ≠ -x ∧
      ∀ i, (dot (rows i) y) ^ 2 = (dot (rows i) x) ^ 2 := by
  have h2 : (2 : K) ≠ 0 := NeZero.ne _
  have hplus : x + v ≠ x := by
    intro heq
    apply hv
    funext i
    have hh := congrArg (fun f : Fin d → K => f i) heq
    change x i + v i = x i at hh
    linear_combination hh
  have hminus : x - v ≠ x := by
    intro heq
    apply hv
    funext i
    have hh := congrArg (fun f : Fin d → K => f i) heq
    change x i - v i = x i at hh
    linear_combination hh
  have hpm : x + v ≠ x - v := by
    intro heq
    apply hv
    funext i
    have hh := congrArg (fun f : Fin d → K => f i) heq
    change x i + v i = x i - v i at hh
    have hzero : (2 : K) * v i = 0 := by linear_combination hh
    exact (mul_eq_zero.mp hzero).resolve_left h2
  have hp (i : Fin d) : dot (rows i) (x + v) = dot (rows i) x := by
    rw [dot_add, hker i]
    simp
  have hm (i : Fin d) : dot (rows i) (x - v) = dot (rows i) x := by
    rw [dot_sub, hker i]
    simp
  by_cases hneg : x + v = -x
  · refine ⟨x - v, hminus, ?_, ?_⟩
    · intro he
      exact hpm (hneg.trans he.symm)
    · intro i
      rw [hm i]
  · refine ⟨x + v, hplus, hneg, ?_⟩
    intro i
    rw [hp i]

theorem frozen_collision_with_zero_row {k : ℕ} [NeZero (2 : K)]
    (rows : Fin (k+1) → Fin (k+1) → K)
    (x : Fin (k+1) → K) (j : Fin (k+1)) (hj : rows j = 0) :
    ∃ y : Fin (k+1) → K,
      y ≠ x ∧ y ≠ -x ∧
      ∀ i, (dot (rows i) y)^2 = (dot (rows i) x)^2 := by
  obtain ⟨v, hv, hrest⟩ :=
    short_rows_have_kernel (n := k+1)
      (fun i : Fin k => rows (j.succAbove i)) (by omega)
  have hall (i : Fin (k+1)) : dot (rows i) v = 0 := by
    rcases Fin.eq_self_or_eq_succAbove j i with he | ⟨q,he⟩
    · subst i
      simp [hj, dot]
    · subst i
      exact hrest q
  exact kernel_pointwise_collision rows x v hv hall

/-- Frozen responses determine the true causal responses, by induction
on the transcript prefix, without any future-observation dependency. -/
theorem history_eq_of_frozen_squares
    (policy : List K → Fin n → K) (x y : Fin n → K) (m : ℕ)
    (h : ∀ i : Fin m,
      (dot (policy (history policy x i.val)) x)^2 =
      (dot (policy (history policy x i.val)) y)^2) :
    history policy x m = history policy y m := by
  induction m with
  | zero => rfl
  | succ m ih =>
      have hp : ∀ i : Fin m,
          (dot (policy (history policy x i.val)) x)^2 =
          (dot (policy (history policy x i.val)) y)^2 := by
        intro i
        exact h ⟨i.val, by omega⟩
      have hprev := ih hp
      have hlast :
          (dot (policy (history policy x m)) x)^2 =
          (dot (policy (history policy x m)) y)^2 :=
        h ⟨m, by omega⟩
      change
          (dot (policy (history policy x m)) x)^2 :: history policy x m =
          (dot (policy (history policy y m)) y)^2 :: history policy y m
      rw [← hprev, hlast]

#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.kernel_pointwise_collision
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.frozen_collision_with_zero_row
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.history_eq_of_frozen_squares



/-! ## The critical n-query adaptive obstruction -/

/-- An n-query causal squared-linear strategy on n>=2 coordinates must
collide on two non-sign-equivalent vectors. This closes the sharp
adaptive lower bound under the same legal squared-linear oracle. -/
theorem critical_adaptive_strategy_fails
    {k : ℕ} [NeZero (2 : K)] (hk : 1 ≤ k)
    (policy : List K → Fin (k+1) → K) :
    ∃ x y : Fin (k+1) → K,
      x ≠ y ∧ x ≠ -y ∧
      history policy x (k+1) = history policy y (k+1) := by
  classical
  let a : Fin (k+1) → K := policy []
  by_cases ha : a = 0
  · obtain ⟨v, hv, hvrest⟩ :=
      short_rows_have_kernel (n := k+1)
        (fun j : Fin k =>
          policy (List.replicate (j.val + 1) (0 : K))) (by omega)
    have hz : ∀ j : ℕ, j < k+1 →
        dot (policy (List.replicate j (0 : K))) v = 0 := by
      intro j hj
      let fi : Fin (k+1) := ⟨j, hj⟩
      have hfi : dot (policy (List.replicate fi.val (0 : K))) v = 0 := by
        induction fi using Fin.cases with
        | zero =>
            change dot a v = 0
            simp [ha, dot]
        | succ q =>
            exact hvrest q
      exact hfi
    refine ⟨v, 0, hv, ?_, ?_⟩
    · simpa using hv
    · rw [history_zero]
      exact history_of_zero_path policy v (k+1) hz
  · obtain ⟨x0, hx0⟩ := nonzero_dot_witness a ha
    let b : Fin (k+1) → K := policy [(dot a x0)^2]
    by_cases hb : b = 0
    · let rows : Fin (k+1) → Fin (k+1) → K :=
        fun i => policy (history policy x0 i.val)
      have hrow1 : rows (Fin.succ (⟨0, by omega⟩ : Fin k)) = 0 := by
        change policy [(dot a x0)^2] = 0
        exact hb
      obtain ⟨y, hneq, hsign, hsame⟩ :=
        frozen_collision_with_zero_row rows x0
          (Fin.succ (⟨0, by omega⟩ : Fin k)) hrow1
      have htrans : history policy x0 (k+1) = history policy y (k+1) := by
        apply history_eq_of_frozen_squares
        intro i
        exact (hsame i).symm
      exact ⟨y, x0, hneq, hsign, htrans.symm⟩
    · obtain ⟨z, hz⟩ := nonzero_dot_witness b hb
      have hsource : ∃ x : Fin (k+1) → K,
          dot a x = dot a x0 ∧ dot b x ≠ 0 := by
        by_cases hb0 : dot b x0 = 0
        · let c : K := dot a z / dot a x0
          let x : Fin (k+1) → K := x0 + z - c • x0
          have hc : c * dot a x0 = dot a z := by
            dsimp [c]
            field_simp
          have hax : dot a x = dot a x0 := by
            dsimp [x]
            rw [dot_sub, dot_add, dot_smul, hc]
            ring
          have hbx : dot b x = dot b z := by
            dsimp [x]
            rw [dot_sub, dot_add, dot_smul, hb0]
            ring
          exact ⟨x, hax, hbx.symm ▸ hz⟩
        · exact ⟨x0, rfl, hb0⟩
      obtain ⟨x, hax, hbx⟩ := hsource
      have hfirst : dot (policy []) x ≠ 0 := by
        change dot a x ≠ 0
        rw [hax]
        exact hx0
      have hsecond : dot (policy (history policy x 1)) x ≠ 0 := by
        have hp : policy (history policy x 1) = b := by
          change policy [(dot a x)^2] = policy [(dot a x0)^2]
          rw [hax]
        rw [hp]
        exact hbx
      let rows : Fin (k+1) → Fin (k+1) → K :=
        fun i => policy (history policy x i.val)
      have hf : dot (rows 0) x ≠ 0 := hfirst
      have hs : dot (rows (Fin.succ (⟨0, by omega⟩ : Fin k))) x ≠ 0 := hsecond
      obtain ⟨y, hneq, hsign, hsame⟩ :=
        frozen_collision_two_nonzero hk rows x hf hs
      have htrans : history policy x (k+1) = history policy y (k+1) := by
        apply history_eq_of_frozen_squares
        intro i
        exact (hsame i).symm
      exact ⟨y, x, hneq, hsign, htrans.symm⟩

#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.critical_adaptive_strategy_fails


#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.history_zero
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.history_of_zero_path
#print axioms Nightfall.InfiniteFieldPhase.AdaptiveLower.short_adaptive_strategy_fails

end
end Nightfall.InfiniteFieldPhase.AdaptiveLower
