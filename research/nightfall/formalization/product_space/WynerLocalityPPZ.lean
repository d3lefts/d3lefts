import WynerLocalityCore

/-! The isolated-assignment bound by disjoint guess cylinders and permutation
averaging. This is the PPZ satisfiability coding argument in a source model
of local exclusion; no SAT solver, probabilistic oracle, or counting premise. -/

namespace Nightfall.WynerLocality

open Finset Real

variable {ι : Type} [Fintype ι] [DecidableEq ι]

def Forced (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (x : ι → Bool) (i : ι) : Prop :=
  ∀ y ∈ A, (∀ j, rank j < rank i → y j = x j) → y i = x i

noncomputable def forcedSet (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (x : ι → Bool) : Finset ι := by
  classical
  exact univ.filter (Forced A rank x)

theorem mem_forcedSet (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (x : ι → Bool) (i : ι) :
    i ∈ forcedSet A rank x ↔ Forced A rank x i := by
  classical
  simp [forcedSet]

noncomputable def guessSet (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (x : ι → Bool) : Finset (ι → Bool) := by
  classical
  exact univ.filter fun u => ∀ i, i ∉ forcedSet A rank x → u i = x i

theorem mem_guessSet (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (x u : ι → Bool) :
    u ∈ guessSet A rank x ↔ ∀ i, i ∉ forcedSet A rank x → u i = x i := by
  classical
  simp [guessSet]

/-- Fill the unconstrained (forced by the source) positions arbitrarily. -/
theorem guessSet_card (A : Finset (ι → Bool)) (rank : ι → ℕ) (x : ι → Bool) :
    (guessSet A rank x).card = 2 ^ (forcedSet A rank x).card := by
  classical
  let F := forcedSet A rank x
  let B := guessSet A rank x
  let e : (↥F → Bool) ≃ ↥B :=
    { toFun := fun v => ⟨fun i => if hi : i ∈ F then v ⟨i, hi⟩ else x i,
        (mem_guessSet A rank x _).mpr (by
          intro i hi
          have h : i ∉ F := hi
          simp [h])⟩
      invFun := fun u i => u.val i.val
      left_inv := by
        intro v
        funext i
        simp [i.property]
      right_inv := by
        intro u
        apply Subtype.ext
        funext i
        by_cases hi : i ∈ F
        · simp [hi]
        · have h := (mem_guessSet A rank x u.val).mp u.property i hi
          simp [hi, h] }
  have h := (Fintype.card_congr e).symm
  simpa [Fintype.card_fun, F, B] using h

/-- Distinct codewords have disjoint guess cylinders, using their earliest
disagreement in an injective coordinate ordering. -/
theorem guessSet_disjoint (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (hrank : Function.Injective rank)
    (x y : ι → Bool) (hx : x ∈ A) (hy : y ∈ A) (hxy : x ≠ y) :
    Disjoint (guessSet A rank x) (guessSet A rank y) := by
  classical
  let J := univ.filter fun i : ι => x i ≠ y i
  have hJ : J.Nonempty := by
    by_contra hn
    apply hxy
    funext i
    by_contra hi
    exact hn ⟨i, by simp [J, hi]⟩
  obtain ⟨i, hi, hmin⟩ := Finset.exists_min_image J rank hJ
  have hdiff : x i ≠ y i := by simpa [J] using hi
  have hagree : ∀ j, rank j < rank i → x j = y j := by
    intro j hj
    by_contra hn
    have hjJ : j ∈ J := by simp [J, hn]
    exact (not_le_of_gt hj) (hmin j hjJ)
  have hfx : i ∉ forcedSet A rank x := by
    intro hh
    exact hdiff (((mem_forcedSet A rank x i).mp hh y hy
      (fun j hj => (hagree j hj).symm)).symm)
  have hfy : i ∉ forcedSet A rank y := by
    intro hh
    exact hdiff ((mem_forcedSet A rank y i).mp hh x hx hagree)
  apply Finset.disjoint_left.mpr
  intro u hux huy
  exact hdiff (((mem_guessSet A rank x u).mp hux i hfx).symm.trans
    ((mem_guessSet A rank y u).mp huy i hfy))

/-- Kraft-type packing bound, proved as finite cardinality of disjoint
cylinders, not assumed as an external inequality. -/
theorem guess_packing (A : Finset (ι → Bool)) (rank : ι → ℕ)
    (hrank : Function.Injective rank) :
    (∑ x ∈ A, 2 ^ (forcedSet A rank x).card) ≤ 2 ^ Fintype.card ι := by
  classical
  have hdisj : (↑A : Set (ι → Bool)).PairwiseDisjoint (guessSet A rank) := by
    intro x hx y hy hne
    exact guessSet_disjoint A rank hrank x y hx hy hne
  have h := Finset.card_le_univ (A.biUnion (guessSet A rank))
  rw [Finset.card_biUnion hdisj] at h
  simpa [guessSet_card, Fintype.card_fun] using h

/-- A critical coordinate of an isolated assignment has a local exclusion
certificate for its one-bit flip, containing that coordinate. -/
theorem critical_set (A : Finset (ι → Bool)) (r : ℕ)
    (hloc : LocalExclusion (↑A : Set (ι → Bool)) r)
    (hiso : Isolated (↑A : Set (ι → Bool))) (x : ι → Bool) (hx : x ∈ A) (i : ι) :
    ∃ J : Finset ι, i ∈ J ∧ J.card ≤ r ∧
      ∀ rank : ι → ℕ, Function.Injective rank →
        (∀ j ∈ J, rank j ≤ rank i) → Forced A rank x i := by
  classical
  obtain ⟨J, hJ, he⟩ := hloc (flip x i) (hiso x hx i)
  have hi : i ∈ J := by
    by_contra hn
    apply he x _ hx
    intro j hj
    have hji : j ≠ i := fun h => hn (h ▸ hj)
    simp [flip, Function.update_of_ne hji]
  refine ⟨J, hi, hJ, ?_⟩
  intro rank hrank hlast y hy hprev
  by_contra hdiff
  apply he y _ hy
  intro j hj
  by_cases hji : j = i
  · subst j
    cases ha : x i <;> cases hb : y i <;> simp_all [flip]
  · have hlt : rank j < rank i := lt_of_le_of_ne (hlast j hj)
        (fun heq => hji (hrank heq))
    simpa [flip, Function.update_of_ne hji] using hprev j hlt

noncomputable def orderRank (σ : Equiv.Perm ι) (i : ι) : ℕ :=
  (Fintype.equivFin ι (σ i)).val

theorem orderRank_injective (σ : Equiv.Perm ι) :
    Function.Injective (orderRank σ) := by
  intro i j h
  exact σ.injective ((Fintype.equivFin ι).injective (Fin.ext h))

noncomputable def lastOrders (J : Finset ι) (i : ι) : Finset (Equiv.Perm ι) := by
  classical
  exact univ.filter fun σ => ∀ j ∈ J, orderRank σ j ≤ orderRank σ i

/-- Uniform permutation symmetry, via injection into last-orders × J.
For every input permutation, swap i with the last element of J. -/
theorem last_order_count (J : Finset ι) (i : ι) (hi : i ∈ J) :
    Fintype.card (Equiv.Perm ι) ≤ (lastOrders J i).card * J.card := by
  classical
  have hne : J.Nonempty := ⟨i, hi⟩
  have hmax : ∀ σ : Equiv.Perm ι, ∃ j ∈ J,
      ∀ a ∈ J, orderRank σ a ≤ orderRank σ j := by
    intro σ
    exact Finset.exists_max_image J (orderRank σ) hne
  choose j hj hlast using hmax
  let B := lastOrders J i
  let f : Equiv.Perm ι → ↥B × ↥J := fun σ =>
    (⟨(Equiv.swap i (j σ)).trans σ, by
      change (Equiv.swap i (j σ)).trans σ ∈ lastOrders J i
      simp only [lastOrders, Finset.mem_filter, Finset.mem_univ, true_and]
      intro a ha
      have hswap : Equiv.swap i (j σ) a ∈ J := by
        by_cases hai : a = i
        · subst a
          simpa using hj σ
        · by_cases haj : a = j σ
          · subst a
            simpa using hi
          · simpa [Equiv.swap_apply_of_ne_of_ne hai haj] using ha
      have hh := hlast σ _ hswap
      simpa [orderRank, Equiv.trans_apply] using hh⟩,
      ⟨j σ, hj σ⟩)
  have hf : Function.Injective f := by
    intro σ τ h
    have hJ : j σ = j τ := congrArg (fun p : ↥B × ↥J => p.2.val) h
    have hP : (Equiv.swap i (j σ)).trans σ = (Equiv.swap i (j τ)).trans τ :=
      congrArg (fun p : ↥B × ↥J => p.1.val) h
    rw [← hJ] at hP
    ext a
    obtain ⟨z, hz⟩ := (Equiv.swap i (j σ)).surjective a
    have he := congrArg (fun p : Equiv.Perm ι => p z) hP
    simpa only [Equiv.trans_apply, hz] using he
  simpa [B, Fintype.card_prod] using Fintype.card_le_of_injective f hf

noncomputable def forcedOrders (A : Finset (ι → Bool)) (x : ι → Bool)
    (i : ι) : Finset (Equiv.Perm ι) := by
  classical
  exact univ.filter fun σ => Forced A (orderRank σ) x i

theorem forced_order_count (A : Finset (ι → Bool)) (r : ℕ)
    (hloc : LocalExclusion (↑A : Set (ι → Bool)) r)
    (hiso : Isolated (↑A : Set (ι → Bool)))
    (x : ι → Bool) (hx : x ∈ A) (i : ι) :
    Fintype.card (Equiv.Perm ι) ≤ r * (forcedOrders A x i).card := by
  classical
  obtain ⟨J, hi, hJ, hf⟩ := critical_set A r hloc hiso x hx i
  have hsub : lastOrders J i ⊆ forcedOrders A x i := by
    intro σ hσ
    simp only [lastOrders, Finset.mem_filter, Finset.mem_univ, true_and] at hσ
    simp only [forcedOrders, Finset.mem_filter, Finset.mem_univ, true_and]
    exact hf (orderRank σ) (orderRank_injective σ) hσ
  calc
    _ ≤ (lastOrders J i).card * J.card := last_order_count J i hi
    _ ≤ (forcedOrders A x i).card * r :=
      Nat.mul_le_mul (Finset.card_le_card hsub) hJ
    _ = _ := Nat.mul_comm _ _

theorem forced_count_total (A : Finset (ι → Bool)) (r : ℕ)
    (hloc : LocalExclusion (↑A : Set (ι → Bool)) r)
    (hiso : Isolated (↑A : Set (ι → Bool)))
    (x : ι → Bool) (hx : x ∈ A) :
    Fintype.card ι * Fintype.card (Equiv.Perm ι) ≤
      r * ∑ σ : Equiv.Perm ι, (forcedSet A (orderRank σ) x).card := by
  classical
  have hs : (∑ i : ι, (forcedOrders A x i).card) =
      ∑ σ : Equiv.Perm ι, (forcedSet A (orderRank σ) x).card := by
    simp only [forcedOrders, forcedSet, Finset.card_filter]
    exact Finset.sum_comm
  calc
    _ = ∑ _i : ι, Fintype.card (Equiv.Perm ι) := by simp
    _ ≤ ∑ i : ι, r * (forcedOrders A x i).card :=
      Finset.sum_le_sum fun i _ => forced_order_count A r hloc hiso x hx i
    _ = _ := by rw [← Finset.mul_sum, hs]

/-- Averaged Kraft bound in nats. The full source is the local-exclusion
form of the satisfiability coding lemma of Paturi, Pudlak and Zane. -/
theorem ppz_log_card (A : Finset (ι → Bool)) (r : ℕ) (hr : 0 < r)
    (hA : A.Nonempty)
    (hloc : LocalExclusion (↑A : Set (ι → Bool)) r)
    (hiso : Isolated (↑A : Set (ι → Bool))) :
    Real.log (A.card : ℝ) ≤
      ((Fintype.card ι : ℝ) - (Fintype.card ι : ℝ) / r) * Real.log 2 := by
  classical
  let P : ℝ := Fintype.card (Equiv.Perm ι)
  let N : ℝ := Fintype.card ι
  have hP : 0 < P := by
    exact Nat.cast_pos.mpr Fintype.card_pos
  have hrR : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  let f := fun (σ : Equiv.Perm ι) (x : ι → Bool) =>
    ((forcedSet A (orderRank σ) x).card : ℝ)
  have hmean : ∀ x ∈ A, N / r ≤ (∑ σ : Equiv.Perm ι, f σ x) / P := by
    intro x hx
    have hc : N * P ≤ (r : ℝ) * ∑ σ : Equiv.Perm ι, f σ x := by
      dsimp [N, P, f]
      exact_mod_cast forced_count_total A r hloc hiso x hx
    apply (div_le_div_iff₀ hrR hP).mpr
    nlinarith
  have hexp : ∀ x ∈ A,
      Real.exp ((N/r) * Real.log 2) ≤
        (∑ σ : Equiv.Perm ι, Real.exp (f σ x * Real.log 2)) / P := by
    intro x hx
    have hw : (∑ _σ : Equiv.Perm ι, (1 : ℝ)/P) = 1 := by
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
      change P * (1/P) = 1
      field_simp
    have hJ := ConvexOn.map_sum_le Real.convexOn_exp
      (t := (univ : Finset (Equiv.Perm ι)))
      (w := fun _ => 1/P) (p := fun σ => f σ x * Real.log 2)
      (fun _ _ => by positivity) hw (fun _ _ => Set.mem_univ _)
    simp only [smul_eq_mul] at hJ
    have hleft : (∑ σ : Equiv.Perm ι, (1/P) * (f σ x * Real.log 2)) =
        ((∑ σ : Equiv.Perm ι, f σ x) / P) * Real.log 2 := by
      rw [← Finset.mul_sum, ← Finset.sum_mul]
      ring
    have hright : (∑ σ : Equiv.Perm ι, (1/P) * Real.exp (f σ x * Real.log 2)) =
        (∑ σ : Equiv.Perm ι, Real.exp (f σ x * Real.log 2)) / P := by
      rw [← Finset.mul_sum]
      ring
    rw [hleft, hright] at hJ
    exact (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (hmean x hx) hlog.le)).trans hJ
  have hpacks : ∀ σ : Equiv.Perm ι,
      (∑ x ∈ A, Real.exp (f σ x * Real.log 2)) ≤ Real.exp (N * Real.log 2) := by
    intro σ
    have h := guess_packing A (orderRank σ) (orderRank_injective σ)
    have hcast : (∑ x ∈ A, (2 : ℝ) ^ (forcedSet A (orderRank σ) x).card) ≤
        (2 : ℝ) ^ Fintype.card ι := by exact_mod_cast h
    simpa [f, N, Real.exp_nat_mul, Real.exp_log (by norm_num : (0 : ℝ) < 2)] using hcast
  have hsum : (A.card : ℝ) * Real.exp ((N/r) * Real.log 2) ≤ Real.exp (N * Real.log 2) := by
    calc
      _ = ∑ _x ∈ A, Real.exp ((N/r) * Real.log 2) := by simp [nsmul_eq_mul]
      _ ≤ ∑ x ∈ A, (∑ σ : Equiv.Perm ι, Real.exp (f σ x * Real.log 2)) / P :=
        Finset.sum_le_sum fun x hx => hexp x hx
      _ = (∑ σ : Equiv.Perm ι, ∑ x ∈ A, Real.exp (f σ x * Real.log 2)) / P := by
        rw [← Finset.sum_div, Finset.sum_comm]
      _ ≤ (∑ _σ : Equiv.Perm ι, Real.exp (N * Real.log 2)) / P :=
        div_le_div_of_nonneg_right (Finset.sum_le_sum fun σ _ => hpacks σ) hP.le
      _ = _ := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
        change P * Real.exp (N * Real.log 2) / P = _
        field_simp
  have hApos : (0 : ℝ) < A.card := Nat.cast_pos.mpr (Finset.card_pos.mpr hA)
  have hlogsum := Real.strictMonoOn_log.monotoneOn
    (show 0 < (A.card : ℝ) * Real.exp ((N/r) * Real.log 2) by positivity)
    (show 0 < Real.exp (N * Real.log 2) by positivity) hsum
  rw [Real.log_mul hApos.ne' (Real.exp_pos _).ne', Real.log_exp, Real.log_exp] at hlogsum
  change Real.log (A.card : ℝ) ≤ (N - N/r) * Real.log 2
  linarith

theorem ppz_cap (r : ℕ) (hr : 0 < r) :
    PPZCap (ι := ι) r (((Fintype.card ι : ℝ) -
      (Fintype.card ι : ℝ)/r) * Real.log 2) := by
  intro A hA hloc hiso
  exact ppz_log_card A r hr hA hloc hiso


end Nightfall.WynerLocality

#print axioms Nightfall.WynerLocality.guess_packing
#print axioms Nightfall.WynerLocality.last_order_count
#print axioms Nightfall.WynerLocality.ppz_log_card
